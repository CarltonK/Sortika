import * as functions from 'firebase-functions'
import * as superadmin from 'firebase-admin'

superadmin.initializeApp()

import * as express from 'express'
import { DocumentSnapshot } from 'firebase-functions/lib/providers/firestore'
import * as goals from './goal_allocations'
import * as mpesa from './mpesa'
import * as sms from './sms'
import * as loan from './loan'
import * as ratecalc from './savings_rate_calculator'
import * as lottery from './lottery'
import * as groups from './groups'
import * as redeem from './redeem'
import * as backup from './backup'
import * as bookings from './bookings'
import * as user from './user_management'

const db = superadmin.firestore()

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

// M-PESA Endpoints
// 1) Lipa Na Mpesa Online Callback URL
app.post('/nitumiekakitu/0CCX2LkvU7kG8cSHU2Ez', mpesa.mpesaLnmCallback)
//2) Lipa Na Mpesa Online Callback URL (Captures)
app.post('/tumecapturekitu/CBCwudDBSn46CVuz1wnn', mpesa.mpesaLnmCallbackForCapture)
// 2) B2C Timeout URL
app.post('/oyab2cimetimeout/Mm6rm3JwcExVNFk82l9X', mpesa.mpesaB2cTimeout)
// 3) B2C Result URL
app.post('/wolandehb2cimeingia/SV02a3Lpqi883ZNfjIma', mpesa.mpesaB2cResult)
// 4) C2B Validation URL
app.post('/wolandehvalidatec2b/eCcjec4GImjejAm9sfAz', mpesa.mpesaC2bValidation)
// 5) C2B Confirmation URL
app.post('/wolandehconfirmationc2b/e1wlv2pVt0DheiDAPixv', mpesa.mpesaC2bConfirmation)

// 6) SMS ANALYSIS Endpoints
app.post('/tusomerecords/9z5JjD9bGODXeSVpdNFW', sms.receiveSMS)


/*
ALLOCATIONS CALCULATOR
Version 1: onCreate
Version 2: onDelete
Version 3: onWrite - Whenever goalAmountSaved or goalCreateDate changes
*/
//
export const allocationsCalculatorV1 = goals.AllocationV1
export const allocationsCalculatorV2 = goals.AllocationV2
export const allocationsCalculatorV3 = goals.AllocationV3

//Run a task every night midnight. GoalCreateDate update to current date, then recalculate daily, weekly, monthly targets
// every day 00:01
export const scheduledMidnightFunction = functions.region('europe-west1').pubsub.schedule(`every day 00:01`)
    .timeZone('Africa/Nairobi')
    .onRun(async (context: functions.EventContext) => {
        //every day 00:01
        // console.log(`This will run every day 00:01`)
        //Retrieve all user documents
        try {
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
            // console.log(`Finished updating Timestamps`)
        } catch (error) {
            throw error
        }
    })


export const scheduledThresholdFunction = functions.region('europe-west1').pubsub.schedule(`every day 01:00`)
    .timeZone('Africa/Nairobi')
    .onRun(async (context: functions.EventContext) => {
        //every day 01:00
        // console.log(`This will run every day 01:00`)
        //Retrieve all user documents
        try {
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
                    const goalAmountSaved: number = userGoalsDocuments[i].get('goalAmountSaved')
                    const goalAmount: number = userGoalsDocuments[i].get('goalAmount')
                    const halfWayPoint: number = goalAmount / 2
                    if (goalAmountSaved >= halfWayPoint) {
                        await db.collection('users').doc(uidList[index]).collection('goals').doc(userGoalsDocuments[i].id).update({
                            'threshold': true
                        })
                    } 
                }

            }
            // console.log(`Finished updating Timestamps`)
        } catch (error) {
            throw error
        }
    })

export const goalAutoCreate = functions.region('europe-west1').firestore
    .document('autocreates/{autocreate}')
    .onCreate(async snapshot => {
        try {
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
        } catch (error) {
            throw error
        }
    })


/*
Sortika Points
Record Points every time a transaction is carried out
*/
exports.sortikaPoints = functions.region('europe-west1').firestore
    .document('/transactions/{transaction}')
    .onCreate(async snapshot => {
        //Retrieve amount and uid
        const amount: number = snapshot.get('transactionAmount')
        const uid: string = snapshot.get('transactionUid')
        //Check if the amount is greater than or equal to 10
        try {
            if (amount >= 10) {
                const points: number = Math.floor(amount / 10)
                await db.collection('users').doc(uid).update({
                    points: superadmin.firestore.FieldValue.increment(points)
                })
            }
        } catch (error) {
            throw error
        }  
    })

//User Registration
export const newUser = user.userCreated

//Midnight Function
export const currentSavingsRateCalculator = ratecalc.scheduledRateCalculator

//Lottery Functions
export const joinLottery = lottery.joinALottery
export const announceLottery = lottery.announceLotteryCreation

//Redeem
export const redeemGoal = redeem.RedeemGoal

//Loan Functions
export const loanCreated =  loan.LoanCreate
export const loanUpdate = loan.LoanStatusUpdate
export const loanRepaid = loan.LoanRepaid
export const loanPayment = loan.LoanPayment

//Groups functions
export const groupWrite = groups.groupMembers
export const groupDeletion = groups.deleteGroup

//Backup Function
export const sortikaBackup = backup.SortikaBackup

//Booking Function
export const bookingCalulator = bookings.BookingCalculator






