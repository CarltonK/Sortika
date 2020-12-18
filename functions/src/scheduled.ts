import * as functions from 'firebase-functions'
import * as superadmin from 'firebase-admin'
import * as notifications from './notification'

const db = superadmin.firestore()

export const scheduledRateCalculator = functions.region('europe-west1').pubsub.schedule(`every day 00:30`)
    .timeZone('Africa/Nairobi')
    .onRun(async (context: functions.EventContext) => {
        //every day 00:30
        //Retrieve all user documents
        const usersQueries: FirebaseFirestore.QuerySnapshot = await db.collection('users').get()
        const userDocuments: FirebaseFirestore.DocumentSnapshot[] = usersQueries.docs

        //Placeholder for UIDs
        const uidList: string[] = []
        const dailySavingsRatesList: number[] = []
        userDocuments.forEach((document: FirebaseFirestore.DocumentSnapshot) => {
            uidList.push(document.get('uid'))
            dailySavingsRatesList.push(document.get('dailyTarget'))
        })

        //Running variables
        //Total savings = sum of all savings from initial deposit to date
        let totalSavings: number = 0
        //Period = todays date - initial deposit date
        let period: number
        //Total Daily Savings = total savings / period
        let tdSavings: number = 0
        //Current savings rate = total saily savings / (daily savings target - read from user doc)
        let currSavingsRate: number = 0

        //Step 1 - Get date now
        const nowDate: Date = superadmin.firestore.Timestamp.now().toDate()
        // Step 2 - Get Sum of savings from initial deposit to date
        try {
            const transactionPromises: Promise<FirebaseFirestore.QuerySnapshot>[] = []
            uidList.forEach(async (member: string) => {
                const relevantQuery: Promise<FirebaseFirestore.QuerySnapshot> = db.collection('transactions')
                    .where('transactionUid','==',member)
                    .where('transactionCategory','in',['General','Loan Fund','Saving','Investment'])
                    .orderBy('transactionTime','asc')
                    .get()
                transactionPromises.push(relevantQuery)
            })
            
            const batch = db.batch()
            const overallTransactionResult = await Promise.all(transactionPromises)
            overallTransactionResult.forEach((promiseResult: FirebaseFirestore.QuerySnapshot) => {
                const queryDocs: FirebaseFirestore.DocumentSnapshot[] = promiseResult.docs
                let index: number = 0
                // console.log(`Query: ${promiseResult.docs}`)
                if (queryDocs !== null && queryDocs.length > 0) {

                    const initDateValue: any = queryDocs[0].createTime?.toDate()
                    const differenceMilliSeconds = nowDate.getTime() - initDateValue.getTime()
                    const differenceDays = differenceMilliSeconds / (1000*60*60*24)
                    period = Math.ceil(differenceDays)

                    // console.log(`Period: ${period}`)

                    let user: string = ''
                    queryDocs.forEach((relDoc: FirebaseFirestore.DocumentSnapshot) => {
                        user = relDoc.get('transactionUid')

                        const amount: number = relDoc.get('transactionAmount')
                        totalSavings += amount

                    })
                    
                    const docRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(user)
                    tdSavings =  totalSavings / period
                    // console.log(`Total Daily Savings: ${tdSavings}`)
                    currSavingsRate = (tdSavings / dailySavingsRatesList[index]) * 100
                    // console.log(`Current Savings Rate: ${currSavingsRate}`)
                    batch.update(docRef, {'dailySavingsTarget': currSavingsRate})
                }
                index += 1
                period = 0
                totalSavings = 0
                currSavingsRate = 0
                tdSavings = 0
            })
            await batch.commit()
        } catch (error) {
            throw error
        }
    })


    //Run a task every night midnight. GoalCreateDate update to current date, then recalculate daily, weekly, monthly targets
// every day 00:01
export const ScheduledMidnightFunction = functions.region('europe-west1').pubsub.schedule(`every day 00:01`)
.timeZone('Africa/Nairobi')
.onRun(async (context: functions.EventContext) => {
    //every day 00:01
    // console.log(`This will run every day 00:01`)
    //Retrieve all user documents
    try {
        const usersQueries: FirebaseFirestore.QuerySnapshot = await db.collection('users').get()
        const userDocuments = usersQueries.docs

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
            const userGoalsDocuments = usersGoalsQueries.docs

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


export const ScheduledThresholdFunction = functions.region('europe-west1').pubsub.schedule(`every day 01:00`)
.timeZone('Africa/Nairobi')
.onRun(async (context: functions.EventContext) => {
    //every day 01:00
    // console.log(`This will run every day 01:00`)
    //Retrieve all user documents
    try {
        const usersQueries: FirebaseFirestore.QuerySnapshot = await db.collection('users').get()
        const userDocuments = usersQueries.docs

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
            const userGoalsDocuments = usersGoalsQueries.docs

            for (let i: number = 0; i < userGoalsDocuments.length; i++) {
                //console.log(`GOAL DOCUMENT: ${userGoalsDocuments[i].id} \nUPDATE: ${superadmin.firestore.Timestamp.now()}`)
                const goalAmountSaved: number = userGoalsDocuments[i].get('goalAmountSaved')
                const goalAmount: number = userGoalsDocuments[i].get('goalAmount')
                const halfWayPoint: number = goalAmount / 2
                if (goalAmountSaved >= halfWayPoint) {
                    await db.collection('users').doc(uidList[index]).collection('goals').doc(userGoalsDocuments[i].id).update({
                        'threshold': true,
                        'thresholdDate': superadmin.firestore.Timestamp.now()
                    })
                } 
            }

        }
        // console.log(`Finished updating Timestamps`)
    } catch (error) {
        throw error
    }
})


export const MorningNotifier = functions.region('europe-west1').pubsub.schedule(`every day 08:00`)
    .timeZone('Africa/Nairobi')
    .onRun(async (context: functions.EventContext) => {
        const tokens: string[] = []
        const usersQuery = await db.collection('users').get()
        const userDocuments: FirebaseFirestore.DocumentSnapshot[] = usersQuery.docs
        userDocuments.forEach(async (element: FirebaseFirestore.DocumentSnapshot) => {
            const token: string = element.get('token')
            tokens.push(token)
        })
        await notifications.singleNotificationSend(tokens,'Kindly login for passive savings computation for the last day',`Hello`)
    })


export const EveningNotifier = functions.region('europe-west1').pubsub.schedule(`every day 20:00`)
    .timeZone('Africa/Nairobi')
    .onRun(async (context: functions.EventContext) => {
        const tokens: string[] = []
        const usersQuery = await db.collection('users').get()
        const userDocuments: FirebaseFirestore.DocumentSnapshot[] = usersQuery.docs
        userDocuments.forEach(async (element: FirebaseFirestore.DocumentSnapshot) => {
            const token: string = element.get('token')
            tokens.push(token)
        })
        await notifications.singleNotificationSend(tokens,'Kindly login for passive savings computation for the last day','Hello')
    })