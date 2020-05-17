import * as functions from 'firebase-functions'
import * as superadmin from 'firebase-admin'
//import * as express from 'express'
//import * as bodyParser from "body-parser"
import { DocumentSnapshot } from 'firebase-functions/lib/providers/firestore'
//import * as auth from './authentication'

// //Initialize Express Server
// const app = express()
// const main = express()

// /*
// SERVER CONFIGURATION
// 1) Base Path
// 2) Set JSON as main parser
// */
// main.use('/api/v1', app)
// main.use(bodyParser.json())

// /*
// API
// */
// //Registration
// export const sortikaMain = functions.https.onRequest(main)
// app.post('/users', auth.createUser)

/*
DATABASE
Version 1: onCreate
Version 2: onDelete

* use onWrite for debugging purposes *
*/
//Calculate goal allocations
superadmin.initializeApp();
const db = superadmin.firestore();
const fcm = superadmin.messaging() 


exports.allocationsCalculatorV1 = functions.firestore
    .document('/users/{user}/goals/{goal}')
    .onCreate(async snapshot => {
        //Retrieve user id
        const uid = snapshot.get('uid')
        const docs = await db.collection('users').doc(uid).collection('goals').get()
        const allDocs: Array<DocumentSnapshot> = docs.docs
        const periods: Array<number> = []
        const amounts: Array<number> = []
        const adjustedAmounts: Array<number> = []
        const documentIds: Array<string> = []
        const allocationpercents: Array<number> = []
        allDocs.forEach(element => {
            //Document Snapshot
            /*
            Timestamp is returned from Firebase.
            Convert to Date then get differences in days
            */
            const timeStart: FirebaseFirestore.Timestamp = element.get('goalCreateDate')
            const dateStart: Date = timeStart.toDate()

            const timeEnd: FirebaseFirestore.Timestamp = element.get('goalEndDate')
            const dateEnd = timeEnd.toDate()

            const differenceSeconds = dateEnd.getTime() - dateStart.getTime()
            const differenceDays = differenceSeconds / (1000*60*60*24)

            //Save the difference in a list
            periods.push(Math.floor(differenceDays))
            //Retrieve target amount and save in amounts
            amounts.push(element.get('goalAmount'))
            documentIds.push(element.id)
        });
        //Sort from smallest to largest
        periods.sort()
        const leastDays = periods[0]
        //Show arrays
        console.log(`Periods: ${periods}`)
        console.log(`Amounts: ${amounts}`)
        console.log(`Document Ids: ${documentIds}`)
        //Keep a total adjusted amount counter
        let totalAdjusted: number = 0
        for (let index = 0; index < amounts.length; index ++) {
            let adjusted: number = ( (amounts[index] * leastDays) / periods[index] )
            adjustedAmounts.push(adjusted)
            totalAdjusted = totalAdjusted + adjusted
        }
        //Show adjusted amounts
        console.log(`Adjusted Amounts: ${adjustedAmounts}`)
        //Show the total adjusted number
        console.log(`Total Adjusted Value: ${totalAdjusted}`)
        //Get allocation percentages
        for (let index = 0; index < adjustedAmounts.length; index ++) {
            let percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
            allocationpercents.push(percent)
        }
        //Show percents
        console.log(`Allocation Percents: ${allocationpercents}`)
        //Update each document with new allocations
        for (let index = 0; index < documentIds.length; index ++) {
            let documentId: string = documentIds[index]
            let allocatedPercent: number = allocationpercents[index]
            await db.collection('users').doc(uid)
                .collection('goals').doc(documentId).update({'goalAllocation':allocatedPercent})
        }
        //Update User Targets
        const dailyTarget: number = (totalAdjusted / leastDays)
        const weeklyTarget: number = (dailyTarget * 7)
        const monthlyTarget: number = (dailyTarget * 30)
        //Update USERS Collection
        await db.collection('users').doc(uid).update({
            'dailyTarget': dailyTarget,
            'weeklyTarget': weeklyTarget,
            'monthlyTarget': monthlyTarget
        })
    })


exports.allocationsCalculatorV2 = functions.firestore
    .document('/users/{user}/goals/{goal}')
    .onDelete(async snapshot => {
        //Redistribute the goal amount
        const goalAmount: number = snapshot.get('goalAmount')
        //Retrieve user id
        const uid = snapshot.get('uid')
        if (snapshot.get('goalCategory') === 'Investment') {
            const investmentDocuments: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid).collection('goals')
                .where('goalCategory', '==', 'Investment').get()
            console.log(`How many investment goals? ${investmentDocuments.docs.length}`)
            const averageAmount: number = (goalAmount / investmentDocuments.docs.length)
            for (let index = 0; index < investmentDocuments.docs.length; index ++) {
                let currentAmount: number = investmentDocuments.docs[index].get('goalAmount')
                currentAmount = currentAmount + averageAmount
            
                let documentId: string = investmentDocuments.docs[index].id
                await db.collection('users').doc(uid)
                .collection('goals').doc(documentId).update({'goalAmount': currentAmount})
            }
        }
        if (snapshot.get('goalCategory') === 'Saving') {
            const lFDocuments: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid)
                .collection('goals').where('goalCategory', '==', 'Loan Fund').limit(1).get()
            lFDocuments.docs.forEach(async (element) => {
                // var amountCurrent = element.get('loanAmount')
                // amountCurrent = amountCurrent + goalAmount
                await db.collection('users').doc(uid)
                .collection('goals').doc(element.id).update({'goalAmount': superadmin.firestore.FieldValue.increment(goalAmount)})
            })
        }
        const docs = await db.collection('users').doc(uid).collection('goals').get()
        const allDocs: Array<DocumentSnapshot> = docs.docs
        const periods: Array<number> = []
        const amounts: Array<number> = []
        const adjustedAmounts: Array<number> = []
        const documentIds: Array<string> = []
        const allocationpercents: Array<number> = []
        allDocs.forEach(element => {
            //Document Snapshot
            /*
            Timestamp is returned from Firebase.
            Convert to Date then get differences in days
            */
            const timeStart: FirebaseFirestore.Timestamp = element.get('goalCreateDate')
            const dateStart: Date = timeStart.toDate()

            const timeEnd: FirebaseFirestore.Timestamp = element.get('goalEndDate')
            const dateEnd = timeEnd.toDate()

            const differenceSeconds = dateEnd.getTime() - dateStart.getTime()
            const differenceDays = differenceSeconds / (1000*60*60*24)

            //Save the difference in a list
            periods.push(Math.floor(differenceDays))
            //Retrieve target amount and save in amounts
            amounts.push(element.get('goalAmount'))
            documentIds.push(element.id)
        });
        //Sort from smallest to largest
        periods.sort()
        const leastDays = periods[0]
        //Show arrays
        console.log(`Periods: ${periods}`)
        console.log(`Amounts: ${amounts}`)
        console.log(`Document Ids: ${documentIds}`)
        //Keep a total adjusted amount counter
        var totalAdjusted: number = 0
        for (let index = 0; index < amounts.length; index ++) {
            let adjusted: number = ( (amounts[index] * leastDays) / periods[index] )
            adjustedAmounts.push(adjusted)
            totalAdjusted = totalAdjusted + adjusted
        }
        //Show adjusted amounts
        console.log(`Adjusted Amounts: ${adjustedAmounts}`)
        //Show the total adjusted number
        console.log(`Total Adjusted Value: ${totalAdjusted}`)
        //Get allocation percentages
        for (let index = 0; index < adjustedAmounts.length; index ++) {
            let percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
            allocationpercents.push(percent)
        }
        //Show percents
        console.log(`Allocation Percents: ${allocationpercents}`)
        //Update each document with new allocations
        for (let index = 0; index < documentIds.length; index ++) {
            let documentId: string = documentIds[index]
            let allocatedPercent: number = allocationpercents[index]
            await db.collection('users').doc(uid)
                .collection('goals').doc(documentId).update(
                    {'goalAllocation':allocatedPercent})
        }
        //Update User Targets
        const dailyTarget: number = (totalAdjusted / leastDays)
        const weeklyTarget: number = (dailyTarget * 7)
        const monthlyTarget: number = (dailyTarget * 30)
        //Update USERS Collection
        await db.collection('users').doc(uid).update({
            'dailyTarget': dailyTarget,
            'weeklyTarget': weeklyTarget,
            'monthlyTarget': monthlyTarget
        })
    })

/*
NOTIFICATIONS
1) Send notification to a Sortika user who has received a lend request
*/
export const promptLendRequest = functions.firestore
    .document('loans/{loan}')
    .onCreate(async snapshot => {
        const token: string = snapshot.get('tokenInvitee')
        const amount: number = snapshot.get('loanAmountTaken')
        const interest: number = snapshot.get('loanInterest')
        const invitees: string | Array<any> = snapshot.get('loanInvitees')
        //Retrieve the token (If exists)
        if (token != null) {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `Loan Request`,
                    body: `You have received a request for ${amount} KES at an interest rate of ${interest} %`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            if (typeof invitees === "string") {
                await db.collection('users').doc(invitees).collection('notifications').doc().set({
                    'message': `You have received a request for ${amount} KES at an interest rate of ${interest} %`,
                    'time': superadmin.firestore.FieldValue.serverTimestamp()
                })
            }
            else {
                invitees.forEach(async (element) => {
                    await db.collection('users').doc(element).collection('notifications').doc().set({
                        'message': `You have received a request for ${amount} KES at an interest rate of ${interest} %`,
                        'time': superadmin.firestore.FieldValue.serverTimestamp()
                    })
                })
            }
            //console.log(payload);
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptLendRequest FCM Error',error)
        })
        }
    })

export const ackBorrowRequest = functions.firestore
    .document('loans/{loan}')
    .onCreate(async snapshot => {
        //Retrieve the token (If exists)
        const token: string = snapshot.get('tokenBorrower')
        const amount: number = snapshot.get('loanAmountTaken')
        const interest: number = snapshot.get('loanInterest')
        const borrowerUid: string = snapshot.get('loanBorrower')

        if (token != null) {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `Wasn't that easy ?`,
                    body: `Your request for ${amount} KES at an interest rate of ${interest} % has been sent successfully`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            //Create a notification for the borrower
            //Store in notifications subcollection of user
            await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                'message': `Your request for ${amount} KES at an interest rate of ${interest} % has been sent successfully`,
                'time': superadmin.firestore.FieldValue.serverTimestamp()
            })
            //console.log(payload);
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptLendRequest FCM Error',error)
        })
        }
    })


export const promptLoanAccepted = functions.firestore
    .document('loans/{loan}')
    .onWrite(async snapshot => {
        const token: string = snapshot.after.get('tokenBorrower')
            const amount: number = snapshot.after.get('loanAmountTaken')
            const due: number = snapshot.after.get('totalAmountToPay')
            const borrowerUid: string = snapshot.after.get('loanBorrower')
            const time: FirebaseFirestore.Timestamp = snapshot.after.get('loanEndDate')
            const date: Date = time.toDate()
        //Retrieve the token (If exists)
        if (snapshot.before.get('loanStatus') === false && snapshot.after.get('loanStatus') === true) {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `Good News`,
                    body: `Your loan request of ${amount} KES has been accepted. You will payback ${due} KES. You have until ${date.toLocaleDateString()}`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            //Create a notification for the borrower
            //Store in notifications subcollection of user
            await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                'message': `Your loan request of ${amount} KES has been accepted. You will payback ${due} KES. You have until ${date.toLocaleDateString()}`,
                'time': superadmin.firestore.FieldValue.serverTimestamp()
            })
            console.log(payload);
            //Send to all tenants in the topic "landlord_code"
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptLoanAccepted FCM Error',error)
        })
        }
    })

export const promptAcceptLoan = functions.firestore
    .document('loans/{loan}')
    .onWrite(async snapshot => {
            const token: string = snapshot.after.get('loanLenderToken')
            const borrowerName: string = snapshot.after.get('borrowerName')
            const amount: number = snapshot.after.get('loanAmountTaken')
            const lenderUid: string = snapshot.after.get('loanLender')
        //Retrieve the token (If exists)
        if (snapshot.before.get('loanStatus') === false && snapshot.after.get('loanStatus') === true) {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `${borrowerName} amesortika`,
                    body: `We will deduct ${amount} KES from your wallet and send to ${borrowerName}`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            //Create a notification for the borrower
            //Store in notifications subcollection of user
            await db.collection('users').doc(lenderUid).collection('notifications').doc().set({
                'message': `We will deduct ${amount} KES from your wallet and send to ${borrowerName}`,
                'time': superadmin.firestore.FieldValue.serverTimestamp()
            })
            console.log(payload);
            //Send to all tenants in the topic "landlord_code"
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptAcceptLoan FCM Error',error)
        })
        }
    })

export const promptLoanRevision = functions.firestore
    .document('loans/{loan}')
    .onWrite(async snapshot => {
        const token: string = snapshot.before.get('tokenBorrower')
        const amount: number = snapshot.after.get('loanAmountTaken')
        const interest: number = snapshot.after.get('loanInterest')
        const due: number = snapshot.after.get('totalAmountToPay')
        const borrowerUid: string = snapshot.before.get('loanBorrower')
        //Retrieve the token (If exists)
        if (snapshot.before.get('loanStatus') === false && snapshot.after.get('loanStatus') === 'Revised') {
            //Retrieve key info
        
            //Define the payload
            const payload = {
                notification: {
                    title: `Loan Revision`,
                    body: `Your loan submission has been revised. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. You will pay back ${due} KES`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            console.log(payload);
             //Create a notification for the borrower
            //Store in notifications subcollection of user
            await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                'message': `Your loan submission has been revised. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. You will pay back ${due} KES`,
                'time': superadmin.firestore.FieldValue.serverTimestamp()
            })
            //Send to all tenants in the topic "landlord_code"
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptLoanRevised FCM Error',error)
            })
        }
    })

    
export const promptLoanNegotiation = functions.firestore
    .document('loans/{loan}')
    .onWrite(async snapshot => {
        const token: string = snapshot.before.get('tokenBorrower')
        const borrowerUid: string = snapshot.before.get('loanBorrower')
        //Retrieve the token (If exists)
        if (snapshot.before.get('loanStatus') === 'Revised' && snapshot.after.get('loanStatus') === 'Revised2') {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `Loan Revision`,
                    body: `You have sent a revised loan request submission`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        }
        console.log(payload);
         //Create a notification for the borrower
        //Store in notifications subcollection of user
        await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
            'message': `You have sent a revised loan request submission`,
            'time': superadmin.firestore.FieldValue.serverTimestamp()
        })
        //Send to all tenants in the topic "landlord_code"
        return fcm.sendToDevice(token, payload)
            .catch(error => {
            console.error('promptLoanRevised FCM Error',error)
        })
    }
})

export const promptReceiveNegotiation = functions.firestore
    .document('loans/{loan}')
    .onWrite(async snapshot => {
        const token: string = snapshot.before.get('tokenInvitee')
        const inviteeUid: string | Array<any> = snapshot.before.get('loanInvitees')
        const amount: number = snapshot.after.get('loanAmountTaken')
        const interest: number = snapshot.after.get('loanInterest')
        const due: number = snapshot.after.get('totalAmountToPay')
        //Retrieve the token (If exists)
        if (snapshot.before.get('loanStatus') === 'Revised' && snapshot.after.get('loanStatus') === 'Revised2') {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `Loan Revision`,
                    body: `You have received a revised loan request. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. They will pay back ${due} KES`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        }
        console.log(payload);
        if (typeof inviteeUid == "string") {
            await db.collection('users').doc(inviteeUid).collection('notifications').doc().set({
                'message': `You have received a revised loan request. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. They will pay back ${due} KES`,
                'time': superadmin.firestore.FieldValue.serverTimestamp()
            })
            //Send to all tenants in the topic "landlord_code"
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptLoanRevised FCM Error',error)
            }) 
        }
        else {
            inviteeUid.forEach(async (element) => {
                await db.collection('users').doc(element).collection('notifications').doc().set({
                    'message': `You have received a revised loan request. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. They will pay back ${due} KES`,
                    'time': superadmin.firestore.FieldValue.serverTimestamp()
                })                
            })
            return null;
        }
    }
})

export const promptSubmitLoanRevision = functions.firestore
    .document('loans/{loan}')
    .onWrite(async snapshot => {
        const token: string | Array<any> = snapshot.before.get('tokenInvitee')
        //Retrieve the token (If exists)
        if (snapshot.before.get('loanStatus') === false && snapshot.after.get('loanStatus') === 'Revised') {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `Loan Revision`,
                    body: `Your money, your terms`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            console.log(payload);
            if (typeof token === "string") {
                return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptLoanRevised FCM Error',error)
            })
            }
            else {
                return null;
            }
        }
    })



export const promptLoanRejected = functions.firestore
    .document('loans/{loan}')
    .onWrite(async snapshot => {
        const token: string = snapshot.before.get('tokenBorrower')
        const amount: number = snapshot.after.get('loanAmountTaken')
        const interest: number = snapshot.after.get('loanInterest')
        const borrowerUid: string = snapshot.before.get('loanBorrower')
        //Retrieve the token (If exists)
        if (snapshot.after.get('loanStatus') === 'Rejected') {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `Bad News`,
                    body: `Your loan request of ${amount} KES at ${interest} % has been rejected`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            console.log(payload)
            //Send a notification to a user
            //Update notifications subcollection for user
            await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
                'message': `Your loan request of ${amount} KES at ${interest} % has been rejected`,
                'time': superadmin.firestore.FieldValue.serverTimestamp()
            })
            //Delete the Document
            await db.collection('loans').doc(snapshot.after.id).delete()
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptLoanRejected FCM Error',error)
        })
        }
    })

export const promptRejectLoan = functions.firestore
    .document('loans/{loan}')
    .onWrite(async snapshot => {
        const token: string | Array<any> = snapshot.before.get('tokenInvitee')
        const amount: number = snapshot.after.get('loanAmountTaken')
        const interest: number = snapshot.after.get('loanInterest')
        const loanInvitee: string | Array<any> = snapshot.before.get('loanInvitees')
        //Retrieve the token (If exists)
        if (snapshot.after.get('loanStatus') === 'Rejected') {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `Don't accept less than you deserve`,
                    body: `You rejected a loan request of ${amount} KES at ${interest} %`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            console.log(payload)
            //Send a notification to a user
            //Update notifications subcollection for user
            if (typeof loanInvitee == "string") {
                await db.collection('users').doc(loanInvitee).collection('notifications').doc().set({
                    'message': `You rejected a loan request of ${amount} KES at ${interest} %`,
                    'time': superadmin.firestore.FieldValue.serverTimestamp()
                })
            }
            else {
                loanInvitee.forEach(async (element) => {
                    await db.collection('users').doc(element).collection('notifications').doc().set({
                        'message': `You rejected a loan request of ${amount} KES at ${interest} %`,
                        'time': superadmin.firestore.FieldValue.serverTimestamp()
                    })
                })
            }
            //Delete the Document
            await db.collection('loans').doc(snapshot.after.id).delete()
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptRejectLoan FCM Error',error)
        })
        }
    })

//Self Loan
export const selfLoan = functions.firestore
    .document('loans/{loan}')
    .onCreate(async snapshot => {
        const lender: string = snapshot.get('loanLender')
        const amount: number = snapshot.get('loanAmountTaken')
        const token: string = snapshot.get('loanLenderToken')
        if (lender != null) {
            //Check if user has enough amount in Loan Fund Goal
            await db.collection('users').doc(lender).collection('goals')
                .where('goalCategory', '==', 'Loan Fund')
                .limit(1)
                .get().then((queries) => {
                    queries.forEach(async (element) => {
                        const limit: number = element.get('goalAmountSaved')
                        if (amount > limit) {
                            await db.collection('loans').doc(snapshot.id).update({
                            'loanStatus': 'Rejected'
                            })
                            const payload = {
                                notification: {
                                    title: `Bad News`,
                                    body: `Insufficient funds in your Loan Fund Goal. Top up to get a higher loan limit`,
                                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                                }
                            }
                            return fcm.sendToDevice(token, payload)
                                .catch(error => {
                                    console.error('selfLoanReject FCM Error',error)
                                })
                        }
                        else {
                            await db.collection('loans').doc(snapshot.id).update({
                                'loanStatus': true
                            })
                            const payload = {
                                notification: {
                                    title: `Good News`,
                                    body: `You have successfully borrowed ${amount} KES from your loan Fund Goal`,
                                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                                }
                            }
                            return fcm.sendToDevice(token, payload)
                                .catch(error => {
                                    console.error('selfLoanReject FCM Error',error)
                                })
                        }
                    })
                })
        }
    })


export const goalAutoCreate = functions.firestore
    .document('autocreates/{autocreate}')
    .onCreate(async snapshot => {
        //Retrieve data from user
        const amount: number = snapshot.get('amount')
        const rate: string = snapshot.get('returnRate')
        const endDate: FirebaseFirestore.Timestamp = snapshot.get('endDate')
        const uid: string = snapshot.get('uid')
        const documentId: string = snapshot.id

        //Retrieve top collection documents
        const upperDocs = await db.collection('investments').get()
        const upperDocsArray: Array<DocumentSnapshot> = upperDocs.docs
        const chosenInvestments: Array<Map<any, any>> = []

        //Placeholder for the data we want
        const allInvestments: Array<FirebaseFirestore.DocumentData> = []
        //const allInvestmentDocIds: Array<string> = []
        //Iterate to get investment types in each
        for (let index = 0; index < upperDocsArray.length; index ++) {
            var currentDocId: string = upperDocsArray[index].get('title')
            const lowerDocs = await db.collection('investments').doc(currentDocId)
                .collection('types').get()
            const lowerDocsArray = lowerDocs.docs
            for (let i = 0; i < lowerDocsArray.length; i ++) {
                var map = new Map()
                map.set(`${currentDocId}`, lowerDocsArray[i].get('name'))
                if (rate == 'low') {
                    if (lowerDocsArray[i].get('return') < 10.5) {
                        chosenInvestments.push(map)
                    }
                } 
                if (rate == 'med') {
                    if (lowerDocsArray[i].get('return') < 18) {
                        chosenInvestments.push(map)
                    }
                }
                if (rate == 'high') {
                    if (lowerDocsArray[i].get('return') >= 18) {
                        chosenInvestments.push(map)
                    }
                }
                //allInvestmentDocIds.push(lowerDocsArray[i].id)
                allInvestments.push(lowerDocsArray[i].data())
            }
        }
        //console.log(`Document IDs: ${allInvestmentDocIds}`)
        //Calculate Deviation
        // This is based on user selected return rate
        var deviation: number
        const deviationList: Array<number> = []
        if (rate == 'low') {
            const staticFigure: number = 10.5
            //Cycle through the investments
            for (let index = 0; index < allInvestments.length; index ++) {
                deviation = staticFigure - allInvestments[index]['return']
                deviationList.push(deviation)
            }
        }
        else if (rate == 'med') {
            const staticFigure: number = 14.25
            //Cycle through the investments
            for (let index = 0; index < allInvestments.length; index ++) {
                deviation = staticFigure - allInvestments[index]['return']
                deviationList.push(deviation)
            }
        }
        else {
            const staticFigure: number = 18
            //Cycle through the investments
            for (let index = 0; index < allInvestments.length; index ++) {
                deviation = staticFigure - allInvestments[index]['return']
                deviationList.push(deviation)
            }
        }
        //console.log(deviationList)
        //Calculate the weights
        //This is given by deviation * 0.1
        const weightCalcs: Array<number> = []
        //Iterate through the list of deviations
        for (let index = 0; index < deviationList.length; index ++) {
            var weight: number = deviationList[index] * 0.1
            weightCalcs.push(weight)
        }
        //console.log(weightCalcs)
        //Calculate the risk level weight estimates
        //This is given by (1 - weight)
        const weightEstimates: Array<number> = []
        //Iterate through the list of weights
        for (let index = 0; index < weightCalcs.length; index ++) {
            var estimate = 1 - weightCalcs[index]
            weightEstimates.push(estimate)
        }
        console.log(`Weight Estimates: ${weightEstimates}`)
        //Calculate adjusted weight estimates
        //These are the weightEstimates that are below 1
        //Keep a running total of adjusted weight estimates
        var weightEstimatesTotal: number  = 0
        const adjustedWeightEstimates: Array<number> = []
        //Iterate through the weight estimates list
        for (let index = 0; index < weightEstimates.length; index ++) {
            //convert weight estimate to 0 if it is greater that 1 - Low and Medium
            //convert weight estimate to 0 if it is less than 1 - High
            if (rate == 'high') {
                if (weightEstimates[index] < 1) {
                    weightEstimates[index] = 0
                    //allInvestmentDocIds[index] = ''
                }
            }
            if (rate == 'low') {
                if (weightEstimates[index] > 1) {
                    weightEstimates[index] = 0
                    //allInvestmentDocIds[index] = ''
                }
            }
            if (rate == 'med') {
                if (weightEstimates[index] > 1) {
                    weightEstimates[index] = 0
                    //allInvestmentDocIds[index] = ''
                }
            }
            weightEstimatesTotal = weightEstimatesTotal + weightEstimates[index]
            adjustedWeightEstimates.push(weightEstimates[index])
        }
        //console.log(`Relevant Documents: ${allInvestmentDocIds}`)
        console.log(`Adjusted Weight Estimates: ${adjustedWeightEstimates}`)
        console.log(`Weight Estimates Total ${weightEstimatesTotal}`)
        //Calculate the actual weight
        //This is calculated by (adjustedWeight * (1/weightEstimatesTotal))
        const actualWeights: Array<number> = []
        for (let index = 0; index < adjustedWeightEstimates.length; index ++) {
            var weightActual = adjustedWeightEstimates[index] * (1/weightEstimatesTotal)
            actualWeights.push(weightActual)
        }
        console.log(`Actual Weights: ${actualWeights}`)
        //Calculate expected return
        //This is calculated by actual weight * asset return
        const expectedReturns: Array<number> = []
        //Keep a counter for total expected return
        var expectedReturnTotal = 0
        for (let index = 0; index < actualWeights.length; index ++) {
            var calculatedReturn = allInvestments[index]['return'] * actualWeights[index]
            expectedReturns.push(calculatedReturn)
            expectedReturnTotal = expectedReturnTotal + calculatedReturn
        }
        console.log(`Total return rate: ${expectedReturnTotal}%`)
        //Calculate allocation
        //This is calculated by actual weight * amount
        const allocation: Array<number> = []
        for (let index = 0; index < actualWeights.length; index ++) {
            var allocatedAmount = actualWeights[index] * amount
            allocation.push(allocatedAmount)
        }
        console.log(`Respective Allocations: ${allocation}`)
        //Total expected return on investment
        const returnAmount: number = (1 + (expectedReturnTotal / 100)) * amount
        console.log(`Expected Return Amount: ${returnAmount}`)
        console.log(`Chosen Investments Count: ${chosenInvestments.length}`)

        //Push changes to the document. Return Amount and Return Rate
        await db.collection('autocreates').doc(documentId).update({
            "returnInterestRate": expectedReturnTotal,
            "returnAmount": returnAmount
        })

        //Finally create the goals
        //Iterate over chosen investments
        const category: string = 'Investment'
        const created: Date = new Date
        const deletable: boolean = true
        const amountSaved: number = 0.0
        var currentKey: string = ''
        var currentValue: string = ''

        //New List to store allocations without 0
        const newAllocations: Array<number> = [];
        //Remove values with '0' from 'allocation
        for (let index = 0; index < allocation.length; index ++) {
            if (allocation[index] > 0) {
                newAllocations.push(allocation[index])
            }
            else {
                continue
            }
        }
        console.log(`New Allocation: ${newAllocations}`)

        for (let index = 0; index < newAllocations.length; index ++) {
            for (let i = 0; i < chosenInvestments.length; i ++) {
                //Iterate over keys
                
                for (let key of chosenInvestments[index].keys()) {
                    currentKey = key
                }
                for (let value of chosenInvestments[index].values()) {
                    currentValue = value
                }
                //console.log(`Key: ${currentKey}, Value: ${currentValue}`)
            }
            await db.collection('users').doc(uid)
                .collection('goals').doc().set({
                    "goalCategory": category,
                    "goalClass": currentKey,
                    "goalType": currentValue,
                    "goalName": currentValue,
                    "uid": uid,
                    "goalAmount": newAllocations[index],
                    "goalAmountSaved": amountSaved,
                    "goalCreateDate": created,
                    "goalEndDate": endDate,
                    "goalAllocation": 0.0,
                    "isGoalDeletable": deletable
                })
        }
        
    })

export const nudgeFriend = functions.firestore
    .document('nudges/{nudge}')
    .onCreate(async snapshot => {
        const token: string = snapshot.get('token')
        const payload = {
            notification: {
                title: `Nudge`,
                body: `You received a nudge from a group member`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        }
        await db.collection('nudges').doc(snapshot.id).delete()
        return fcm.sendToDevice(token, payload)
            .catch(error => {
            console.error('Nudge FCM Error',error)
        })
    })

export const groupMembers = functions.firestore
    .document('groups/{group}')
    .onWrite(async snapshot => {
        //const admin: string = snapshot.before.get('groupAdmin')
        const membersBefore: Array<string> = snapshot.before.get('members')
        const membersAfter: Array<string> = snapshot.after.get('members');
        console.log(`Members Before: ${membersBefore}`)
        console.log(`Members After: ${membersAfter}`)


        if (!snapshot.before.exists) {
            membersAfter.forEach(async (element) => {
                let user: DocumentSnapshot = await db.collection('users').doc(element).get()
                console.log(`Requesting USER: ${user.get('uid')}`)
                await db.collection('groups').doc(snapshot.after.id).collection('members').doc(element).set({
                    "fullName": user.get('fullName'),
                    "photoURL": user.get('photoURL'),
                    "token": user.get('token'),
                })
            })
        }
        if (!snapshot.after.exists) {
            deleteGroup
        }
        else {
            if (membersAfter.length > membersBefore.length && (snapshot.before.exists)) {
                const diff: number = membersAfter.length - membersBefore.length
                await db.collection('groups').doc(snapshot.after.id).update({
                    'groupMembers': superadmin.firestore.FieldValue.increment(diff)
                });
            }
            if (membersBefore.length > membersAfter.length) {
                const diff: number = membersBefore.length - membersAfter.length
                await db.collection('groups').doc(snapshot.after.id).update({
                    'groupMembers': superadmin.firestore.FieldValue.increment(-diff)
                });
            }

            for (let index = 0; index < membersAfter.length; index ++) {
                if (membersBefore[index] == membersAfter[index]) {
                    continue
                }
                else {
                    let user: DocumentSnapshot = await db.collection('users').doc(membersAfter[index]).get()
                    console.log(`Requesting USER: ${user.get('uid')}`)
                    await db.collection('groups').doc(snapshot.after.id).collection('members').doc(membersAfter[index]).set({
                        "fullName": user.get('fullName'),
                        "photoURL": user.get('photoURL'),
                        "token": user.get('token'),
                    })
                }
            }
        }
    })

export const deleteGroup = functions.firestore
    .document('groups/{group}')
    .onDelete(async snapshot => {
        const uid: string = snapshot.id
        const queries: FirebaseFirestore.QuerySnapshot = await db.collection('groups').doc(uid).collection('members').get()
        queries.forEach(async (element) => {
            await db.collection('groups').doc(uid).collection('members').doc(element.id).delete()
        })
    })

export const lendMoneyGoalFund  = functions.firestore
    .document('loans/{loan}')
    .onCreate(async snapshot => {
        const uid: string =  snapshot.get('loanLender')
        const amount: number = snapshot.get('loanAmountTaken')
        const invitee: string = snapshot.get('loanInvitees')
        if (invitee == null) {
            //Update Loan Fund Goal
            const doc: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid)
                .collection('goals').where('goalCategory', '==', 'Loan Fund').limit(1).get()
            console.log(`Document ID: ${doc.docs[0].id}`)
            doc.docs.forEach(async (element) => {
                const docId: string = element.id
                await db.collection('users').doc(uid).collection('goals').doc(docId).update({
                    'goalAmount': amount
                })
            })
        }
    })
