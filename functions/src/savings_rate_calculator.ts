import * as functions from 'firebase-functions'
import * as superadmin from 'firebase-admin'

const db = superadmin.firestore()

export const scheduledRateCalculator = functions.pubsub.schedule(`every day 00:30`)
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