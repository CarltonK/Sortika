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
        //Periods placeholder
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
            var adjusted: number = ( (amounts[index] * leastDays) / periods[index] )
            adjustedAmounts.push(adjusted)
            totalAdjusted = totalAdjusted + adjusted
        }
        //Show adjusted amounts
        console.log(`Adjusted Amounts: ${adjustedAmounts}`)
        //Show the total adjusted number
        console.log(`Total Adjusted Value: ${totalAdjusted}`)
        //Get allocation percentages
        for (let index = 0; index < adjustedAmounts.length; index ++) {
            var percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
            allocationpercents.push(percent)
        }
        //Show percents
        console.log(`Allocation Percents: ${allocationpercents}`)
        //Update each document with new allocations
        for (let index = 0; index < documentIds.length; index ++) {
            await db.collection('users').doc(uid)
                .collection('goals').doc(documentIds[index]).update({'goalAllocation':allocationpercents[index]})
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
        const docs = await db.collection('users').doc(uid).collection('goals').get()
        const allDocs: Array<DocumentSnapshot> = docs.docs
        //Periods placeholder
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
            var adjusted: number = ( (amounts[index] * leastDays) / periods[index] )
            adjustedAmounts.push(adjusted)
            totalAdjusted = totalAdjusted + adjusted
        }
        //Show adjusted amounts
        console.log(`Adjusted Amounts: ${adjustedAmounts}`)
        //Show the total adjusted number
        console.log(`Total Adjusted Value: ${totalAdjusted}`)
        //Get allocation percentages
        for (let index = 0; index < adjustedAmounts.length; index ++) {
            var percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
            allocationpercents.push(percent)
        }
        //Show percents
        console.log(`Allocation Percents: ${allocationpercents}`)
        //Update each document with new allocations
        for (let index = 0; index < documentIds.length; index ++) {
            var newAmount: number = amounts[index]
            const avg: number = (goalAmount / documentIds.length)
            newAmount = newAmount + avg
            await db.collection('users').doc(uid)
                .collection('goals').doc(documentIds[index]).update(
                    {'goalAllocation':allocationpercents[index],
                     'goalAmount': newAmount})
        }
        //Update User Targets
        const dailyTarget: number = (totalAdjusted / 365)
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
        //Retrieve the token (If exists)
        if (snapshot.get('tokenInvitee') != null) {
            //Retrieve key info
            const token: string = snapshot.get('tokenInvitee')
            const amount: number = snapshot.get('loanAmountTaken')
            const interest: number = snapshot.get('loanInterest')
            //Define the payload
            const payload = {
                notification: {
                    title: `Loan Request`,
                    body: `You have received a request for ${amount} KES at an interest rate of ${interest} %`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            console.log(payload);
            //Send to all tenants in the topic "landlord_code"
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptLendRequest FCM Error',error)
        })
        }
    })


export const promptLoanAccepted = functions.firestore
    .document('loans/{loan}')
    .onWrite(async snapshot => {
        //Retrieve the token (If exists)
        if (snapshot.before.get('loanStatus') === false && snapshot.after.get('loanStatus') === true) {
            //Retrieve key info
            const token: string = snapshot.after.get('tokenBorrower')
            const amount: number = snapshot.after.get('loanAmountTaken')
            const due: number = snapshot.after.get('totalAmountToPay')

            const time: FirebaseFirestore.Timestamp = snapshot.after.get('loanEndDate')
            const date: Date = time.toDate()
            //Define the payload
            const payload = {
                notification: {
                    title: `Good News`,
                    body: `Your loan request of ${amount} KES has been accepted. You will payback ${due} KES. You have until ${date.toLocaleDateString()}`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            console.log(payload);
            //Send to all tenants in the topic "landlord_code"
            return fcm.sendToDevice(token, payload)
                .catch(error => {
                console.error('promptLoanAccepted FCM Error',error)
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

        if (!snapshot.before.exists) {
            membersAfter.forEach(async (element) => {
                const user: DocumentSnapshot = await db.collection('users').doc(element).get()
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
                    'groupMembers': FirebaseFirestore.FieldValue.increment(diff)
                });
            }
            if (membersBefore.length > membersAfter.length) {
                const diff: number = membersBefore.length - membersAfter.length
                await db.collection('groups').doc(snapshot.after.id).update({
                    'groupMembers': FirebaseFirestore.FieldValue.increment(-diff)
                });
            }

            for (let index = 0; index < membersAfter.length; index ++) {
                if (membersBefore[index] == membersAfter[index]) {
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
