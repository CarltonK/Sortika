import * as notification from './notification'
import * as superadmin from 'firebase-admin'
import * as functions from 'firebase-functions'

const db = superadmin.firestore()

export const joinALottery = functions.region('europe-west1').firestore
    .document('lottery/{lot}/participants/{user}')
    .onCreate(async snapshot => {
        try {
            const uid: string = snapshot.get('uid')
            const ticket: string = snapshot.get('ticket')
            const name: string = snapshot.get('name')
            const club: string = snapshot.get('club')
            const fee: number = snapshot.get('fee')
            const token: string = snapshot.get('token')

            await db.collection('lottery').doc(club).update({
                'participants': superadmin.firestore.FieldValue.increment(1)
            })

            const walletRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('wallet').doc(uid)
            db.runTransaction(async trans => {
                return trans.get(walletRef)
                    .then(wallet => {
                        trans.update(walletRef, {amount: superadmin.firestore.FieldValue.increment(-fee)})
                    })
                    .catch(error => console.error('joinALottery Wallet Update ERROR',error))
            })
            .then(async value => {
                const tokenList: string[] = [token]
                await notification.singleNotificationSend(tokenList,`You have successfully joined ${name}. Your ticket number is ${ticket}`,'Congratulations')
                await db.collection('users').doc(uid).collection('notifications').doc().set({
                    'message': `You have successfully joined ${name}. Your ticket number is ${ticket}`,
                    'time': superadmin.firestore.Timestamp.now()
                })
            })
            .catch(error => console.error('joinALottery ERROR', error))
            
        } catch (error) {
            throw error
        }
    })