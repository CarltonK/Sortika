import * as superadmin from 'firebase-admin'
import * as functions from 'firebase-functions'
import * as notification from './notification'

const db = superadmin.firestore()
const now: FirebaseFirestore.Timestamp = superadmin.firestore.Timestamp.now()

/*
Create a Loan Fund Goal
Create a Wallet
Create an activity
Create and send a notification
Send an FCM
*/

export const userCreated = functions.region('europe-west1').firestore
    .document('/users/{user}')
    .onCreate(async snapshot => {
        try {
            const token: string = snapshot.get('token')
            const uid: string = snapshot.get('uid')
            const fullName: string = snapshot.get('fullName')
            const firstName: string = fullName.split(' ')[0]
            const tokens: string[] = [token]
    
            const userRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid)
            const batch = db.batch()
    
            //1) Loan Fund Goal
            const loanFundRef: FirebaseFirestore.DocumentReference = userRef.collection('goals').doc()
            const oneYearFromNow: FirebaseFirestore.Timestamp = superadmin.firestore.Timestamp.fromDate(new Date(now.toDate().getTime() + (1000 * 60 * 60 * 24 * 365)))
            batch.set(loanFundRef, {
                goalAllocation: 100,
                goalAmount: 5200,
                goalAmountSaved: 0,
                goalCategory: 'Loan Fund',
                goalClass: null,
                goalCreateDate: now,
                goalEndDate: oneYearFromNow,
                goalName: null,
                goalType: null,
                growth: null,
                interest: null,
                isGoalDeletable: false,
                uid: uid
            })
            //2) Wallet
            const walletRef: FirebaseFirestore.DocumentReference = userRef.collection('wallet').doc(uid)
            batch.set(walletRef, {
                amount: 0
            })
    
            //3) Activity
            const activityRef: FirebaseFirestore.DocumentReference = userRef.collection('activity').doc()
            batch.set(activityRef, {
                activity: 'Welcome to Sortika',
                activityDate: now
            })
    
            //4) Notification
            const notifyRef: FirebaseFirestore.DocumentReference = userRef.collection('notifications').doc()
            batch.set(notifyRef, {
                message: `We are glad to have you on board ${firstName}. Thank you for joining Sortika. We have awarded you 100 savings points`,
                time: now
            })
    
            //5) FCM
            await notification.singleNotificationSend(tokens,`We are glad to have you on board ${firstName}. Thank you for joining Sortika. We have awarded you 100 savings points`,'Welcome')

            //6) Update lastlogin to now
            batch.update(userRef, {lastLogin: now})
            await batch.commit()
        } catch (error) {
            throw error
        }
    })

