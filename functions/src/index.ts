import * as functions from 'firebase-functions'
import * as superadmin from 'firebase-admin'

superadmin.initializeApp()

import * as express from 'express'
import { DocumentSnapshot } from 'firebase-functions/lib/providers/firestore'
//import * as auth from './authentication'
import * as mpesa from './mpesa'
import * as sms from './sms'


const db = superadmin.firestore()
const fcm = superadmin.messaging()

// Initialize Express Server
const app = express()
const main = express()

// /*
// SERVER CONFIGURATION
// 1) Base Path
// 2) Set JSON as main parser
// */
main.use('/api/v1', app)
main.use(express.json())

// /*
// API
// */
export const sortikaMain = functions.region('europe-west1').https.onRequest(main)
// Registration
// app.post('/users', auth.createUser)

// M-PESA Endpoints
// 1) Lipa Na Mpesa Online CallbackURL
app.post('/nitumiekakitu/0CCX2LkvU7kG8cSHU2Ez', mpesa.mpesaLnmCallback)
//2) Lipa Na Mpesa Online CallbackURL (Captures)
app.post('/tumecapturekitu/CBCwudDBSn46CVuz1wnn', mpesa.mpesaLnmCallbackForCapture)
// 2) B2C Timeout URL
app.post('/oyab2cimetimeout/Mm6rm3JwcExVNFk82l9X', mpesa.mpesaB2cTimeout)
// 3) B2C ResultURL
app.post('/wolandehb2cimeingia/SV02a3Lpqi883ZNfjIma', mpesa.mpesaB2cResult)

// SMS ANALYSIS Endpoints
app.post('/tusomerecords/9z5JjD9bGODXeSVpdNFW', sms.receiveSMS)


/*
ALLOCATIONS CALCULATOR
Version 1: onWrite
Version 2: onDelete
*/

//Calculate goal allocations
exports.allocationsCalculatorV1 = functions.firestore
    .document('/users/{user}/goals/{goal}')
    .onWrite(async snapshot => {
        //Retrieve user id
        const uid = snapshot.after.get('uid')
        const docs = await db.collection('users').doc(uid).collection('goals').get()
        const allDocs: Array<DocumentSnapshot> = docs.docs
        const periods: Array<number> = []
        const amounts: Array<number> = []
        const adjustedAmounts: Array<number> = []
        const documentIds: Array<string> = []
        const allocationpercents: Array<number> = []
        allDocs.forEach(element => {
            //If the goal is a group goal fetch targetAmountPer and not goal amount
            const cat: string = element.get('goalCategory')
            let amt:number = (cat === 'Group') ? element.get('targetAmountPerp') : element.get('goalAmount')
            /*
            Timestamp is returned from Firebase.
            Convert to Date then get differences in days
            */
            const timeStart: FirebaseFirestore.Timestamp = element.get('goalCreateDate')
            const dateStart: Date = timeStart.toDate()

            const timeEnd: FirebaseFirestore.Timestamp = element.get('goalEndDate')
            const dateEnd = timeEnd.toDate()

            const differenceMilliSeconds = dateEnd.getTime() - dateStart.getTime()
            const differenceDays = differenceMilliSeconds / (1000*60*60*24)

            //Save the difference in a list
            periods.push(Math.ceil(differenceDays))
            //Document Snapshot
            //Retrieve target amount and save in amounts
            amounts.push(amt)
            documentIds.push(element.id)
            
        });
        //Sort from smallest to largest
        periods.sort()
        const leastDays = periods[0]
        //Show arrays
        // console.log(`Periods: ${periods}`)
        // console.log(`Amounts: ${amounts}`)
        // console.log(`Document Ids: ${documentIds}`)
        //Keep a total adjusted amount counter
        let totalAdjusted: number = 0
        for (let index = 0; index < amounts.length; index ++) {
            const adjusted: number = ( (amounts[index] * leastDays) / periods[index] )
            adjustedAmounts.push(adjusted)
            totalAdjusted = totalAdjusted + adjusted
        }
        //Show adjusted amounts
        // console.log(`Adjusted Amounts: ${adjustedAmounts}`)
        // //Show the total adjusted number
        // console.log(`Total Adjusted Value: ${totalAdjusted}`)
        //Get allocation percentages
        // for (const adjAmount of adjustedAmounts) {
        //     const percent: number = ( (adjAmount / totalAdjusted) * 100 )
        //     allocationpercents.push(percent)
        // }
        for (let index = 0; index < adjustedAmounts.length; index ++) {
            const percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
            allocationpercents.push(percent)
        }
        //Show percents
        // console.log(`Allocation Percents: ${allocationpercents}`)
        //Update each document with new allocations
        for (let index = 0; index < documentIds.length; index ++) {
            const documentId: string = documentIds[index]
            const allocatedPercent: number = allocationpercents[index]
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
        //A message to be displayed when the function ends
        console.log('allocationsCalculatorV1 has completed successfully')
    })

/*
Any change to goal amount saved
//New goal amount = goal amount - amount saved
//Run a task every night midnight. GoalCreateDate update to current date, then recalculate dialy, weekly, monthly targets
*/

// async function scheduledAllocator(users: Array<string>) {
//     users.forEach(async (user) => {
//         const docs = await db.collection('users').doc(user).collection('goals').get()
//         const allDocs: Array<DocumentSnapshot> = docs.docs
//         const periods: Array<number> = []
//         const amounts: Array<number> = []
//         const adjustedAmounts: Array<number> = []
//         const documentIds: Array<string> = []
//         const allocationpercents: Array<number> = []
//         allDocs.forEach(element => {
//             //If the goal is a group goal fetch targetAmountPer and not goal amount
//             const cat: string = element.get('goalCategory')
//             let amt:number = (cat === 'Group') ? element.get('targetAmountPerp') : element.get('goalAmount')
//             /*
//             Timestamp is returned from Firebase.
//             Convert to Date then get differences in days
//             */
//             const timeStart: FirebaseFirestore.Timestamp = element.get('goalCreateDate')
//             const dateStart: Date = timeStart.toDate()

//             const timeEnd: FirebaseFirestore.Timestamp = element.get('goalEndDate')
//             const dateEnd = timeEnd.toDate()

//             const differenceMilliSeconds = dateEnd.getTime() - dateStart.getTime()
//             const differenceDays = differenceMilliSeconds / (1000*60*60*24)

//             //Save the difference in a list
//             periods.push(Math.ceil(differenceDays))
//             //Document Snapshot
//             //Retrieve target amount and save in amounts
//             amounts.push(amt)
//             documentIds.push(element.id)
//         });
//         //Sort from smallest to largest
//         periods.sort()
//         const leastDays = periods[0]
//         //Show arrays
//         // console.log(`Periods: ${periods}`)
//         // console.log(`Amounts: ${amounts}`)
//         // console.log(`Document Ids: ${documentIds}`)
//         //Keep a total adjusted amount counter
//         let totalAdjusted: number = 0
//         for (let index = 0; index < amounts.length; index ++) {
//             const adjusted: number = ( (amounts[index] * leastDays) / periods[index] )
//             adjustedAmounts.push(adjusted)
//             totalAdjusted = totalAdjusted + adjusted
//         }
//         //Show adjusted amounts
//         // console.log(`Adjusted Amounts: ${adjustedAmounts}`)
//         // //Show the total adjusted number
//         // console.log(`Total Adjusted Value: ${totalAdjusted}`)
//         //Get allocation percentages
//         for (let index = 0; index < adjustedAmounts.length; index ++) {
//             const percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
//             allocationpercents.push(percent)
//         }
//         //Show percents
//         // console.log(`Allocation Percents: ${allocationpercents}`)
//         //Update each document with new allocations
//         for (let index = 0; index < documentIds.length; index ++) {
//             const documentId: string = documentIds[index]
//             const allocatedPercent: number = allocationpercents[index]
//             await db.collection('users').doc(user)
//                 .collection('goals').doc(documentId).update({'goalAllocation':allocatedPercent})
//         }
//         //Update User Targets
//         const dailyTarget: number = (totalAdjusted / leastDays)
//         const weeklyTarget: number = (dailyTarget * 7)
//         const monthlyTarget: number = (dailyTarget * 30)
//         //Update USERS Collection
//         await db.collection('users').doc(user).update({
//             'dailyTarget': dailyTarget,
//             'weeklyTarget': weeklyTarget,
//             'monthlyTarget': monthlyTarget
//         })
//     })
// }

// every day 00:01
export const scheduledFunction = functions.pubsub.schedule(`every day 00:01`)
    .timeZone('Africa/Nairobi')
    .onRun(async (context: functions.EventContext) => {
        //every day 00:01
        // console.log(`This will run every day 00:01`)
        //Retrieve all user documets
        const usersQueries: FirebaseFirestore.QuerySnapshot = await db.collection('users').get()
        const userDocuments: Array<DocumentSnapshot> = usersQueries.docs

        //Placeholder for UIDs
        const uidList: Array<string> = []
        userDocuments.forEach((document: FirebaseFirestore.DocumentSnapshot) => {
            uidList.push(document.get('uid'))
        })
        // console.log(`List of User IDs: ${uidList}`)

        //Iterate through list of USER IDs
        for (let index: number = 0; index < uidList.length; index ++) {
            //Retrieve all user goals documents
            const usersGoalsQueries: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uidList[index]).collection('goals').get()
            const userGoalsDocuments: Array<DocumentSnapshot> = usersGoalsQueries.docs

            for (let i: number = 0; i < userGoalsDocuments.length; i++) {
                //console.log(`GOAL DOCUMENT: ${userGoalsDocuments[i].id} \nUPDATE: ${superadmin.firestore.Timestamp.now()}`)
                await db.collection('users').doc(uidList[index]).collection('goals').doc(userGoalsDocuments[i].id).update({
                    'goalCreateDate': superadmin.firestore.Timestamp.now()
                })
            }

        }
        console.log(`Finished updating Timestamps`)
        //Perform changes
        // console.log('Perform allocation changes')
        // // scheduledAllocator(uidList)
        // //     .catch((error) => console.log(`Scheduled Allocator Error: ${error}`))
        // console.log('Finished updating allocations')
        console.log('Midnight function has completed successfully')
        return null;
    });



exports.allocationsCalculatorV2 = functions.firestore
    .document('/users/{user}/goals/{goal}')
    .onDelete(async snapshot => {
        //Redistribute the goal amount
        const goalAmount: number = snapshot.get('goalAmount')
        const goalAmountSaved: number = snapshot.get('goalAmountSaved')
        //Retrieve user id
        const uid = snapshot.get('uid')
        if (snapshot.get('goalCategory') === 'Investment') {
            const investmentDocuments: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid).collection('goals')
                .where('goalCategory', '==', 'Investment').get()
            // console.log(`How many investment goals? ${investmentDocuments.docs.length}`)
            const averageAmount: number = (goalAmount / investmentDocuments.docs.length)
            for (let index = 0; index < investmentDocuments.docs.length; index ++) {
                let currentAmount: number = investmentDocuments.docs[index].get('goalAmount')
                currentAmount = currentAmount + averageAmount
            
                const documentId: string = investmentDocuments.docs[index].id
                await db.collection('users').doc(uid)
                .collection('goals').doc(documentId).update({'goalAmount': currentAmount})
            }
        }
        if (snapshot.get('goalCategory') === 'Saving') {
            const lFDocuments: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid)
                .collection('goals').where('goalCategory', '==', 'Loan Fund').limit(1).get()
                if (goalAmountSaved === 0) {
                    console.log(`The goal amount saved is 0`)
                }
                else {
                    lFDocuments.docs.forEach(async (element) => {
                        // var amountCurrent = element.get('loanAmount')
                        // amountCurrent = amountCurrent + goalAmount
                        await db.collection('users').doc(uid)
                        .collection('goals').doc(element.id).update({
                            'goalAmountSaved': superadmin.firestore.FieldValue.increment(goalAmountSaved)})
                    })
                }
        }
        const docs = await db.collection('users').doc(uid).collection('goals').get()
        const allDocs: Array<DocumentSnapshot> = docs.docs
        const periods: Array<number> = []
        const amounts: Array<number> = []
        const adjustedAmounts: Array<number> = []
        const documentIds: Array<string> = []
        const allocationpercents: Array<number> = []
        allDocs.forEach(element => {
            //If the goal is a group goal fetch targetAmountPer and not goal amount
            const cat: string = element.get('goalCategory')
            let amt:number = (cat === 'Group') ? element.get('targetAmountPerp') : element.get('goalAmount')
            /*
            Timestamp is returned from Firebase.
            Convert to Date then get differences in days
            */
            const timeStart: FirebaseFirestore.Timestamp = element.get('goalCreateDate')
            const dateStart: Date = timeStart.toDate()

            const timeEnd: FirebaseFirestore.Timestamp = element.get('goalEndDate')
            const dateEnd = timeEnd.toDate()

            const differenceMilliSeconds = dateEnd.getTime() - dateStart.getTime()
            const differenceDays = differenceMilliSeconds / (1000*60*60*24)

            //Save the difference in a list
            periods.push(Math.ceil(differenceDays))
            //Document Snapshot
            //Retrieve target amount and save in amounts
            amounts.push(amt)
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
            const adjusted: number = ( (amounts[index] * leastDays) / periods[index] )
            adjustedAmounts.push(adjusted)
            totalAdjusted = totalAdjusted + adjusted
        }
        //Show adjusted amounts
        console.log(`Adjusted Amounts: ${adjustedAmounts}`)
        //Show the total adjusted number
        console.log(`Total Adjusted Value: ${totalAdjusted}`)
        //Get allocation percentages
        for (let index = 0; index < adjustedAmounts.length; index ++) {
            const percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
            allocationpercents.push(percent)
        }
        //Show percents
        console.log(`Allocation Percents: ${allocationpercents}`)
        //Update each document with new allocations
        for (let index = 0; index < documentIds.length; index ++) {
            const documentId: string = documentIds[index]
            const allocatedPercent: number = allocationpercents[index]
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
1) Send notification to a Sortika user who has received a lend request - promptLendRequest
2) Send notification to the borrower - ackBorrowRequest
3) Send a notification to borrower when loan has been accepted - promptLoanAccepted
4) Send a notification to the lender when they accept the loan request - promptLoanAccept
5) Send a notification to a borrower when the lender revises a loan request - promptLoanRevision
6) Send a notification to the lender when the borrower negotiates - promptLoanNegotiation
7) Send a notification to lender when they receive a negotiation request - promptReceiveNegotiation
8) Send a notification to a lender who has sent the loan back for revision - promptSubmitLoanRevision
9) Send a notification to a borrower when loan request has been rejected - promptLoanRejected
10) Send a notification to a lender who has rejected a loan request - promptRejectLoan
*/

export const promptLendRequest = functions.firestore
    .document('loans/{loan}')
    .onCreate(async snapshot => {
        const token: string = snapshot.get('tokenInvitee')
        const amount: number = snapshot.get('loanAmountTaken')
        const interest: number = snapshot.get('loanInterest')
        //const invitees: string | Array<any> = snapshot.get('loanInvitees')
        //Retrieve the token (If exists)
        if (token !== null) {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `Loan Request`,
                    body: `You have received a request for ${amount} KES at an interest rate of ${interest} %`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            // if (typeof invitees === "string") {
            //     await db.collection('users').doc(invitees).collection('notifications').doc().set({
            //         'message': `You have received a request for ${amount} KES at an interest rate of ${interest} %`,
            //         'time': superadmin.firestore.FieldValue.serverTimestamp()
            //     })
            // }
            // else {
            //     invitees.forEach(async (element) => {
            //         await db.collection('users').doc(element).collection('notifications').doc().set({
            //             'message': `You have received a request for ${amount} KES at an interest rate of ${interest} %`,
            //             'time': superadmin.firestore.FieldValue.serverTimestamp()
            //         })
            //     })
            // }
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
        //const borrowerUid: string = snapshot.get('loanBorrower')

        if (token !== null) {
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
            // await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
            //     'message': `Your request for ${amount} KES at an interest rate of ${interest} % has been sent successfully`,
            //     'time': superadmin.firestore.FieldValue.serverTimestamp()
            // })
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
            //const borrowerUid: string = snapshot.after.get('loanBorrower')
            const time: FirebaseFirestore.Timestamp = snapshot.after.get('loanEndDate')
        //Retrieve the token (If exists)
        if (snapshot.before.get('loanStatus') === false && snapshot.after.get('loanStatus') === true) {
            //Retrieve key info
            //Define the payload
            const payload = {
                notification: {
                    title: `Good News`,
                    body: `Your loan request of ${amount} KES has been accepted. You will payback ${due} KES. You have until ${time.toDate().toString()}`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            //Create a notification for the borrower
            //Store in notifications subcollection of user
            // await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
            //     'message': `Your loan request of ${amount} KES has been accepted. You will payback ${due} KES. You have until ${date.toLocaleDateString()}`,
            //     'time': superadmin.firestore.FieldValue.serverTimestamp()
            // })
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
            //const lenderUid: string = snapshot.after.get('loanLender')
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
            // await db.collection('users').doc(lenderUid).collection('notifications').doc().set({
            //     'message': `We will deduct ${amount} KES from your wallet and send to ${borrowerName}`,
            //     'time': superadmin.firestore.FieldValue.serverTimestamp()
            // })
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
        //const borrowerUid: string = snapshot.before.get('loanBorrower')
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
        // await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
        //     'message': `You have sent a revised loan request submission`,
        //     'time': superadmin.firestore.FieldValue.serverTimestamp()
        // })
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
        if (typeof inviteeUid === "string") {
            // await db.collection('users').doc(inviteeUid).collection('notifications').doc().set({
            //     'message': `You have received a revised loan request. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. They will pay back ${due} KES`,
            //     'time': superadmin.firestore.FieldValue.serverTimestamp()
            // })
            //Send to all tenants in the topic "landlord_code"
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptLoanRevised FCM Error',error)
            }) 
        }
        else {
            // inviteeUid.forEach(async (element) => {
            //     await db.collection('users').doc(element).collection('notifications').doc().set({
            //         'message': `You have received a revised loan request. The new loan amount is ${amount} KES while the revised interest rate is ${interest} %. They will pay back ${due} KES`,
            //         'time': superadmin.firestore.FieldValue.serverTimestamp()
            //     })                
            // })
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
        //const borrowerUid: string = snapshot.before.get('loanBorrower')
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
            // await db.collection('users').doc(borrowerUid).collection('notifications').doc().set({
            //     'message': `Your loan request of ${amount} KES at ${interest} % has been rejected`,
            //     'time': superadmin.firestore.FieldValue.serverTimestamp()
            // })
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
        //const loanInvitee: string | Array<any> = snapshot.before.get('loanInvitees')
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
            // if (typeof loanInvitee == "string") {
            //     await db.collection('users').doc(loanInvitee).collection('notifications').doc().set({
            //         'message': `You rejected a loan request of ${amount} KES at ${interest} %`,
            //         'time': superadmin.firestore.FieldValue.serverTimestamp()
            //     })
            // }
            // else {
            //     loanInvitee.forEach(async (element) => {
            //         await db.collection('users').doc(element).collection('notifications').doc().set({
            //             'message': `You rejected a loan request of ${amount} KES at ${interest} %`,
            //             'time': superadmin.firestore.FieldValue.serverTimestamp()
            //         })
            //     })
            // }
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
        const token: string = snapshot.get('tokenBorrower')
        if (lender !== null) {
            //Check if user has enough amount in Loan Fund Goal
            await db.collection('users').doc(lender).collection('goals')
                .where('goalCategory', '==', 'Loan Fund')
                .limit(1)
                .get().then((queries) => {
                    queries.forEach(async (element) => {
                        const limit: number = element.get('goalAmountSaved')
                        if (amount > limit) {
                            await db.collection('loans').doc(snapshot.id).update({
                                'tokenInvitee': token,
                            })
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
                                'loanLenderToken': token,
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
                                    console.error('selfLoanAccept FCM Error',error)
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
            const currentDocId: string = upperDocsArray[index].get('title')
            const lowerDocs = await db.collection('investments').doc(currentDocId)
                .collection('types').get()
            const lowerDocsArray = lowerDocs.docs
            for (let i = 0; i < lowerDocsArray.length; i ++) {
                const map = new Map()
                map.set(`${currentDocId}`, lowerDocsArray[i].get('name'))
                if (rate === 'low') {
                    if (lowerDocsArray[i].get('return') <= 10.5) {
                        chosenInvestments.push(map)
                    }
                } 
                if (rate === 'med') {
                    if (lowerDocsArray[i].get('return') > 10.5 && lowerDocsArray[i].get('return') <= 18) {
                        chosenInvestments.push(map)
                    }
                }
                if (rate === 'high') {
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
        let deviation: number
        const deviationList: Array<number> = []
        if (rate === 'low') {
            const staticFigure: number = 10.5
            //Cycle through the investments
            for (let index = 0; index < allInvestments.length; index ++) {
                deviation = staticFigure - allInvestments[index]['return']
                deviationList.push(deviation)
            }
        }
        else if (rate === 'med') {
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
            const weight: number = deviationList[index] * 0.1
            weightCalcs.push(weight)
        }
        //console.log(weightCalcs)
        //Calculate the risk level weight estimates
        //This is given by (1 - weight)
        const weightEstimates: Array<number> = []
        //Iterate through the list of weights
        for (let index = 0; index < weightCalcs.length; index ++) {
            const estimate = 1 - weightCalcs[index]
            weightEstimates.push(estimate)
        }
        console.log(`Weight Estimates: ${weightEstimates}`)
        //Calculate adjusted weight estimates
        //These are the weightEstimates that are below 1
        //Keep a running total of adjusted weight estimates
        let weightEstimatesTotal: number  = 0
        const adjustedWeightEstimates: Array<number> = []
        //Iterate through the weight estimates list
        for (let index = 0; index < weightEstimates.length; index ++) {
            //convert weight estimate to 0 if it is greater that 1 - Low and Medium
            //convert weight estimate to 0 if it is less than 1 - High
            if (rate === 'high') {
                if (weightEstimates[index] < 1) {
                    weightEstimates[index] = 0
                    //allInvestmentDocIds[index] = ''
                }
            }
            if (rate === 'low') {
                if (weightEstimates[index] > 1) {
                    weightEstimates[index] = 0
                    //allInvestmentDocIds[index] = ''
                }
            }
            if (rate === 'med') {
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
            const weightActual = adjustedWeightEstimates[index] * (1/weightEstimatesTotal)
            actualWeights.push(weightActual)
        }
        console.log(`Actual Weights: ${actualWeights}`)
        //Calculate expected return
        //This is calculated by actual weight * asset return
        const expectedReturns: Array<number> = []
        //Keep a counter for total expected return
        let expectedReturnTotal = 0
        for (let index = 0; index < actualWeights.length; index ++) {
            const calculatedReturn = allInvestments[index]['return'] * actualWeights[index]
            expectedReturns.push(calculatedReturn)
            expectedReturnTotal = expectedReturnTotal + calculatedReturn
        }
        console.log(`Total return rate: ${expectedReturnTotal}%`)
        //Calculate allocation
        //This is calculated by actual weight * amount
        const allocation: Array<number> = []
        for (let index = 0; index < actualWeights.length; index ++) {
            const allocatedAmount = actualWeights[index] * amount
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
        let currentKey: string = ''
        let currentValue: string = ''

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

// export const nudgeFriend = functions.firestore
//     .document('nudges/{nudge}')
//     .onCreate(async snapshot => {
//         const token: string = snapshot.get('token')
//         const payload = {
//             notification: {
//                 title: `Nudge`,
//                 body: `You received a nudge from a group member`,
//                 clickAction: 'FLUTTER_NOTIFICATION_CLICK'
//             }
//         }
//         await db.collection('nudges').doc(snapshot.id).delete()
//         return fcm.sendToDevice(token, payload)
//             .catch(error => {
//             console.error('Nudge FCM Error',error)
//         })
//     })

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
                const user: DocumentSnapshot = await db.collection('users').doc(element).get()
                //console.log(`Requesting USER: ${user.get('uid')}`)
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
        if (snapshot.before.exists && snapshot.after.exists) {
            if (membersAfter.length > membersBefore.length) {
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
                if (membersBefore[index] === membersAfter[index]) {
                    continue
                }
                else {
                    const user: DocumentSnapshot = await db.collection('users').doc(membersAfter[index]).get()
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



/*
NB
//Loan Limit Ratio = ((interest amount / limit ratio) * 100)
1) Loan Limit Ratio only changes when loan has been fully paid
2) Recoup sortika revenue before anything
3) Sortika revenue is 20% of total amount to be paid
*/

async function increaseLoanLimit(interest: number, uid: string) {
    const rate: number = interest * 0.75
    const doc: DocumentSnapshot = await db.collection('users').doc(uid).get()
    const limit: number = doc.get('loanLimitRatio')
    const newLimit: number = limit + rate
    await db.collection('users').doc(uid).update({
        'loanLimitRatio': newLimit
    })
}

export const loanLimitCalculator = functions.firestore
    .document('loans/{loan}')
    .onWrite(async snapshot => {
        //Check if the document exists
        if (snapshot.before.exists || snapshot.after.exists) {
            const totalAmountToPay: number = snapshot.after.get('totalAmountToPay')
            const amountRepaid: number = snapshot.after.get('loanAmountRepaid')
            const interest: number = snapshot.after.get('loanInterest')
            const borrowerUid: string = snapshot.after.get('loanBorrower')
            const lenderUid: string = snapshot.after.get('loanLender')

            //Calculate sortika revenue
            const sortikaRevenue: number = totalAmountToPay * 0.2
            console.log(`Sortika Revenue ${sortikaRevenue}`)

            //Check if amount paid is more than totaltoPay
            if (amountRepaid > totalAmountToPay) {
                //Get the difference and store in overpayments collection
                const difference: number = amountRepaid - totalAmountToPay
                //Change the loanAmountRepaid to TotalAmountToPay and mark loan as complete
                await db.collection('loans').doc(snapshot.after.id).update({
                    'loanAmountRepaid': totalAmountToPay,
                    'loanStatus': 'Completed'
                })
                //Create an overpayment
                await db.collection('overpayments').doc().set({
                    'loanBorrower': borrowerUid,
                    'loanLender': lenderUid,
                    'overpayment': difference
                })
                //increase loan limit
                increaseLoanLimit(interest, borrowerUid)
                .then((value) => {console.log(value)})
                .catch((error) => {console.error(`Increase Loan Limit Error: ${error}`)})
            }
            if (amountRepaid === totalAmountToPay) {
                //Mark loan as completed
                await db.collection('loans').doc(snapshot.after.id).update({
                    'loanStatus': 'Completed'
                })
                //increase loan limit
                increaseLoanLimit(interest, borrowerUid)
                .then((value) => {console.log(value)})
                .catch((error) => {console.error(`Increase Loan Limit Error: ${error}`)})
            }
        }
    })


// //Welcome a user
// export const welcomeUser = functions.firestore
//     .document('users/{user}')
//     .onCreate(async snapshot => {
//         //Send the user a welcome notification
//         const token: string = snapshot.get('token')
//         const fullName: string = snapshot.get('fullName')
//         const fname: string = fullName.split(' ')[0]
//         const payload = {
//             notification: {
//                 title: `It\'s time to Sortika`,
//                 body: `We are glad to have you on board ${fname}`,
//                 clickAction: 'FLUTTER_NOTIFICATION_CLICK'
//             }
//         }
//     return fcm.sendToDevice(token, payload)
//         .catch(error => {
//             console.error('welcomeUser FCM Error',error)
//     })
// })