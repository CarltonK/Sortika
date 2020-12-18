import * as superadmin from 'firebase-admin'
import * as functions from 'firebase-functions'

const db = superadmin.firestore()

export const AllocationV1= functions.region('europe-west1').firestore
    .document('/users/{user}/goals/{goal}')
    .onCreate(async snapshot => {
        //Retrieve user id
        const uid = snapshot.get('uid')
        try {
            const docs = await db.collection('users').doc(uid).collection('goals').orderBy('goalEndDate').get()
            const allDocs: Array<superadmin.firestore.DocumentSnapshot> = docs.docs
            const periods: Array<number> = []
            const amounts: Array<number> = []
            const adjustedAmounts: Array<number> = []
            const documentIds: Array<string> = []
            const allocationpercents: Array<number> = []
            allDocs.forEach(element => {
                //If the goal is a group goal fetch targetAmountPer and not goal amount
                const cat: string = element.get('goalCategory')
                const amt: number = (cat === 'Group') ? element.get('targetAmountPerp') : element.get('goalAmount')
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
            periods.sort(function(a: number, b: number) {
                return a - b;
              });
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
            // //Show the total adjusted number
            console.log(`Total Adjusted Value: ${totalAdjusted}`)
            //Get allocation percentages
            for (let index = 0; index < adjustedAmounts.length; index ++) {
                const percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
                allocationpercents.push(percent)
            }
            //Show percents
            // console.log(`Allocation Percents: ${allocationpercents}`)
            //Update each document with new allocations
            const batch = db.batch()
            for (let index = 0; index < documentIds.length; index ++) {
                const documentId: string = documentIds[index]
                const allocatedPercent: number = allocationpercents[index]

                const docRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(documentId)
                batch.update(docRef, {goalAllocation:allocatedPercent})
                // await db.collection('users').doc(user)
                //     .collection('goals').doc(documentId).update({'goalAllocation':allocatedPercent})
            }
            //Update User Targets
            const dailyTarget: number = (totalAdjusted / leastDays)
            const weeklyTarget: number = (dailyTarget * 7)
            const monthlyTarget: number = (dailyTarget * 30)
            //Update USERS Collection
            const userRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid)
            batch.update(userRef, {
                'dailyTarget': dailyTarget,
                'weeklyTarget': weeklyTarget,
                'monthlyTarget': monthlyTarget
            })

            console.log(`Daily Targets - ${dailyTarget}`)
            console.log(`Weekly Targets - ${weeklyTarget}`)
            console.log(`Monthly Targets - ${monthlyTarget}`)

            //Commit the batch
            await batch.commit()
        } catch (error) {
            throw error
        }
        //A message to be displayed when the function ends
        // console.log('allocationsCalculatorV1 has completed successfully')
    })


export const AllocationV2 = functions.region('europe-west1').firestore
    .document('/users/{user}/goals/{goal}')
    .onDelete(async snapshot => {
        //Redistribute the goal amount
        // const goalAmount: number = snapshot.get('goalAmount')
        const goalAmountSaved: number = snapshot.get('goalAmountSaved')
        //Retrieve user id
        const uid = snapshot.get('uid')
        try {
            if (snapshot.get('goalCategory') === 'Investment') {
                const investmentDocuments: FirebaseFirestore.QuerySnapshot = await db.collection('users').doc(uid).collection('goals')
                    .where('goalCategory', '==', 'Investment').get()
                // console.log(`How many investment goals? ${investmentDocuments.docs.length}`)
                const averageAmount: number = (goalAmountSaved / investmentDocuments.docs.length)
                const batchInvest = db.batch()
                for (let index = 0; index < investmentDocuments.docs.length; index ++) {
                    if (snapshot.id === investmentDocuments.docs[index].id) {
                        investmentDocuments.docs.splice(index, 1)
                    }
                    let currentAmount: number = investmentDocuments.docs[index].get('goalAmountSaved')
                    currentAmount = currentAmount + averageAmount
                
                    const documentId: string = investmentDocuments.docs[index].id
                    const investDocRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(documentId)
                    batchInvest.update(investDocRef,{'goalAmountSaved': currentAmount})
                    // await db.collection('users').doc(uid)
                    // .collection('goals').doc(documentId).update({'goalAmount': currentAmount})
                }
                await batchInvest.commit()
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
            const docs = await db.collection('users').doc(uid).collection('goals').orderBy('goalEndDate').get()
            const allDocs: Array<superadmin.firestore.DocumentSnapshot> = docs.docs
            const periods: Array<number> = []
            const amounts: Array<number> = []
            const adjustedAmounts: Array<number> = []
            const documentIds: Array<string> = []
            const allocationpercents: Array<number> = []
            allDocs.forEach(element => {
                //If the goal is a group goal fetch targetAmountPer and not goal amount
                const cat: string = element.get('goalCategory')
                const amt:number = (cat === 'Group') ? element.get('targetAmountPerp') : element.get('goalAmount')
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
            periods.sort(function(a: number, b: number) {
                return a - b;
              });
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
            // //Show the total adjusted number
            console.log(`Total Adjusted Value: ${totalAdjusted}`)
            //Get allocation percentages
            for (let index = 0; index < adjustedAmounts.length; index ++) {
                const percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
                allocationpercents.push(percent)
            }
            //Show percents
            console.log(`Allocation Percents: ${allocationpercents}`)
            //Update each document with new allocations
            const batch = db.batch()
            for (let index = 0; index < documentIds.length; index ++) {
                const documentId: string = documentIds[index]
                const allocatedPercent: number = allocationpercents[index]

                const docRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(documentId)
                batch.update(docRef, {goalAllocation:allocatedPercent})
                // await db.collection('users').doc(user)
                //     .collection('goals').doc(documentId).update({'goalAllocation':allocatedPercent})
            }
            //Update User Targets
            const dailyTarget: number = (totalAdjusted / leastDays)
            const weeklyTarget: number = (dailyTarget * 7)
            const monthlyTarget: number = (dailyTarget * 30)

            console.log(`Daily Targets - ${dailyTarget}`)
            console.log(`Weekly Targets - ${weeklyTarget}`)
            console.log(`Monthly Targets - ${monthlyTarget}`)
            //Update USERS Collection
            const userRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid)
            batch.update(userRef, {
                'dailyTarget': dailyTarget,
                'weeklyTarget': weeklyTarget,
                'monthlyTarget': monthlyTarget
            })
            //Commit the batch
            await batch.commit()

        } catch (error) {
            throw error
        }
    })


/*
Any change to goal amount saved
//New goal amount = goal amount - amount saved
*/
export const AllocationV3 = functions.region('europe-west1').firestore
    .document('/users/{user}/goals/{goal}')
    .onUpdate(async snapshot => {
        //To be on the safe side check if the document exists
        const uid: string = snapshot.after.get('uid')
        try {
            if (snapshot.before.exists && snapshot.after.exists) {
                //Check if either the goalAmountSaved or the goalCreateDate has changed
                const usersList: Array<string> = []
                const cond1: Boolean = snapshot.before.get('goalAmountSaved') !== snapshot.after.get('goalAmountSaved')
                const cond2: Boolean = snapshot.before.get('goalCreateDate') !== snapshot.after.get('goalCreateDate')
                const cond3: Boolean = snapshot.before.get('goalAmount') !== snapshot.after.get('goalAmount')
                if (cond1 || cond2 || cond3) {
                    usersList.push(uid)
                    scheduledAllocator(usersList)
                        .then(value => console.log('Allocations Calculator V3 Success'))
                        .catch(error => console.error('Allocations Calculator V3 ERROR', error))
                }
            }
        } catch (error) {
            console.log(error)
        }
    })


async function scheduledAllocator(users: string[]) {
    users.forEach(async uid => {
        const docs = await db.collection('users').doc(uid).collection('goals').orderBy('goalEndDate').get()
        const allDocs: Array<superadmin.firestore.DocumentSnapshot> = docs.docs
        const periods: Array<number> = []
        const amounts: Array<number> = []
        const adjustedAmounts: Array<number> = []
        const documentIds: Array<string> = []
        const allocationpercents: Array<number> = []
        allDocs.forEach(element => {
            //If the goal is a group goal fetch targetAmountPer and not goal amount
            const cat: string = element.get('goalCategory')
            const amt:number = (cat === 'Group') ? element.get('targetAmountPerp') : element.get('goalAmount')
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
        periods.sort(function(a: number, b: number) {
            return a - b;
          });
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
        // //Show the total adjusted number
        console.log(`Total Adjusted Value: ${totalAdjusted}`)
        //Get allocation percentages
        for (let index = 0; index < adjustedAmounts.length; index ++) {
            const percent: number = ( (adjustedAmounts[index] / totalAdjusted) * 100 )
            allocationpercents.push(percent)
        }
        //Show percents
        // console.log(`Allocation Percents: ${allocationpercents}`)
        //Update each document with new allocations
        const batch = db.batch()
        for (let index = 0; index < documentIds.length; index ++) {
            const documentId: string = documentIds[index]
            const allocatedPercent: number = allocationpercents[index]

            const docRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('goals').doc(documentId)
            batch.update(docRef, {goalAllocation:allocatedPercent})
            // await db.collection('users').doc(user)
            //     .collection('goals').doc(documentId).update({'goalAllocation':allocatedPercent})
        }
        //Update User Targets
        const dailyTarget: number = (totalAdjusted / leastDays)
        const weeklyTarget: number = (dailyTarget * 7)
        const monthlyTarget: number = (dailyTarget * 30)
        //Update USERS Collection
        const userRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid)
        batch.update(userRef, {
            'dailyTarget': dailyTarget,
            'weeklyTarget': weeklyTarget,
            'monthlyTarget': monthlyTarget
        })
        //Commit the batch
        await batch.commit()
    })
}