import { Request, Response } from "express"
import * as superadmin from 'firebase-admin'
import { DocumentSnapshot } from "firebase-functions/lib/providers/firestore"
import * as notification from './notification'


export function mpesaLnmCallbackForCapture(request: Request, response: Response) {
    try {
        console.log('---Received Safaricom M-PESA Webhook For Capture---')
        const serverRequest = request.body
        //console.log(`Incoming Request: ${serverRequest}`)
        //Get the response code
        const code: number = serverRequest['Body']['stkCallback']['ResultCode']
        //console.log(`Incoming Request Code: ${code}`)
        if (code === 0) {
            let transactionAmount: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][0]['Value']
            const transactionCode: string = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][1]['Value']
            const transactionTime: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][3]['Value']
            const transactionPhone: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][4]['Value']

            let transactionPhoneFormatted: string = transactionPhone.toString().slice(3)
            transactionPhoneFormatted = "0" + transactionPhoneFormatted

            const sortikaAmount: number = transactionAmount * 0.05
            transactionAmount = transactionAmount * 0.95

            let uid: string

            const db = superadmin.firestore()
            db.collection('users').where('phone' ,'==', transactionPhoneFormatted).limit(1).get()
                .then(async (value) => {

                    if (value.docs.length === 1) {

                        const document: DocumentSnapshot = value.docs[0]
                        uid = document.get('uid')

                        await db.collection('private').doc('LhKYJC32tQHAf8qrnGSn').collection('transactions').doc().set({
                            type: 'Deposit',
                            amount: sortikaAmount,
                            uid: uid,
                            time: superadmin.firestore.Timestamp.now()
                        })
                        console.log(`Sortika has earned ${sortikaAmount} KES from Deposit of ${uid}`)

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
                            .then(result => {
                                console.log('General update success!')
                                console.log('notification update success')
                            })
                            .catch(err => {
                                console.log('General update failure:', err)
                            })
                        })
                    }
                    //Create a notification for the user
                    await db.collection('users').doc(uid).collection('notifications').doc().set({
                        'message': `You have distributed ${transactionAmount} KES based on the goal allocations of each goal`,
                        'time': superadmin.firestore.Timestamp.now()
                    })
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
            let transactionAmount: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][0]['Value']
            const transactionCode: string = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][1]['Value']
            const transactionTime: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][3]['Value']
            const transactionPhone: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][4]['Value']

            console.log(`Amount: ${transactionAmount}`)
            console.log(`Code: ${transactionCode}`)
            console.log(`Time: ${transactionTime}`)
            console.log(`Phone: ${transactionPhone}`)

            let transactionPhoneFormatted: string = transactionPhone.toString().slice(3)
            transactionPhoneFormatted = "0" + transactionPhoneFormatted

            const sortikaAmount: number = transactionAmount * 0.07

            console.log(transactionPhoneFormatted)
            let uid: string

            const db = superadmin.firestore()
            //Search for user with matching phone number
            db.collection('users').where('phone' ,'==', transactionPhoneFormatted).limit(1).get()
                .then(async (value) => {
                    if (value.docs.length === 1) {

                        const document: DocumentSnapshot = value.docs[0]
                        uid = document.get('uid')

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

                            await db.collection('private').doc('LhKYJC32tQHAf8qrnGSn').collection('transactions').doc().set({
                                type: 'Deposit',
                                amount: sortikaAmount,
                                uid: uid,
                                time: superadmin.firestore.Timestamp.now()
                            })
                            console.log(`Sortika has earned ${sortikaAmount} KES from Deposit of ${uid}`)

                            transactionAmount = transactionAmount * 0.93

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
                                    // console.log('notification update begin')
                                    // console.log('notification update end')

                                    console.log('Overal  General update success!')
                                })
                                .catch(err => {
                                    console.log('General update failure:', err)
                                })
                            })
                            await db.collection('users').doc(uid).collection('notifications').doc().set({
                                'message': `You have distributed ${transactionAmount} KES based on the goal allocations of each goal`,
                                'time': superadmin.firestore.Timestamp.now()
                            })
                        }
                        if (destination === 'specific' && goal !== null) {
                            console.log(`Deposit to specific goal: ${goal}`)

                            await db.collection('private').doc('LhKYJC32tQHAf8qrnGSn').collection('transactions').doc().set({
                                type: 'Deposit',
                                amount: sortikaAmount,
                                uid: uid,
                                time: superadmin.firestore.Timestamp.now()
                            })
                            console.log(`Sortika has earned ${sortikaAmount} KES from Deposit of ${uid}`)

                            transactionAmount = transactionAmount * 0.93
                            
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

export function mpesaB2cResult(request: Request, response: Response) {
    try {
        console.log('---Received Safaricom M-PESA Webhook For B2C---')
        const serverRequest = request.body
        console.log(serverRequest)
        const code: number = serverRequest['Result']['ResultCode']
        console.log(`B2C Result Code -> ${code}`)
        if (code === 0) {
            const transactionCode: string = serverRequest['Result']['TransactionID']
            let transactionAmount: number = 0
            let transactionTime: string = ''
            let transactionUser: string = ''
            // console.log(transactionCode)
            const params: any[] = serverRequest['Result']['ResultParameters']['ResultParameter']
            params.forEach(singleParam => {
                console.log(singleParam)
                if (singleParam['Key'] === 'TransactionAmount') {
                    transactionAmount = singleParam['Value']
                }
                if (singleParam['Key'] === 'ReceiverPartyPublicName') {
                    transactionUser = singleParam['Value']
                }
                if (singleParam['Key'] === 'TransactionCompletedDateTime') {
                    transactionTime = singleParam['Value']
                }
            })

            const phoneNumSecStr: string = transactionUser.split(' - ')[0]
            console.log(`Phone -> ${phoneNumSecStr}`)
            const transactionPhone: string = (phoneNumSecStr.startsWith('0')) ? phoneNumSecStr : ('0' + phoneNumSecStr.slice(3))
            console.log(`Phone Transformed -> ${transactionPhone}`)

            //Modify time to match string in transactions
            const transactionTimeDate: string = transactionTime.split(' ')[0]
            const transactionTimeTime: string = transactionTime.split(' ')[1]

            const transactionTimeDateSplit = transactionTimeDate.split('.')
            const transactionTimeTimeSplit = transactionTimeTime.split(':')

            let transactionTimeString: string = ''
            transactionTimeString += transactionTimeDateSplit[2]
            transactionTimeString += transactionTimeDateSplit[1]
            transactionTimeString += transactionTimeDateSplit[0]
            transactionTimeString += transactionTimeTimeSplit[0]
            transactionTimeString += transactionTimeTimeSplit[1]
            transactionTimeString += transactionTimeTimeSplit[2]

            const transactionTimeNumber: number = Number(transactionTimeString)

            // console.log(`Transaction amount ${transactionAmount}`)
            // console.log(`Transaction time ${transactionTime}`)
            // console.log(`Transaction phone ${transactionPhone}`)

            let uid: string
            let token: string

            const db = superadmin.firestore()

            //Check if a user with the phone exists
            db.collection('users').where('phone','==',transactionPhone).limit(1).get()
                .then((userQuerySnap: superadmin.firestore.QuerySnapshot) => {
                    const userDocs: DocumentSnapshot[] = userQuerySnap.docs
                    //Only one result should be found
                    if (userDocs.length === 1) {
                        const userDoc: DocumentSnapshot = userDocs[0]
                        uid = userDoc.get('uid')
                        token = userDoc.get('token')

                        const walletRef: superadmin.firestore.DocumentReference = db.collection('users').doc(uid).collection('wallet').doc(uid)
                        db.runTransaction(async walletTrans => {
                            return walletTrans.get(walletRef)
                                .then(async walletTransValue => {
                                    const walletAmt: number = walletTransValue.get('amount')
                                    const totalWithdrawAmount: number = (transactionAmount < 1000) ? transactionAmount + 40 : transactionAmount + 79
                                    if (walletAmt >= totalWithdrawAmount) {
                                        walletTrans.update(walletRef, {amount: superadmin.firestore.FieldValue.increment(-totalWithdrawAmount)})
                                        console.log(`Updating the wallet of ${uid} after a withdrawal transaction`)

                                        //Send notifications
                                        const tokens: string[] = [token]
                                        await notification.singleNotificationSend(tokens,`Your withdrawal request was successful.`,`Umesortika`)
                                        await db.collection('users').doc(uid).collection('notifications').doc().set({
                                            'message': `Your withdrawal request was successful.`,
                                            'time': superadmin.firestore.FieldValue.serverTimestamp()
                                        })
                                        
                                        //Create a transaction
                                        await db.collection('transactions').doc(transactionCode).set({
                                            'transactionAction': 'Withdrawal',
                                            'transactionCategory': 'Wallet',
                                            'transactionCode': transactionCode,
                                            'transactionAmount': transactionAmount,
                                            'transactionPhone': phoneNumSecStr,
                                            'transactionUid': uid,
                                            'transactionTime': transactionTimeNumber
                                        })

                                        //Delete the relevant withdrawals document
                                        await db.collection('withdrawals').doc(uid).delete()
                                    }
                                })
                                .catch(error => console.error(`There was an error updating the wallet of ${uid}`))
                        })
                        .then(value => console.log('Wallet credit transaction has completed'))
                        .catch(error => console.error(`wallet credit transaction error`,error))
                    }
                })
                .catch(error => console.error('There was an error retrieveing user',error))
        }
        const message = {
            "ResponseCode": "00000000",
	        "ResponseDesc": "success"
        }
        response.json(message) 
    } catch (error) {
        console.error('There was an error in mpesaB2cResult',error)
    }
}

export function mpesaB2cTimeout(request: Request, response: Response) {
    try {
        console.log('---Received Safaricom M-PESA Webhook For B2C Timeout---')
        console.log(`---B2C Timeout---\n${request.body}`)
        const message = {
            "ResponseCode": "00000000",
	        "ResponseDesc": "success"
        }
        response.json(message)
    } catch (error) {
        console.error('There was an error in mpesaB2cTimeout',error)
    }
}

export function mpesaC2bValidation(request: Request, response: Response) {
    try {
        console.log('---Received Safaricom M-PESA Webhook For C2B Validation---')
        console.log(`---C2B Validation---\n${request.body}`)
        const message = {
            "ResultCode": 0,
            "ResultDesc": "Accepted"
        }
        response.json(message)
    } catch (error) {
        console.error('There was an error in mpesaC2bValidation',error)
    }
}


interface MpesaResponse {
    TransactionType:   string;
    TransID:           string;
    TransTime:         string;
    TransAmount:       string;
    BusinessShortCode: string;
    BillRefNumber:     string;
    InvoiceNumber:     string;
    OrgAccountBalance: string;
    ThirdPartyTransID: string;
    MSISDN:            string;
    FirstName:         string;
    MiddleName:        string;
    LastName:          string;
}

export function mpesaC2bConfirmation(request: Request, response: Response) {
    try {
        console.log('---Received Safaricom M-PESA Webhook For C2B Confirmation---')
        const mpesaResp: MpesaResponse = request.body

        let transactionPhoneFormatted: string = mpesaResp.MSISDN.slice(3)
        transactionPhoneFormatted = "0" + transactionPhoneFormatted

        const transactionAmtString: string = mpesaResp.TransAmount.split('.')[0]
        let transactionAmount: number = Number(transactionAmtString)

        const sortikaAmount: number = transactionAmount * 0.05

        const transTime: number = Number(mpesaResp.TransTime)


        console.log('Phone',transactionPhoneFormatted)
        console.log('Ref',mpesaResp.BillRefNumber)

        const db = superadmin.firestore()

        db.collection('users').where('phone','==',transactionPhoneFormatted).limit(1).get()
            .then(async (userValue: FirebaseFirestore.QuerySnapshot) => {
                const userDocs: DocumentSnapshot[] = userValue.docs
                if (userDocs.length === 1) {
                    const userDocument: DocumentSnapshot = userDocs[0]
                    const uid: string = userDocument.get('uid')
                    const token: string = userDocument.get('token')
                    const tokenList: string[] = [token]

                    if (mpesaResp.BillRefNumber.toLowerCase() === 'srtkwallet' || mpesaResp.BillRefNumber.toLowerCase().includes('wallet')) {
                        //Update transaction document, id - transaction code
                        await db.collection('transactions').doc(mpesaResp.TransID).set({
                            'transactionAmount': transactionAmount,
                            'transactionCode': mpesaResp.TransID,
                            'transactionTime': transTime,
                            'transactionAction': 'Deposit',
                            'transactionCategory': 'Wallet',
                            'transactionUid': uid
                        })

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
                            await notification.singleNotificationSend(tokenList,`We have received your deposit of ${transactionAmount} KES`,'Good News')
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
                    if (mpesaResp.BillRefNumber.toLowerCase() === 'srtkgeneral' || mpesaResp.BillRefNumber.toLowerCase().includes('general')) {

                        await db.collection('private').doc('LhKYJC32tQHAf8qrnGSn').update({
                            amount: superadmin.firestore.FieldValue.increment(sortikaAmount)
                        })

                        await db.collection('private').doc('LhKYJC32tQHAf8qrnGSn').collection('transactions').doc().set({
                            type: 'Deposit',
                            amount: sortikaAmount,
                            uid: uid
                        })
                        console.log(`Sortika has earned ${sortikaAmount} KES from Deposit of ${uid}`)

                        transactionAmount = transactionAmount * 0.95

                        //Update transaction document, id - transaction code
                        await db.collection('transactions').doc(mpesaResp.TransID).set({
                            'transactionAmount': transactionAmount,
                            'transactionCode': mpesaResp.TransID,
                            'transactionTime': transTime,
                            'transactionAction': 'Deposit',
                            'transactionCategory': 'General',
                            'transactionUid': uid
                        })


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
                                console.log('Overal  General update success!')
                            })
                            .catch(err => {
                                console.log('General update failure:', err)
                            })
                        })
                        await notification.singleNotificationSend(tokenList,`You have distributed ${transactionAmount} KES based on the goal allocations of each goal`,'Good News')
                        await db.collection('users').doc(uid).collection('notifications').doc().set({
                            'message': `You have distributed ${transactionAmount} KES based on the goal allocations of each goal`,
                            'time': superadmin.firestore.Timestamp.now()
                        })

                    }
                    if (mpesaResp.BillRefNumber.toLowerCase().includes('wallet') && mpesaResp.BillRefNumber.toLowerCase().includes('general')) {
                        await notification.singleNotificationSend(tokenList,'Please enter one of the account numbers provided','Error')
                        await db.collection('users').doc(uid).collection('notifications').doc().set({
                            'message': 'Please enter one of the account numbers provided',
                            'time': superadmin.firestore.Timestamp.now()
                        })
                    }
                    // else {

                    //     await db.collection('private').doc('LhKYJC32tQHAf8qrnGSn').update({
                    //         amount: superadmin.firestore.FieldValue.increment(sortikaAmount)
                    //     })

                    //     await db.collection('private').doc('LhKYJC32tQHAf8qrnGSn').collection('transactions').doc().set({
                    //         type: 'Deposit',
                    //         amount: sortikaAmount,
                    //         uid: uid
                    //     })
                    //     console.log(`Sortika has earned ${sortikaAmount} KES from Deposit of ${uid}`)

                    //     transactionAmount = transactionAmount * 0.95

                    //     const userGoalQuery: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid).collection('goals')
                    //         .where('goalType','in',[mpesaResp.BillRefNumber.toLowerCase(),mpesaResp.BillRefNumber.toUpperCase(),mpesaResp.BillRefNumber]).limit(1).get()
                    //     const userGoalDocs: DocumentSnapshot[] = userGoalQuery.docs
                    //     console.log(`This is the number of goals we have retrieved ${userGoalDocs.length} under B2C transaction for ${uid}`)
                    //     if (userGoalDocs.length === 1) {
                    //         const concernedDoc: DocumentSnapshot = userGoalDocs[0]
                    //         const concernedDocRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(concernedDoc.id)
                    //         db.runTransaction(async specificTrans => {
                    //             return specificTrans.get(concernedDocRef)
                    //                 .then(async docRetrieved => {
                    //                     specificTrans.update(concernedDocRef, {goalAmountSaved: superadmin.firestore.FieldValue.increment(transactionAmount)})
                    //                     await notification.singleNotificationSend(tokenList,`You have deposited ${transactionAmount} KES to your ${concernedDoc.get('goalCategory')} goal`,'Good News')
                    //                     await db.collection('users').doc(uid).collection('notifications').doc().set({
                    //                         'message': `You have deposited ${transactionAmount} KES to your ${concernedDoc.get('goalCategory')} goal`,
                    //                         'time': superadmin.firestore.Timestamp.now()
                    //                     })
                                        
                    //                     const categ: string = docRetrieved.get('goalCategory')
                    //                     await db.collection('transactions').doc(mpesaResp.TransID).set({
                    //                         'transactionAmount': transactionAmount,
                    //                         'transactionCode': mpesaResp.TransID,
                    //                         'transactionTime': transTime,
                    //                         'transactionAction': 'Deposit',
                    //                         'transactionCategory': categ,
                    //                         'transactionUid': uid
                    //                     })
                    //                 })
                    //                 .catch(transError => console.error('B2C Specific Goal Update ERROR',transError))
                    //         })
                    //         .then(value => console.log('B2C Specific has completed successfully'))
                    //         .catch(errorVal => console.error('B2C Specific has failed',errorVal))

                    //     }
                    //     else {
                    //         await notification.singleNotificationSend(tokenList,`You used an ambiguous account number ${mpesaResp.BillRefNumber}. Please contact customer care`,'Warning')
                    //         await db.collection('users').doc(uid).collection('notifications').doc().set({
                    //             'message': `You used an ambiguous account number ${mpesaResp.BillRefNumber}. Please contact customer care`,
                    //             'time': superadmin.firestore.Timestamp.now()
                    //         })
                    //     }
                    // }
                }
            })
            .catch(userError => console.error('There was an error fetching the user',userError)) 

        const message = {
            "ResultCode": 0,
            "ResultDesc": "Accepted"
        }
        response.json(message)
    } catch (error) {
        console.error('There was an error in mpesaC2bConfirmation',error)
    }
}

