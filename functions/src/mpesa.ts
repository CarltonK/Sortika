import { Request, Response } from "express";
import * as superadmin from 'firebase-admin'
import { DocumentSnapshot } from "firebase-functions/lib/providers/firestore";


export function mpesaLnmCallbackForCapture(request: Request, response: Response) {
    try {
        console.log('---Received Safaricom M-PESA Webhook For Capture---')
        const serverRequest = request.body
        //console.log(`Incoming Request: ${serverRequest}`)
        //Get the response code
        const code: number = serverRequest['Body']['stkCallback']['ResultCode']
        //console.log(`Incoming Request Code: ${code}`)
        if (code === 0) {
            const transactionAmount: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][0]['Value']
            const transactionCode: string = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][1]['Value']
            const transactionTime: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][3]['Value']
            const transactionPhone: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][4]['Value']

            let transactionPhoneFormatted: string = transactionPhone.toString().slice(3)
            transactionPhoneFormatted = "0" + transactionPhoneFormatted

            const db = superadmin.firestore()
            db.collection('users').where('phone' ,'==', transactionPhoneFormatted).limit(1).get()
                .then(async (value) => {
                    if (value.docs.length === 1) {

                        const document: DocumentSnapshot = value.docs[0]
                        const uid: string = document.get('uid')

                        console.log(`transaction ${transactionCode} document create begin`)
                        await db.collection('transactions').doc(transactionCode).set({
                            'transactionAmount': transactionAmount,
                            'transactionCode': transactionCode,
                            'transactionTime': transactionTime,
                            'transactionPhone': transactionPhone,
                            'transactionAction': 'Passive',
                            'transactionCategory': 'General',
                            'transactionUid': uid
                        })
                        console.log(`transaction ${transactionCode} document create end`)

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
                            db.runTransaction(async transaction => {
                                return transaction.get(docRef)
                                    .then(doc => {
                                        if (doc.get('goalAllocation') === Number.isNaN) {
                                            console.error('goalAllocation is NaN')
                                        }
                                        const newIncrement: number = (transactionAmount * doc.get('goalAllocation')) / 100
                                        transaction.update(docRef, {goalAmountSaved: superadmin.firestore.FieldValue.increment(newIncrement)})
                                    })
                            })
                            .then(async result => {
                                //Create a notification for the user
                                await db.collection('users').doc(uid).collection('notifications').doc().set({
                                    'message': `You have distributed ${transactionAmount} KES based on the goal allocations of each goal`,
                                    'time': superadmin.firestore.Timestamp.now()
                                })
                                console.log('General update success!')
                                console.log('notification update success')
                            })
                            .catch(err => {
                                console.log('General update failure:', err)
                            })
                        })
                    }
                })
                .catch(error => {
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

export function mpesaLnmCallback(request: Request, response: Response) {
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

            console.log(`Amount: ${transactionAmount}`)
            console.log(`Code: ${transactionCode}`)
            console.log(`Time: ${transactionTime}`)
            console.log(`Phone: ${transactionPhone}`)

            let transactionPhoneFormatted: string = transactionPhone.toString().slice(3)
            transactionPhoneFormatted = "0" + transactionPhoneFormatted

            // console.log(transactionPhoneFormatted)

            const db = superadmin.firestore()
            //Search for user with matching phone number
            db.collection('users').where('phone' ,'==', transactionPhoneFormatted).limit(1).get()
                .then(async (value) => {
                    if (value.docs.length === 1) {

                        const document: DocumentSnapshot = value.docs[0]
                        const uid: string = document.get('uid')

                        //Check deposit => FieldValue = destination
                        const depositSnapshot: FirebaseFirestore.QuerySnapshot = await db.collection('deposits').where('uid','==',uid).orderBy('time', 'desc').limit(1).get()
                        const depositDocument = depositSnapshot.docs[0]
                        const destination: string = depositDocument.get('destination')
                        const goal: string = depositDocument.get('goalName')


                        if (destination === 'wallet') {
                            //Update transaction document, id - transaction code
                            console.log(`transaction ${transactionCode} document create begin`)
                            await db.collection('transactions').doc(transactionCode).set({
                                'transactionAmount': transactionAmount,
                                'transactionCode': transactionCode,
                                'transactionTime': transactionTime,
                                'transactionPhone': transactionPhone,
                                'transactionAction': 'Deposit',
                                'transactionCategory': 'Wallet',
                                'transactionUid': uid
                            })
                            console.log(`transaction ${transactionCode} document create end`)

                            //Transaction operation to update wallet
                            const docRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('wallet').doc(uid)
                            db.runTransaction(async transaction => {
                                return transaction.get(docRef)
                                    .then(doc => {
                                        console.log(`Wallet update begin for user: ${uid}`)
                                        transaction.update(docRef, {amount: superadmin.firestore.FieldValue.increment(transactionAmount)})
                                        console.log(`Wallet update end for user: ${uid}`)
                                    });
                            })
                            .then(async result => {
                                //Create a notification for the user
                                console.log('notification update begin')
                                await db.collection('users').doc(uid).collection('notifications').doc().set({
                                    'message': `We have received your deposit of ${transactionAmount} KES`,
                                    'time': superadmin.firestore.Timestamp.now()
                                })
                                console.log('notification update end')

                                console.log('Overall wallet update process ended')
                            })
                            .catch(err => {
                                console.log('Wallet update failure:', err)
                            })
                        }
                        if (destination === 'general') {

                            //Update transaction document, id - transaction code
                            console.log(`transaction ${transactionCode} document create begin`)
                            await db.collection('transactions').doc(transactionCode).set({
                                'transactionAmount': transactionAmount,
                                'transactionCode': transactionCode,
                                'transactionTime': transactionTime,
                                'transactionPhone': transactionPhone,
                                'transactionAction': 'Deposit',
                                'transactionCategory': 'General',
                                'transactionUid': uid
                            })
                            console.log(`transaction ${transactionCode} document create end`)


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
                                db.runTransaction(async transaction => {
                                    return transaction.get(docRef)
                                        .then(doc => {
                                            const newIncrement: number = (transactionAmount * doc.get('goalAllocation')) / 100
                                            transaction.update(docRef, {goalAmountSaved: superadmin.firestore.FieldValue.increment(newIncrement)})
                                        })
                                })
                                .then(async result => {
                                    //Create a notification for the user
                                    console.log('notification update begin')
                                    await db.collection('users').doc(uid).collection('notifications').doc().set({
                                        'message': `You have distributed ${transactionAmount} KES based on the goal allocations of each goal`,
                                        'time': superadmin.firestore.Timestamp.now()
                                    })
                                    console.log('notification update end')

                                    console.log('Overal  General update success!')
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

                                    console.log('transactions collection create begin')
                                    await db.collection('transactions').doc(transactionCode).set({
                                            'transactionAction': 'Deposit',
                                            'transactionAmount': transactionAmount,
                                            'transactionTime': transactionTime,
                                            'transactionPhone': transactionPhone,
                                            'transactionCategory': 'Loan Fund',
                                            'transactionGoal': goal,
                                            'transactionCode': transactionCode,
                                            'transactionUid': uid
                                    })
                                    console.log('transactions collection create end')

                                    const goalDoc: DocumentSnapshot = userLoanFundQuery.docs[0]
                                    const goalDocRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(goalDoc.id)
                                    
                                    db.runTransaction(async transaction => {
                                        transaction.update(goalDocRef, {goalAmountSaved: superadmin.firestore.FieldValue.increment(transactionAmount)})
                                    })
                                    .then(async result => {
                                        console.log('notification update begin')
                                        await db.collection('users').doc(uid).collection('notifications').doc().set({
                                            'message': `We have captured a Loan Fund Goal deposit of ${transactionAmount} KES`,
                                            'time': superadmin.firestore.Timestamp.now()
                                        })
                                        console.log('notification update end')

                                        console.log('Overall Loan Fund goal update success')
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

                                    console.log('transactions collection create begin')
                                    await db.collection('transactions').doc(transactionCode).set({
                                            'transactionAction': 'Deposit',
                                            'transactionAmount': transactionAmount,
                                            'transactionTime': transactionTime,
                                            'transactionPhone': transactionPhone,
                                            'transactionCategory': 'Saving',
                                            'transactionGoal': goal,
                                            'transactionCode': transactionCode,
                                            'transactionUid': uid
                                    })
                                    console.log('transactions collection create end')

                                    const goalDoc: DocumentSnapshot = userSavingQuery.docs[0]
                                    const goalDocRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(goalDoc.id)
                                    db.runTransaction(async transaction => {
                                        transaction.update(goalDocRef, {goalAmountSaved: superadmin.firestore.FieldValue.increment(transactionAmount)})
                                    })
                                    .then(async result => {
                                        console.log('notification update begin')
                                        await db.collection('users').doc(uid).collection('notifications').doc().set({
                                            'message': `We have captured a Savings Goal deposit of ${transactionAmount} KES`,
                                            'time': superadmin.firestore.Timestamp.now()
                                        })
                                        console.log('notification update end')
                                        
                                        console.log('Overall Savings goal update success')
                                    })
                                    .catch(err => {
                                        console.log(`savings goal update failure:`, err)
                                    })
                                }
                            }
                            else {
                                const userInvestQuery: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid).collection('goals')
                                    .where('goalName','==',goal)
                                    .limit(1)
                                    .get()
                                if (userInvestQuery.docs.length === 1) {
                                    const category: string = userInvestQuery.docs[0].get('goalCategory')


                                    console.log('transactions collection create begin')
                                    await db.collection('transactions').doc(transactionCode).set({
                                            'transactionAction': 'Deposit',
                                            'transactionAmount': transactionAmount,
                                            'transactionTime': transactionTime,
                                            'transactionPhone': transactionPhone,
                                            'transactionCategory': category,
                                            'transactionGoal': goal,
                                            'transactionUid': uid,
                                            'transactionCode': transactionCode
                                    })
                                    console.log('transactions collection create end')

                                    const goalDoc: DocumentSnapshot = userInvestQuery.docs[0]
                                    const goalDocRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(goalDoc.id)
                                    db.runTransaction(async transaction => {
                                        transaction.update(goalDocRef, {goalAmountSaved: superadmin.firestore.FieldValue.increment(transactionAmount)})
                                    })
                                    .then(async result => {
                                        await db.collection('users').doc(uid).collection('notifications').doc().set({
                                            'message': `We have captured a deposit of ${transactionAmount} KES for your goal titled ${goal}`,
                                            'time': superadmin.firestore.Timestamp.now()
                                        })
                                        console.log('notification update success')
                                        console.log(`${goal} update success`)
                                    })
                                    .catch(err => {
                                        console.log(`${goal} update failure:`, err)
                                    })
                                }
                                
                            }
                        } 
                            
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

export function mpesaB2cTimeout(request: Request, response: Response) {
    console.log('---Received Safaricom M-PESA Webhook For B2C Timeout---')
    console.log(`---B2C Timeout---\n${request.body}`)
}

export function mpesaB2cResult(request: Request, response: Response) {
    console.log('---Received Safaricom M-PESA Webhook For B2C---')
    console.log(`---B2C Result---\n${request.body['Result']['ResultCode']}`)
    console.log(`---B2C Result---\n${request.body['Result']['ResultDesc']}`)
}
