import * as superadmin from 'firebase-admin'
import * as functions from 'firebase-functions'

const db = superadmin.firestore()

interface Type {
    booking: number,
    title: string,
    name: string,
    returnVal: number,
    time: FirebaseFirestore.Timestamp
}

const now: FirebaseFirestore.Timestamp = superadmin.firestore.Timestamp.now()
let periodFromLast: number
let totalAmountSaved: number = 0
const goalDetails: Map<string, any>[] = []

/*
---!!!OPERATION---!!!
(Amount Saved for a single user / Total Amount Saved) * ((Payday - Threshold Date) / Period from last pay day)
Variables required for this operation
1) Amount Saved in concerned goal for a single user
2) Total amount saved by all users in the specified investment class
3) Payday -> Time the function is run
4) Threshold Date -> Date the goal passed half of target amount therefore making the goal eligible for a payout
5) Period from last booking for concerned investment class (Default to 30 if last booking is not made or value > 30)
*/

export const BookingCalculator = functions.region('europe-west1').firestore
    .document('bookings/{booking}')
    .onWrite(async snapshot => {
        const data: Type = snapshot.after.data() as Type
        try {
            //Retrieve last pay date
            const lastBookingQuery = await db.collection('bookings')
                .where('title','==',data.title)
                .where('name','==',data.name)
                .orderBy('time','desc')
                .limit(2)
                .get()
            const lastBookingDocuments = lastBookingQuery.docs
            if (lastBookingDocuments !== null && lastBookingDocuments.length > 0)  {
                const docLen: number = lastBookingDocuments.length
                //Get Period from last pay day
                if (docLen === 1) {
                    periodFromLast = 30
                }
                if (docLen === 2) {
                    const concernedDoc: Type = lastBookingDocuments.pop()?.data() as Type
                    const timeOfConcernedDoc: Date = concernedDoc.time.toDate()
                    const nowDate: Date = now.toDate()

                    const differenceMilliSeconds = nowDate.getTime() - timeOfConcernedDoc.getTime()
                    const differenceDays = Math.ceil(differenceMilliSeconds / (1000*60*60*24))
                    periodFromLast = (differenceDays > 30) ? 30 : differenceDays
                }
            }
            console.log(`Period from last payday -> ${periodFromLast}`)
            
            //Retrieve concerned user goals
            const usersRef: FirebaseFirestore.CollectionReference = db.collection('users')
            const usersQuery: FirebaseFirestore.QuerySnapshot = await usersRef.get()
            const promises: Promise<FirebaseFirestore.QuerySnapshot>[] = []

            const userDocs: FirebaseFirestore.DocumentSnapshot[] = usersQuery.docs
            for (const iterator of userDocs) {
                const uid: string = iterator.get('uid')
                const goals: Promise<FirebaseFirestore.QuerySnapshot> = db.collection('users').doc(uid).collection('goals')
                    .where('goalClass','==',data.title)
                    .where('goalName','==',data.name)
                    .where('threshold','==',true)
                    .get()
                promises.push(goals)
            }
            
            let affectedGoalCount: number = 0
            const retreievedQuery: FirebaseFirestore.QuerySnapshot[] = await Promise.all(promises)
            retreievedQuery.forEach(query => {
                const retreivedGoals: FirebaseFirestore.DocumentSnapshot[] = query.docs
                retreivedGoals.forEach(async (goal: FirebaseFirestore.DocumentSnapshot) => {
                    const currentAmount: number = goal.get('goalAmountSaved')
                    affectedGoalCount ++
                    totalAmountSaved += currentAmount

                    //Save Key details in Map
                    const id: string = goal.get('uid')
                    const time: FirebaseFirestore.Timestamp = goal.get('thresholdDate')
                    const map = new Map()
                    map.set('uid',id)
                    map.set('time',time)
                    map.set('amount',currentAmount)
                    map.set('doc',goal.id)
                    map.set('interest',goal.get('interest'))
                    map.set('growth',goal.get('growth'))

                    goalDetails.push(map)
                })
            })

            console.log(`Affected Goal Count -> ${affectedGoalCount}`)
            console.log(`Total amount saved for ${data.name} -> ${totalAmountSaved} KES`)
            let amountPayable: number = (totalAmountSaved * data.booking) / 100
            console.log(`Total amount payable for ${data.name} -> ${amountPayable} KES`)

            //Actual Operation
            for (const singleGoal of goalDetails) {
                const amount: number = singleGoal.get('amount')
                const time: FirebaseFirestore.Timestamp = singleGoal.get('time')
                const user: string = singleGoal.get('uid')
                const doc: string = singleGoal.get('doc')

                const leftSideOperation: number = amount / totalAmountSaved
                const nowDate: Date = now.toDate()

                const differenceMilliSeconds = nowDate.getTime() - time.toDate().getTime()
                const differenceDays = Math.ceil(differenceMilliSeconds / (1000*60*60*24))
                const rightSideOpersation: number = differenceDays / periodFromLast
                
                const entireOperation: number = leftSideOperation * rightSideOpersation
                const increment: number = entireOperation * amountPayable

                const growth: number = (increment / amount ) * 100

                await db.collection('users').doc(user).collection('goals').doc(doc).update({
                    goalAmountSaved: superadmin.firestore.FieldValue.increment(increment),
                    interest: superadmin.firestore.FieldValue.increment(increment),
                    growth: superadmin.firestore.FieldValue.increment(growth)
                })
            }

            const batch = db.batch()
            const docRef: FirebaseFirestore.DocumentReference = db.collection('investments').doc(data.title)
            batch.update(docRef, {
                types: superadmin.firestore.FieldValue.arrayRemove({name: data.name, return: data.returnVal, booking: 0})
            })
            batch.update(docRef, {
                types: superadmin.firestore.FieldValue.arrayUnion({name: data.name, return: data.returnVal, booking: data.booking})
            })
            await batch.commit()
            periodFromLast = 0
            affectedGoalCount = 0
            totalAmountSaved = 0
            amountPayable = 0

        } catch (error) {
            throw error
        }
    })