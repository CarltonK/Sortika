import * as notification from './notification'
import * as superadmin from 'firebase-admin'
import * as functions from 'firebase-functions'

interface Loan {
    loanLender: string,
    loanLenderName: string,
    loanLenderToken: string,
    loanInvitees: string | Array<any>
    loanInviteeName: Array<any>
    tokenInvitee: Array<any>
    loanBorrower: string
    tokenBorrower: string
    borrowerName: string
    sortikaInterestComputed: number
    clientInterestComputed: number
    lfrepaymentAmount: number
    loanAmountTaken: number
    loanAmountRepaid: number
    loanBalance: number
    loanInterest: number
    loanEndDate: FirebaseFirestore.Timestamp
    loanTakenDate: FirebaseFirestore.Timestamp
    loanStatus: string | boolean
    loanIC: number
    totalAmountToPay: number
    sortikaInterest: number
    clientInterest: number
    principal: number
}

/*
What happens after a loan document is created
1) Send notifications
1.1) Borrower acknowledging that a loan request has been sent
1.2) Send a notification to invitees
2) Check if lender === borrower
3) check if invitees === All
4) check if invitee !== All
*/

const db = superadmin.firestore()

export const LoanCreate = functions.region('europe-west1').firestore
    .document('loans/{loan}')
    .onCreate(async snapshot => {
        const loanData = snapshot.data()
        const loanModel: Loan = loanData as Loan
        console.log(`A new loan document has been created`,loanModel)
        try {
            //Step 1 - Send a notification to the borrower (Both FCM and Notifications folder)
            const borrowerUid: string = loanModel.loanBorrower
            const borrowerTokens: Array<string> = [loanModel.tokenBorrower]
            const lenderUid: string = loanModel.loanLender
            const lenderTokens: Array<string> = [loanModel.loanLenderToken]
            const amount: number = loanModel.loanAmountTaken
            const interest: number = loanModel.loanInterest
            await notification.singleNotificationSend(borrowerTokens,`Your request for ${amount} KES at an interest rate of ${interest} % has been sent successfully`,`Wasn't that easy ?`)
            await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                'message': `Your request for ${amount} KES at an interest rate of ${interest} % has been sent successfully`,
                'time': superadmin.firestore.FieldValue.serverTimestamp()
            })

            //Step 2 - Check if the borrower is also the lender
            if (borrowerUid === lenderUid) {
                //Send a notification to the lender i.e yourself
                await notification.singleNotificationSend(lenderTokens,`You have received a loan request for ${amount} KES at an interest rate of ${interest} % from yourself`,'Loan Request')
                await db.collection('users').doc(lenderUid).collection('notifications').doc().set({
                    'message': `You have received a loan request for ${amount} KES at an interest rate of ${interest} % from yourself`,
                    'time': superadmin.firestore.FieldValue.serverTimestamp()
                })

                //Check if i can lend myself
                const myselfQuerySnapshots = await db.collection('users').doc(lenderUid).collection('goals')
                    .where('goalCategory', '==', 'Loan Fund')
                    .limit(1)
                    .get()
                const myselfGoalDocSnapshots = myselfQuerySnapshots.docs
                myselfGoalDocSnapshots.forEach(async (singleGoalDoc: FirebaseFirestore.DocumentSnapshot) => {
                    const amtSaved = singleGoalDoc.get('goalAmountSaved')
                    if (amtSaved >= amount) {
                        //Document Reference of the wallet doc
                        const doc: FirebaseFirestore.DocumentReference = db.collection('users').doc(lenderUid).collection('wallet').doc(lenderUid)
                        const loanDoc: FirebaseFirestore.DocumentReference = db.collection('users').doc(lenderUid).collection('goals').doc(singleGoalDoc.id)
                        //Change the loan document to true
                        await db.collection('loans').doc(snapshot.id).update({
                            'loanStatus': true
                        })
                        db.runTransaction(async transact => {
                            return transact.get(loanDoc)
                                .then(value => {
                                    console.log(`Loan Fund Goal update begin for user: ${lenderUid}`)
                                    transact.update(loanDoc, {goalAmountSaved: superadmin.firestore.FieldValue.increment(-amount)})
                                    console.log(`Loan Fund Goal update end for user: ${lenderUid}`)

                                    db.runTransaction(async transaction => {
                                        return transaction.get(doc)
                                            .then(val => {
                                                console.log(`Wallet update begin for user: ${lenderUid}`)
                                                transaction.update(doc, {amount: superadmin.firestore.FieldValue.increment(amount)})
                                                console.log(`Wallet update end for user: ${lenderUid}`)
                                            })
                                    })
                                    .then(async thenVal => {
                                        await notification.singleNotificationSend(borrowerTokens,`You have successfully borrowed ${amount} KES from your loan Fund Goal`,`Good News`)
                                        await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                                            'message': `You have successfully borrowed ${amount} KES from your loan Fund Goal`,
                                            'time': superadmin.firestore.FieldValue.serverTimestamp()
                                        })
                                        
                                    })
                                    .catch(error => {
                                        console.error(`Wallet update transaction error: ${error}`)
                                    })
                                })
                                .catch(error => {
                                    console.error(`Fetch Loan Fund Goal Error: ${error}`)
                                })
                        })
                        .then(value => {
                            console.log(`Self Loan Transaction completed`)
                        })
                        .catch(error => {
                            console.error(`Self Loan Transaction Error: ${error}`)
                        })
                    }
                    else {
                        await db.collection('loans').doc(snapshot.id).update({
                            'loanStatus': 'Rejected'
                        })
                        await notification.singleNotificationSend(borrowerTokens,`Insufficient funds in your Loan Fund Goal. Top up to get a higher loan limit`,`Bad News`)
                        await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                            'message': `Insufficient funds in your Loan Fund Goal. Top up to get a higher loan limit`,
                            'time': superadmin.firestore.FieldValue.serverTimestamp()
                        })
                    }
                })
            }
            else {
                if (loanModel.loanInvitees !== null) {
                    if (loanModel.loanInvitees === "All") {
                        const batch = db.batch()
                        //Remove 100 from borrowers wallet
                        const borrowerWallerRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(borrowerUid).collection('wallet').doc(borrowerUid)
                        const sortikaRef: FirebaseFirestore.DocumentReference = db.collection('private').doc('LhKYJC32tQHAf8qrnGSn')
                        const sortikaTransactionRef: FirebaseFirestore.DocumentReference = db.collection('private').doc('LhKYJC32tQHAf8qrnGSn').collection('transactions').doc()
                        db.runTransaction(async creditWalletTransaction => {
                            return creditWalletTransaction.get(borrowerWallerRef)
                                .then(async docValue => {
                                    const amountInWallet: number = docValue.get('amount')
                                    if (amountInWallet >= (amount + 100)) {
                                        //Remove 100 from wallet as fee
                                        creditWalletTransaction.update(borrowerWallerRef, {amount: superadmin.firestore.FieldValue.increment(-100)})

                                        batch.update(sortikaRef, {amount : superadmin.firestore.FieldValue.increment(100)})
                                        batch.set(sortikaTransactionRef, {
                                            amount: 100,
                                            type: 'Loan request to All',
                                            uid: loanModel.loanBorrower,
                                            time: superadmin.firestore.FieldValue.serverTimestamp()
                                        })

                                        const action: string = 'Payment'
                                        const category: string = 'Wallet'
                                        const code: string = makeid(10)
                                        const transuid: string = loanModel.loanBorrower
                                        const amountCred: number = 100

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

                                        //Transaction Ref
                                        const transactionRef: FirebaseFirestore.DocumentReference = db.collection('transactions').doc(code)
                                        batch.set(transactionRef, {
                                            transactionAction: action,
                                            transactionCategory: category,
                                            transactionCode: code,
                                            transactionTime: finalTime,
                                            transactionUid: transuid,
                                            transactionAmount: amountCred
                                        })

                                        const usersSatisfying: string[] = []
                                        const namesSatisfying: string[] = []
                                        const tokensSatisfying: string[] = []
                                        // console.log('We will send out a request to all on Sortika who can fullfill the request')
                    
                                        //Retrieve all the users in Sortika
                                        const usersList: Array<string> = []
                                        const userQueries = await db.collection('users').get()
                                        const usersSnapshots: Array<FirebaseFirestore.DocumentSnapshot> = userQueries.docs
                                        usersSnapshots.forEach((userSnap: FirebaseFirestore.DocumentSnapshot) => {
                                            usersList.push(userSnap.get('uid'))
                                        })
                                        // console.log(`All users on db: ${usersList}`)
                    
                                        //Retrieve the LF of each user
                                        //1) Create a list containing promises of QuerySnapshots
                                        const promisesLFQuerySnapshots: Promise<FirebaseFirestore.QuerySnapshot>[] = []
                                        usersList.forEach(async (singleUser: string) => {
                                            const querySnapshot = db.collection('users').doc(singleUser).collection('goals')
                                                .where('goalCategory','==','Loan Fund')
                                                .limit(1)
                                                .get()
                                            promisesLFQuerySnapshots.push(querySnapshot)
                                        })
                                        const lfQuerySnapshots: FirebaseFirestore.QuerySnapshot[] =  await Promise.all(promisesLFQuerySnapshots)
                                        // console.log(`Loan Fund Goal QuerySnapshots: ${lfQuerySnapshots}`)
                    
                                        //2) Retrieve a list of all document snapshots
                                        lfQuerySnapshots.forEach((singleGoalSnapshot: FirebaseFirestore.QuerySnapshot) => {
                                            const snapshotGoalDocs: FirebaseFirestore.DocumentSnapshot[] = singleGoalSnapshot.docs
                                            snapshotGoalDocs.forEach(async (goalDocSnap: FirebaseFirestore.DocumentSnapshot) => {
                                                const amtSaved: number = goalDocSnap.get('goalAmountSaved')
                                                const userID: string = goalDocSnap.get('uid')
                                                if (amtSaved >= amount) {
                                                    // console.log(`${userID} can fulfill the request`)
                                                    if (userID !== borrowerUid) {
                                                        usersSatisfying.push(userID)
                                                    }
                                                    else {
                                                        await db.collection('loans').doc(snapshot.id).update({
                                                            'loanStatus': true,
                                                            'loanLender': loanModel.loanBorrower,
                                                            'loanLenderToken': loanModel.tokenBorrower,
                                                            'loanLenderName': loanModel.borrowerName
                                                        })
                                                        const doc: FirebaseFirestore.DocumentReference = db.collection('users').doc(userID).collection('wallet').doc(userID)
                                                        const loanDoc: FirebaseFirestore.DocumentReference = db.collection('users').doc(userID).collection('goals').doc(goalDocSnap.id)
                                                        db.runTransaction(async transact => {
                                                            return transact.get(loanDoc)
                                                                .then(value => {
                                                                    console.log(`Loan Fund Goal update begin for user: ${userID}`)
                                                                    transact.update(loanDoc, {goalAmountSaved: superadmin.firestore.FieldValue.increment(-amount)})
                                                                    console.log(`Loan Fund Goal update end for user: ${userID}`)
                                
                                                                    db.runTransaction(async transaction => {
                                                                        return transaction.get(doc)
                                                                            .then(val => {
                                                                                console.log(`Wallet update begin for user: ${userID}`)
                                                                                transaction.update(doc, {amount: superadmin.firestore.FieldValue.increment(amount + 100)})
                                                                                console.log(`Wallet update end for user: ${userID}`)
                                                                            })
                                                                    })
                                                                    .then(async thenVal => {
                                                                        await notification.singleNotificationSend(borrowerTokens,`You have successfully borrowed ${amount} KES from your loan Fund Goal`,`Good News`)
                                                                        await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                                                                            'message': `You have successfully borrowed ${amount} KES from your loan Fund Goal`,
                                                                            'time': superadmin.firestore.FieldValue.serverTimestamp()
                                                                        })
                                                                        
                                                                    })
                                                                    .catch(error => {
                                                                        console.error(`Wallet update transaction error: ${error}`)
                                                                    })
                                                                })
                                                                .catch(error => {
                                                                    console.error(`Fetch Loan Fund Goal Error: ${error}`)
                                                                })
                                                        })
                                                        .then(value => {
                                                            console.log(`Self Loan Transaction completed`)
                                                        })
                                                        .catch(error => {
                                                            console.error(`Self Loan Transaction Error: ${error}`)
                                                        })
                                                    }
                                                }
                                            })
                                        })

                                        if (usersSatisfying.length === 0) {
                                            //Inform borrower that no one can fullfill the request
                                            await notification.singleNotificationSend(borrowerTokens,`Unfortunately no one can satisfy your request. Please send another loan request`,`Bad News`)
                                            await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                                                'message': `Unfortunately no one can satisfy your request. Please send another loan request`,
                                                'time': superadmin.firestore.FieldValue.serverTimestamp()
                                            })
                                            //Reject the loan
                                            await db.collection('loans').doc(snapshot.id).update({
                                                'loanStatus': 'Rejected'
                                            })
                                        }
                    
                                        //3) Retrieve Names and Tokens of each user
                                        const promisesUserSnapshots: Promise<FirebaseFirestore.DocumentSnapshot>[] = []
                                        usersSatisfying.forEach((userSatisy: string) => {
                                            const userStisfySnap =  db.collection('users').doc(userSatisy).get()
                                            promisesUserSnapshots.push(userStisfySnap)
                                        })
                                        const usersSnapshotsSatisfy: FirebaseFirestore.DocumentSnapshot[] = await Promise.all(promisesUserSnapshots)
                                        console.log(`Users Satisfying Document Snapshots: ${usersSnapshotsSatisfy}`)
                    
                                        usersSnapshotsSatisfy.forEach((userSatisfyDocSnap: FirebaseFirestore.DocumentSnapshot) => {
                                            const tokenSingle: string = userSatisfyDocSnap.get('token')
                                            const fullNameSingle: string = userSatisfyDocSnap.get('fullName')
                                            const nameSingle: string =  fullNameSingle.split(' ')[0]
                                            
                                            //Push to list
                                            namesSatisfying.push(nameSingle)
                                            tokensSatisfying.push(tokenSingle)
                                        })
                    
                                        //4) Update the loan document
                                        if (namesSatisfying.length === tokensSatisfying.length) {
                                            await db.collection('loans').doc(snapshot.id).update({
                                                'loanInviteeName': namesSatisfying,
                                                'loanInvitees': usersSatisfying,
                                                'tokenInvitee': tokensSatisfying
                                            })
                                        }
                    
                                        //5) Send notifications
                                        //5.1) FCM
                                        await notification.singleNotificationSend(tokensSatisfying,`You have received a loan request for ${amount} KES at an interest rate of ${interest} %`,'Loan Request')
                                        //5.2) Notifications
                                       
                                        usersSatisfying.forEach((singleInvitee: string) => {
                                            const inviteeDocRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(singleInvitee).collection('notifications').doc()
                                            batch.set(inviteeDocRef,{
                                                'message': `You have received a loan request for ${amount} KES at an interest rate of ${interest} %`,
                                                'time': superadmin.firestore.FieldValue.serverTimestamp()
                                            })
                                        })
                                        await batch.commit()
                    
                                        console.log('A request and a notification has been sent out to all on Sortika who can fullfill the request')
                                    }
                                    else {
                                        //Send an insufficient funds notification
                                        await notification.singleNotificationSend(borrowerTokens,`Insufficient funds in your wallet to make this loan request. We charge 100 KES for sending a loan request to All`,'Bad News')
                                        await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                                            message: `Insufficient funds in your wallet to make this loan request. We charge 100 KES for sending a loan request to All`,
                                            time: superadmin.firestore.Timestamp.now()
                                        })
                                    }
                                })
                                .catch(error => console.error('crediting Wallet ERROR',error))
                        })
                        .then(value => console.log(`Successfully credited 100 from wallet of ${borrowerUid} for a loan request to all`))
                        .catch(error => console.error('sendInvitationToAll ERROR',error))

                    }
                    else {
                        //Then loanInvitees is an Array<string>
                        //Send an FCM Message
                        const invitees: any = loanModel.loanInvitees
                        const inviteeTokens: Array<string> = loanModel.tokenInvitee
    
                        //In this case loanInvitees can only contain one item
                        if (invitees.length === 1) {
                            const inviteeID: string =  invitees[0]
                            const inviteeLFGoalQuerySnap: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(inviteeID).collection('goals')
                                .where('goalCategory','==','Loan Fund')
                                .limit(1)
                                .get()
                            const inviteeGoals: FirebaseFirestore.DocumentSnapshot[] =  inviteeLFGoalQuerySnap.docs
                            inviteeGoals.forEach(async (singleInviteeDoc: FirebaseFirestore.DocumentSnapshot) => {
                                const amtSaved = singleInviteeDoc.get('goalAmountSaved')
                                if (amtSaved >= amount) {
                                    //Send Notifications
                                    await notification.singleNotificationSend(inviteeTokens,`You have received a loan request for ${amount} KES at an interest rate of ${interest} %`,'Loan Request')
                                    await db.collection('users').doc(inviteeID).collection('notifications').doc().set({
                                        'message': `You have received a loan request for ${amount} KES at an interest rate of ${interest} %`,
                                        'time': superadmin.firestore.FieldValue.serverTimestamp()
                                    })
                                }
                                else {
                                    //Send Notifications
                                    await notification.singleNotificationSend(inviteeTokens,`You have received a loan request for ${amount} KES but you do not qualify to be a lender. Continue to top up to take advantage of such opportunities`,'Loan Request')
                                    await db.collection('users').doc(inviteeID).collection('notifications').doc().set({
                                        'message': `You have received a loan request for ${amount} KES but you do not qualify to be a lender. Continue to top up your Loan Fund Goal to take advantage of such opportunities`,
                                        'time': superadmin.firestore.FieldValue.serverTimestamp()
                                    })
                                }
                            })
                        }
                    }
                }
            }
        } catch (error) {
            console.error('LoanCreateError: ',error)
        }
    })


export const LoanStatusUpdate = functions.region('europe-west1').firestore
    .document('loans/{loan}')
    .onUpdate(async snapshot => {
        const loanData = snapshot.after.data()
        const loanModel: Loan = loanData as Loan 

        const token: string = loanModel.tokenBorrower
        const amount: number = loanModel.loanAmountTaken
        const interest: number = loanModel.loanInterest
        const due: number = loanModel.totalAmountToPay
        const borrowerUid: string = loanModel.loanBorrower
        const lenderUid: string = loanModel.loanLender
        const time: FirebaseFirestore.Timestamp = loanModel.loanEndDate

        if (loanData.loanStatus === 'Revised') {
            console.log(`A loan has been revised ${snapshot.after.id}`)
            try {
                const borrowerTokens: string[] = [token]
                await notification.singleNotificationSend(borrowerTokens,`Your loan request submission has been revised. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. You will pay back ${due} KES`,`Loan Revision`)
                await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                    'message': `Your loan request submission has been revised. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. You will pay back ${due} KES`,
                    'time': superadmin.firestore.FieldValue.serverTimestamp()
                })
            } catch (error) {
                console.error('loanRevisionError', error)
            }
        }

        if (loanData.loanStatus === 'Revised2') {
            console.log(`A loan has been re-revised ${snapshot.after.id}`)
            try {
                const borrowerTokens: string[] = [token]
                await notification.singleNotificationSend(borrowerTokens,`You have sent a revised loan request submission`,`Loan Revision`)
                await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                    'message': `You have sent a revised loan request submission`,
                    'time': superadmin.firestore.FieldValue.serverTimestamp()
                })

                if (loanModel.loanLender !== null && loanModel.loanLenderToken !== null) {
                    try {
                        const lenderTokens: string[] = [loanModel.loanLenderToken]
                        await notification.singleNotificationSend(lenderTokens,`You have received a revised loan request. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. They will pay back ${due} KES`,`Loan Revision`)
                        const batch = db.batch()
                        const notificationRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(loanModel.loanLender).collection('notifications').doc()
                        batch.set(notificationRef, {
                            'message': `You have received a revised loan request. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. They will pay back ${due} KES`,
                            'time': superadmin.firestore.FieldValue.serverTimestamp()
                        })
                        await batch.commit()
                    } catch (error) {
                        throw error
                    }
                }
            } catch (error) {
                console.error('loanNegotiationError', error)
            }
        }

        if (loanModel.loanStatus === 'Rejected') {
            console.log(`A loan has been rejected ${snapshot.after.id}`)
            try {
                const borrowerTokens: string[] = [token]
                await notification.singleNotificationSend(borrowerTokens,`Your loan request of ${amount} KES at ${interest} % has been rejected`,`Bad News`)
                await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                    'message': `Your loan request of ${amount} KES at ${interest} % has been rejected`,
                    'time': superadmin.firestore.FieldValue.serverTimestamp()
                })
                //Delete the Document
                await db.collection('loans').doc(snapshot.after.id).delete()
            } catch (error) {
                console.error('loanRejectedError', error)
            }
        }


        if (loanModel.loanStatus === 'Completed') {
            console.log(`A loan has been completed ${snapshot.after.id}`)
            if (loanModel.loanBorrower === loanModel.loanLender) {
                await increaseLoanLimit(interest,borrowerUid)
            }
        }

        if (loanModel.loanStatus === true) {
            if (snapshot.before.get('loanStatus') === true) {
                console.log('This loan is already true. Then we can assume that the loanAmountRepaid has changed')
            }
            else {
                try {
                    if (borrowerUid !== lenderUid) {
                        //Check if indeed the lender can satisfy the requirement
                        const lenderLFGQuery = await db.collection('users').doc(lenderUid).collection('goals').where('goalCategory','==','Loan Fund')
                            .limit(1).get()
                        const lenderGoals: FirebaseFirestore.DocumentSnapshot[] = lenderLFGQuery.docs
                        if (lenderGoals.length === 1) {
                            const glDoc: FirebaseFirestore.DocumentSnapshot = lenderGoals[0]
                            const amtSaved: number = glDoc.get('goalAmountSaved')
                            if (amtSaved >= amount) {
                                //The user can satisfy this requirement
                                //Transfer money from Loan Fund Goal to your wallet
                                const lenderLoanFundDoc: FirebaseFirestore.DocumentReference = db.collection('users').doc(lenderUid).collection('goals').doc(glDoc.id)
                                //Borrowers Wallet Reference
                                const borrowerWalletDoc: FirebaseFirestore.DocumentReference = db.collection('users').doc(borrowerUid).collection('wallet').doc(borrowerUid)
                                db.runTransaction(async transact => {
                                    return transact.get(lenderLoanFundDoc)
                                        .then(value => {
                                            console.log(`Loan Fund Goal update begin for user: ${lenderUid}`)
                                            transact.update(lenderLoanFundDoc, {goalAmountSaved: superadmin.firestore.FieldValue.increment(-amount)})
                                            console.log(`Loan Fund Goal update end for user: ${lenderUid}`)
        
                                            db.runTransaction(async transaction => {
                                                return transaction.get(borrowerWalletDoc)
                                                    .then(val => {
                                                        console.log(`Wallet update begin for user: ${borrowerUid}`)
                                                        transaction.update(borrowerWalletDoc, {amount: superadmin.firestore.FieldValue.increment(amount)})
                                                        console.log(`Wallet update end for user: ${borrowerUid}`)
                                                    })
                                            })
                                            .then(async thenVal => {
                                                console.log('The wallet has beeen updated successfully after the loan')
                                                //Send a success notification to both lender and borrower
                                                const borrowerTokens: string[] = [token]
                                                await notification.singleNotificationSend(borrowerTokens,`Your loan request of ${amount} KES has been accepted. You will payback ${due} KES. You have until ${time.toDate().toString()}. The transaction is being processed`,`Good News`)
                                                await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                                                    'message': `Your loan request of ${amount} KES has been accepted. You will payback ${due} KES. You have until ${time.toDate().toString()}. The transaction is being processed`,
                                                    'time': superadmin.firestore.FieldValue.serverTimestamp()
                                                })
                                            })
                                            .catch(error => {
                                                console.error(`Wallet update transaction error: ${error}`)
                                            })
                                        })
                                        .catch(error => {
                                            console.error(`Fetch Loan Fund Goal Error: ${error}`)
                                        })
                                })
                                .then(value => {
                                    console.log(`P2P Loan Transaction completed`)
                                })
                                .catch(error => {
                                    console.error(`P2P Loan Transaction Error: ${error}`)
                                })
                            }
                            else {
                                //Send a notification to the borrower and then delete the goal
                                const borrowerTokens: string[] = [token]
                                await notification.singleNotificationSend(borrowerTokens,`Unfortunately your request could not be fullfilled due to insuffient funds. Send another request, people are waiting for your offer`,`Bad News`)
                                await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                                    'message': `Unfortunately your request could not be fullfilled due to insuffient funds. Send another request, people are waiting for your offer`,
                                    'time': superadmin.firestore.FieldValue.serverTimestamp()
                                })
                                await db.collection('loans').doc(snapshot.after.id).delete()
                            }
                        }
                    }
                } catch (error) {
                    console.error('loanAcceptanceError', error)
                }
            }
        }

        if (loanModel.loanBalance === 0) {
            await db.collection('loans').doc(snapshot.after.id).update({
                'loanStatus': 'Completed',
                'loanAmountTaken': loanModel.loanAmountRepaid,
            })
        }
    })


export const LoanRepaid = functions.region('europe-west1').firestore
    .document('loans/{loan}')
    .onUpdate(async snapshot => {
        
        const loanData = snapshot.after.data()
        const loanModel: Loan = loanData as Loan

        const lender: string = loanModel.loanLender
        console.log(`The lender is ${lender}`)

        const batch = db.batch()

        try {
            //A reference to this loan document
            const loanDocRef: FirebaseFirestore.DocumentReference = db.collection('loans').doc(snapshot.after.id)
            //Get a reference to the lender wallet,lender loan fund goal, sortika document
            const lenderWalletRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(lender).collection('wallet').doc(lender)
            const lenderGoalsQuery: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(lender)
                .collection('goals').where('goalCategory','==','Loan Fund').limit(1).get()
            const lenderGoalDoc: FirebaseFirestore.DocumentSnapshot = lenderGoalsQuery.docs[0]
            const lenderGoalDocID: string = lenderGoalDoc.id
            const lenderLFRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(lender).collection('goals').doc(lenderGoalDocID)
            const sortikaRef: FirebaseFirestore.DocumentReference = db.collection('private').doc('LhKYJC32tQHAf8qrnGSn')
            const sortikaTransactionRef: FirebaseFirestore.DocumentReference = db.collection('private').doc('LhKYJC32tQHAf8qrnGSn').collection('transactions').doc()

            const amtBefore: number = snapshot.before.get('loanAmountRepaid')
            if (amtBefore !== loanModel.loanAmountRepaid) {
                if (loanModel.loanBalance > 0) {
                    //Calculate loan allocations
                    const allcationSortika: number = (loanModel.sortikaInterestComputed / loanModel.totalAmountToPay)
                    const allcationClient: number = (loanModel.clientInterestComputed / loanModel.totalAmountToPay)
                    const allcationPrincipal: number = (loanModel.loanAmountTaken / loanModel.totalAmountToPay)

                    //Amount Paid in a single session
                    const diff: number = loanModel.loanAmountRepaid - amtBefore
                    //Loan Balance
                    const balance: number = loanModel.totalAmountToPay - loanModel.loanAmountRepaid

                    //Sortika Update
                    batch.update(loanDocRef, {sortikaInterest : superadmin.firestore.FieldValue.increment(diff * allcationSortika)})
                    batch.update(sortikaRef, {amount : superadmin.firestore.FieldValue.increment(diff * allcationSortika)})
                    batch.set(sortikaTransactionRef, {
                        amount: diff * allcationSortika,
                        type: 'Loan Repayment',
                        uid: loanModel.loanBorrower,
                        time: superadmin.firestore.FieldValue.serverTimestamp()
                    })

                    //Client Update
                    batch.update(loanDocRef, {clientInterest : superadmin.firestore.FieldValue.increment(diff * allcationClient)})
                    batch.update(lenderWalletRef, {amount : superadmin.firestore.FieldValue.increment(diff * allcationClient)})
                    //Categorise under wallet of lender

                    const action: string = 'Earning'
                    const category: string = 'Wallet'
                    const code: string = makeid(10)
                    const transuid: string = loanModel.loanLender
                    const amount: number = diff * allcationClient

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

                    //Transaction Ref
                    const transactionRef: FirebaseFirestore.DocumentReference = db.collection('transactions').doc(code)
                    batch.set(transactionRef, {
                        transactionAction: action,
                        transactionCategory: category,
                        transactionCode: code,
                        transactionTime: finalTime,
                        transactionUid: transuid,
                        transactionAmount: amount
                    })

                    //Principal Update
                    batch.update(loanDocRef, {principal : superadmin.firestore.FieldValue.increment(diff * allcationPrincipal)})
                    batch.update(lenderLFRef, {goalAmountSaved : superadmin.firestore.FieldValue.increment(diff * allcationPrincipal)})

                    //Balance Update
                    batch.update(loanDocRef, {loanBalance : balance})

                    //Send a notification to a Lender that a loan has been repaid
                    const lenderTokens: string[] = [loanModel.loanLenderToken]
                    await notification.singleNotificationSend(lenderTokens, `${loanModel.borrowerName} has made a loan payment of ${diff} KES. Loan balance is ${balance} KES`,'Good News')
                    const notRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(transuid).collection('notifications').doc()
                    batch.set(notRef, {
                        message: `${loanModel.borrowerName} has made a loan payment of ${diff} KES. Loan balance is ${balance} KES`,
                        time: superadmin.firestore.Timestamp.now()
                    })

                    await batch.commit()
                }
            }

        
        } catch (error) {
            throw error
        }
    })


function makeid(length: number): string {
    let result           = '';
    const characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const charactersLength = characters.length;
    for ( let i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}


/*
NB
//Loan Limit Ratio = ((interest amount / limit ratio) * 100)
1) Loan Limit Ratio only changes when loan has been fully paid
*/

async function increaseLoanLimit(interest: number, uid: string) {
    const rate: number = interest * 0.75
    const userDocRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid)
    try {
        db.runTransaction(async transaction => {
            return transaction.get(userDocRef)
                .then(value => {
                    transaction.update(userDocRef,{'loanLimitRatio':superadmin.firestore.FieldValue.increment(rate)})
                })
                .catch(error => console.error('userDocRetrieval ERROR', error))
        })
        .then(valueTrans => {
            console.log('Loan Limit Increased')
        })
        .catch(valueError => {
            console.log('increaseLoanLimit ERROR',valueError)
        })
    } catch (error) {
        throw error
    }
}


export const LoanPayment = functions.region('europe-west1').firestore
    .document('loanpayments/{payments}')
    .onCreate(async snapshot => {
        const borrower: string = snapshot.get('borrowerUid')
        const loanDoc: string = snapshot.get('loanDoc')
        const amount: number = snapshot.get('amount')

        //Retrieve borrower wallet
        const borrowerWalletRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(borrower).collection('wallet').doc(borrower)
        //Retrieve loan document
        const loanDocRef: FirebaseFirestore.DocumentReference = db.collection('loans').doc(loanDoc)

        try {
            db.runTransaction(async transactionBorrower => {
                return transactionBorrower.get(borrowerWalletRef)
                    .then(async tranBorrDoc => {
                        transactionBorrower.update(borrowerWalletRef,{amount: superadmin.firestore.FieldValue.increment(-amount)})
                        // console.log(`We have credited the wallet of ${borrower} with ${amount} KES`)
    
                        await db.collection('users').doc(borrower).collection('notifications').doc().set({
                            'message': `Your wallet has been credited with ${amount} KES for loan payment`,
                            'time': superadmin.firestore.Timestamp.now()
                        })

                        const code: string = makeid(10)

                        const action: string = 'Payment'
                        const category: string = 'Wallet'
                        const transuid: string = borrower

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
                    })
                    .catch(error => {
                        console.error(`We ran into the following error when trying to retrieve and update borrowersWallet: ${error}`)
                    })
            })
            .then(value => {
                // console.log(`The wallet of ${borrower} has been updated`)
                // console.log(`Start updating the loan`)
                db.runTransaction(async transactionLoanPay => {
                    return transactionLoanPay.get(loanDocRef)
                        .then(async tranLoanDoc => {
                            transactionLoanPay.update(loanDocRef, {loanAmountRepaid: superadmin.firestore.FieldValue.increment(amount)})
                        })
                        .catch(error => {
                            console.error(`We ran into the following error when trying to update the loan document: ${error}`)
                        })
                })
                .then(transDocValue => {
                    console.log(`The loan has been updated`)
                })
                .catch(error => console.error(`There was an error updating the loan document`,error))
            })
            .catch(error => {
                console.error(`We ran into the following error when trying to perform overal loan payment transaction: ${error}`)
            })
            
        } catch (error) {
            throw error
        }
    })



/*
        function recoupSortika(diff: number): boolean {
            if (diff >= loanModel.sortikaInterestComputed) {
                loanModel.sortikaInterest = loanModel.sortikaInterestComputed
                return true
            }
            else {
                loanModel.sortikaInterest = diff
                return false
            }
        }

        // function recoupClient(diff: number): boolean {
            
        //     if ((diff - loanModel.sortikaInterestComputed) >= loanModel.clientInterestComputed) {
        //         loanModel.clientInterest = loanModel.clientInterestComputed
        //         return true
        //     }
        //     else {
        //         loanModel.clientInterest = diff - loanModel.sortikaInterestComputed
        //         return false
        //     }
        // }

        // function recoupPrincipal(diff: number): boolean {
        //     if ((diff - loanModel.sortikaInterestComputed - loanModel.clientInterestComputed) >= loanModel.loanAmountTaken) {
        //         loanModel.principal = loanModel.loanAmountTaken
        //         return true
        //     }
        //     else {
        //         loanModel.principal = diff - loanModel.sortikaInterestComputed - loanModel.clientInterestComputed
        //         return false
        //     }
        // }
*/