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
    .onCreate(async (data: DocumentSnapshot, context: functions.EventContext) => {
        //Retrieve user id
        const uid = data.get('uid')
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


exports.allocationsCalculatorV2 = functions.firestore
    .document('/users/{user}/goals/{goal}')
    .onDelete(async (data: DocumentSnapshot, context: functions.EventContext) => {
        //Retrieve user id
        const uid = data.get('uid')
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
    .onWrite(async snapshot => {
        const amount: number = snapshot.after.get('amount')
        const rate: string = snapshot.after.get('returnRate')

        //Retrieve top collection documents
        const upperDocs = await db.collection('investments').get()
        const upperDocsArray: Array<DocumentSnapshot> = upperDocs.docs
        //Placeholder for the data we want
        const allInvestments: Array<FirebaseFirestore.DocumentData> = []
        //Iterate to get investment types in each
        for (let index = 0; index < upperDocsArray.length; index ++) {
            var currentDocId = upperDocsArray[index].get('title')
            const lowerDocs = await db.collection('investments').doc(currentDocId)
                .collection('types').get()
            const lowerDocsArray = lowerDocs.docs
            lowerDocsArray.forEach((type) => {
                allInvestments.push(type.data())
            }) 
        }
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
            //convert weight estimate to 0 if it is greater that 1
            if (weightEstimates[index] > 1) {
                weightEstimates[index] = 0
            }
            weightEstimatesTotal = weightEstimatesTotal + weightEstimates[index]
            adjustedWeightEstimates.push(weightEstimates[index])
        }
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
    })