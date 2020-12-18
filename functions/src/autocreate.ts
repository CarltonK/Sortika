import * as superadmin from 'firebase-admin'
import * as functions from 'firebase-functions'

const db = superadmin.firestore()

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
            const upperDocsArray = upperDocs.docs
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
            console.log(error)
        }
    })