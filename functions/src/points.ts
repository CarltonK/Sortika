import * as functions from 'firebase-functions'
import * as superadmin from 'firebase-admin'

const db = superadmin.firestore()

export const sortikaPoints = functions.region('europe-west1').firestore
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
            console.log(error)
        }  
    })