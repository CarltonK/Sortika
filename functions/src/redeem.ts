import * as notification from './notification'
import * as superadmin from 'firebase-admin'
import * as functions from 'firebase-functions'


const db = superadmin.firestore()

function makeid(length: number): string {
    let result           = '';
    const characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const charactersLength = characters.length;
    for ( let i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}

//Redeem Goal
export const RedeemGoal = functions.region('europe-west1').firestore
    .document('/users/{user}/redeem/{redeem}')
    .onCreate(async snapshot => {
        const uid: string = snapshot.get('uid')
        const goal: string = snapshot.get('goal')
        const amount: number = snapshot.get('amount')
        const token: string = snapshot.get('token')
        const tokenList: string[] = [token]
        let redeemed: boolean = false

        const walletRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('wallet').doc(uid)
        const goalRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(goal)

        db.runTransaction(async transactionGoal => {
            return transactionGoal.get(goalRef)
                .then(async goalValue => {
                    const category: string = goalValue.get('goalCategory')
                    const amtSaved: number = goalValue.get('goalAmountSaved')
                    if (category === 'Loan Fund') {
                        if ((amtSaved - 200) > amount) {
                            transactionGoal.update(goalRef, {goalAmountSaved : superadmin.firestore.FieldValue.increment(-amount)})
                            redeemed = true

                            //Send a success notification
                            await notification.singleNotificationSend(tokenList, `You have successfully redeemed ${amount} KES from your ${category} goal`,'Good News')
                            await db.collection('users').doc(uid).collection('notifications').doc().set({
                                message: `You have successfully redeemed ${amount} KES from your ${category} goal`,
                                time: superadmin.firestore.Timestamp.now()
                            })

                        }
                        else {
                            await notification.singleNotificationSend(tokenList, `You cannot redeem ${amount} KES from ${category} goal because of insufficient funds`,'Bad News')
                            await db.collection('users').doc(uid).collection('notifications').doc().set({
                                message: `You cannot redeem ${amount} KES from ${category} goal because of insufficient funds`,
                                time: superadmin.firestore.Timestamp.now()
                            })
                        }
                    }
                    else {
                        if (amtSaved > amount) {
                            transactionGoal.update(goalRef, {goalAmountSaved : superadmin.firestore.FieldValue.increment(-amount)})
                            redeemed = true

                            //Send a success notification
                            await notification.singleNotificationSend(tokenList, `You have successfully redeemed ${amount} KES from your ${category} goal`,'Good News')
                            await db.collection('users').doc(uid).collection('notifications').doc().set({
                                message: `You have successfully redeemed ${amount} KES from your ${category} goal`,
                                time: superadmin.firestore.Timestamp.now()
                            })
                        }
                        else {
                            await notification.singleNotificationSend(tokenList, `You cannot redeem ${amount} KES from ${category} goal because of insufficient funds`,'Bad News')
                            await db.collection('users').doc(uid).collection('notifications').doc().set({
                                message: `You cannot redeem ${amount} KES from ${category} goal because of insufficient funds`,
                                time: superadmin.firestore.Timestamp.now()
                            })
                        }
                    }
                })
                .catch(error => console.log('goal transaction ERROR',error))
        })
        .then(async valueGoal => {
            db.runTransaction(async transWallet => {
                return transWallet.get(walletRef)
                    .then(async walletValue => {
                        if (redeemed) {
                            transWallet.update(walletRef, {amount : superadmin.firestore.FieldValue.increment(amount)})

                            const code: string = makeid(10)

                            const action: string = 'Redemption'
                            const category: string = 'Wallet'
                            const transuid: string = uid

                            //Time Formatting
                            let time: string = ''
                            const now: Date = superadmin.firestore.Timestamp.now().toDate()

                            const year: string = now.getFullYear().toString()
                            time += year

                            const month: string = now.getUTCMonth().toString()
                            time += month

                            const day: string = now.getUTCDate().toString()
                            time += day

                            const hr: string = now.getUTCHours().toString()
                            time += hr

                            const min: string = now.getUTCMinutes().toString()
                            time += min

                            const sec: string = now.getUTCSeconds().toString()
                            time += sec

                            const finalTime: number = Number(time)
                            
                            await db.collection('transactions').doc(code).set({
                                transactionAction: action,
                                transactionCategory: category,
                                transactionCode: code,
                                transactionTime: finalTime,
                                transactionUid: transuid,
                                transactionAmount: amount
                            })
                        }
                    })
                    .catch(error => console.error('wallet update ERROR', error))
            })
            .then(valueOps => console.log('wallet has updated after redeem goal'))
            .catch(valueEror => console.error('wallet update error after redeemGoal',valueEror))
        })
        .catch(error => console.error('redeemGoal ERROR', error))
    })