import { Request, Response } from "express";
import * as superadmin from 'firebase-admin'
import { DocumentSnapshot } from "firebase-functions/lib/providers/firestore";

export function mpesaCallback(request: Request, response: Response) {
    try {
        console.log('---Received Safaricom M-PESA Webhook---')
        const serverRequest = request.body
        //Get the ResponseCode
        const code: number = serverRequest['Body']['stkCallback']['ResultCode']
        if (code === 0) {
            const transactionAmount: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][0]['Value']
            const transactionCode: string = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][1]['Value']
            const transactionTime: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][3]['Value']
            const transactionPhone: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][4]['Value']

            // console.log(`Amount: ${transactionAmount}`)
            // console.log(`Code: ${transactionCode}`)
            // console.log(`Time: ${transactionTime}`)
            // console.log(`Phone: ${transactionPhone}`)

            let transactionPhoneFormatted: string = transactionPhone.toString().slice(3)
            transactionPhoneFormatted = "0" + transactionPhoneFormatted

            // console.log(transactionPhoneFormatted)

            const db = superadmin.firestore()
            //Search for user with matching phone number
            db.collection('users').where('phone' ,'==', transactionPhoneFormatted).limit(1).get()
                .then(async (value) => {
                    if (value.docs.length === 1) {
                        await db.collection('transactions').doc(transactionCode).set({
                            'transactionAmount': transactionAmount,
                            'transactionCode': transactionCode,
                            'transactionTime': transactionTime,
                            'transactionPhone': transactionPhone,
                        })

                        const document: DocumentSnapshot = value.docs[0]
                        const uid: string = document.get('uid')

                        //Check deposit => FieldValue = destination
                        const depositDocument: DocumentSnapshot = await db.collection('deposits').doc(uid).get()
                        const destination: string = depositDocument.get('destination')
                        const goal: string = depositDocument.get('goalName')

                        if (destination === 'wallet') {
                            const docRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('wallet').doc(uid)
                            const transactRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('transactions').doc(transactionCode)
                            db.runTransaction(async transaction => {
                                return transaction.get(docRef)
                                    .then(doc => {
                                        transaction.update(docRef, {amount: superadmin.firestore.FieldValue.increment(transactionAmount)})
                                        console.log('transactions collection update begin')
                                            transaction.set(transactRef, {
                                                'transactionAction': 'Deposit',
                                                'transactionAmount': transactionAmount,
                                                'transactionDate': superadmin.firestore.Timestamp.now(),
                                                'transactionCategory': 'Wallet',
                                                'transactionCode': transactionCode
                                            })
                                            console.log('transactions collection update end')
                                    });
                            })
                            .then(result => {
                                console.log('Wallet update success')
                            })
                            .catch(err => {
                                console.log('Wallet update failure:', err)
                            })
                        }
                        if (destination === 'general') {
                            let category: string
                            let goalName: any 
                            const userGoalsQueries: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid).collection('goals').get()
                            const userGoalsDocs: Array<DocumentSnapshot> = userGoalsQueries.docs
                            userGoalsDocs.forEach((element) => {
                                category = element.get('goalCategory')
                                goalName = element.get('goalName')
                                if (goalName === null) {
                                    goalName = category
                                } 
                                const docRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(element.id)
                                const transactRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('transactions').doc(transactionCode)
                                db.runTransaction(async transaction => {
                                    return transaction.get(docRef)
                                        .then(doc => {
                                            const newIncrement: number = (transactionAmount * doc.get('goalAllocation')) / 100
                                            transaction.update(docRef, {goalAmountSaved: superadmin.firestore.FieldValue.increment(newIncrement)})
                                            console.log('transactions collection update begin')
                                            transaction.set(transactRef, {
                                                'transactionAction': 'Deposit',
                                                'transactionAmount': transactionAmount,
                                                'transactionDate': superadmin.firestore.Timestamp.now(),
                                                'transactionCategory': category,
                                                'transactionGoal': goalName,
                                                'transactionCode': transactionCode
                                            })
                                            console.log('transactions collection update end')
                                        })
                                })
                                .then(result => {
                                    console.log('General update success!')
                                })
                                .catch(err => {
                                    console.log('General update failure:', err)
                                })
                            })
                            
                        }
                        if (destination === 'specific' && goal !== null) {
                            console.log(`Deposit to specific goal: ${goal}`)
                            if (goal === 'Loan Fund') {
                                const userLoanFundQuery: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid).collection('goals')
                                    .where('goalCategory','==','Loan Fund')
                                    .limit(1)
                                    .get()
                                if (userLoanFundQuery.docs.length === 1) {
                                    const goalDoc: DocumentSnapshot = userLoanFundQuery.docs[0]
                                    const goalDocRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(goalDoc.id)
                                    const transactRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('transactions').doc(transactionCode)
                                    db.runTransaction(async transaction => {
                                        transaction.update(goalDocRef, {goalAmountSaved: superadmin.firestore.FieldValue.increment(transactionAmount)})
                                        console.log('transactions collection update begin')
                                        transaction.set(transactRef, {
                                            'transactionAction': 'Deposit',
                                            'transactionAmount': transactionAmount,
                                            'transactionDate': superadmin.firestore.Timestamp.now(),
                                            'transactionCategory': 'Loan Fund',
                                            'transactionGoal': goal,
                                            'transactionCode': transactionCode
                                        })
                                        console.log('transactions collection update end')
                                    })
                                    .then(result => {
                                        console.log(`Loan Fund goal update success`)
                                    })
                                    .catch(err => {
                                        console.log(`Loan Fund goal update failure:`, err)
                                    })
                                }
                            }
                            else if (goal === 'Saving') {
                                const userSavingQuery: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid).collection('goals')
                                    .where('goalCategory','==','Saving')
                                    .limit(1)
                                    .get()
                                if (userSavingQuery.docs.length >= 1) {
                                    const goalDoc: DocumentSnapshot = userSavingQuery.docs[0]
                                    const goalDocRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(goalDoc.id)
                                    const transactRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('transactions').doc(transactionCode)
                                    db.runTransaction(async transaction => {
                                        transaction.update(goalDocRef, {goalAmountSaved: superadmin.firestore.FieldValue.increment(transactionAmount)})
                                        console.log('transactions collection update begin')
                                        transaction.set(transactRef, {
                                            'transactionAction': 'Deposit',
                                            'transactionAmount': transactionAmount,
                                            'transactionDate': superadmin.firestore.Timestamp.now(),
                                            'transactionCategory': 'Saving',
                                            'transactionGoal': goal,
                                            'transactionCode': transactionCode
                                        })
                                        console.log('transactions collection update end')
                                    })
                                    .then(result => {
                                        console.log(`Loan Fund goal update success`)
                                    })
                                    .catch(err => {
                                        console.log(`Loan Fund goal update failure:`, err)
                                    })
                                }
                            }
                            else {
                                const userInvestQuery: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid).collection('goals')
                                    .where('goalName','==',goal)
                                    .limit(1)
                                    .get()
                                if (userInvestQuery.docs.length >= 1) {
                                    const goalDoc: DocumentSnapshot = userInvestQuery.docs[0]
                                    const goalDocRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(goalDoc.id)
                                    const transactRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('transactions').doc(transactionCode)
                                    db.runTransaction(async transaction => {
                                        transaction.update(goalDocRef, {goalAmountSaved: superadmin.firestore.FieldValue.increment(transactionAmount)})
                                        console.log('transactions collection update begin')
                                        transaction.set(transactRef, {
                                            'transactionAction': 'Deposit',
                                            'transactionAmount': transactionAmount,
                                            'transactionDate': superadmin.firestore.Timestamp.now(),
                                            'transactionCategory': 'Investment',
                                            'transactionGoal': goal,
                                            'transactionCode': transactionCode
                                        })
                                        console.log('transactions collection update end')
                                    })
                                    .then(result => {
                                        console.log(`${goal} update success`)
                                    })
                                    .catch(err => {
                                        console.log(`${goal} update failure:`, err)
                                    })
                                }
                                
                            }
                        } 
                            
                        await db.collection('deposits').doc(uid).delete()
                    }
                })
                .catch((error) => {
                    console.error(error)
                })
        }

        //Send a Response back to Safaricom
        const message = {
            "ResponseCode": "00000000",
	        "ResponseDesc": "success"
        }
        response.json(message)
    } catch (error) {
        console.error(error)
    }
}
