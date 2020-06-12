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

export const LoanCreate = functions.firestore
    .document('loans/{loan}')
    .onCreate(async snapshot => {
        const loanData = snapshot.data()
        const loanModel: Loan = loanData as Loan
        // console.log(`A new loan document has been created`,loanModel)
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
                        const usersSatisfying: string[] = []
                        const namesSatisfying: string[] = []
                        const tokensSatisfying: string[] = []
                        console.log('We will send out a request to all on Sortika who can fullfill the request')
    
                        //Retrieve all the users in S0rtika
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
                                    console.log(`${userID} can fulfill the request`)
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
                                                                transaction.update(doc, {amount: superadmin.firestore.FieldValue.increment(amount)})
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
                        const batch = db.batch()
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


export const LoanAcceptance = functions.firestore
    .document('loans/{loan}')
    .onUpdate(async snapshot => {
        const loanData = snapshot.after.data()
        const loanModel: Loan = loanData as Loan 

        const borrowerUid: string = loanModel.loanBorrower
        const borrowerToken: string = loanModel.tokenBorrower
        const amount: number = loanModel.loanAmountTaken
        const due: number = loanModel.totalAmountToPay
        const lenderUid: string = loanModel.loanLender
        const time: FirebaseFirestore.Timestamp = loanModel.loanEndDate

        //Send notifications to relavant parties
        //Send only when p2p - hence why we check if lender === borrower
        if (snapshot.before.get('loanStatus') === false && loanModel.loanStatus === true) {
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
                                            const borrowerTokens: string[] = [borrowerToken]
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
                            const borrowerTokens: string[] = [borrowerToken]
                            await notification.singleNotificationSend(borrowerTokens,`Unfortunately your request could not be fullfilled due to insuffient funds. Send another request, people are waiting for your offer`,`Bad News`)
                            await db.collection('loans').doc(snapshot.after.id).delete()
                        }
                    }
                }
            } catch (error) {
                console.error('loanAcceptanceError', error)
            }
        }
    })


export const LoanRevision = functions.firestore
    .document('loans/{loan}')
    .onUpdate(async snapshot => {
        const loanData = snapshot.after.data()
        const loanModel: Loan = loanData as Loan 

        const token: string = loanModel.tokenBorrower
        const amount: number = loanModel.loanAmountTaken
        const interest: number = loanModel.loanInterest
        const due: number = loanModel.totalAmountToPay
        const borrowerUid: string = loanModel.loanBorrower

        if (loanData.loanStatus === 'Revised') {
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
    })


export const LoanNegotiation = functions.firestore
    .document('loans/{loan}')
    .onUpdate(async snapshot => {
        const loanData = snapshot.after.data()
        const loanModel: Loan = loanData as Loan 

        const token: string = loanModel.tokenBorrower
        const borrowerUid: string = loanModel.loanBorrower

        if (loanData.loanStatus === 'Revised2') {
            try {
                const borrowerTokens: string[] = [token]
                await notification.singleNotificationSend(borrowerTokens,`You have sent a revised loan request submission`,`Loan Revision`)
                await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                    'message': `You have sent a revised loan request submission`,
                    'time': superadmin.firestore.FieldValue.serverTimestamp()
                })
            } catch (error) {
                console.error('loanNegotiationError', error)
            }
        }
    })


export const LoanRejected = functions.firestore
    .document('loans/{loan}')
    .onUpdate(async snapshot => {

        const loanData = snapshot.after.data()
        const loanModel: Loan = loanData as Loan

        const token: string = loanModel.tokenBorrower
        const amount: number = loanModel.loanAmountTaken
        const interest: number = loanModel.loanInterest
        const borrowerUid: string = loanModel.loanBorrower
        //Retrieve the token (If exists)
        if (loanModel.loanStatus === 'Rejected') {
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
    })