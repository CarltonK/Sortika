import { Request, Response } from "express"
import {firestore} from 'firebase-admin'
import * as _ from "lodash"

interface SMS {
    address: string
    body: string
    date: number
    uid: string
}

const db = firestore()

export function receiveSMS(request: Request, response: Response) {
    try {
        //Receive JSON and parse to SMS interface
        const serverRequest = request.body
        const obj = JSON.parse(serverRequest)
        const arrayObjects: Array<SMS> = obj['sms_data']
        const arrayPast: Array<SMS> = obj['past_data']
        
        const unwantedSMS: Array<SMS> = []
        const wantedSMS: Array<SMS> = []
        const miscSMS: Array<SMS> = []
        
        for (const iterator of arrayObjects) {
            const body: string = iterator.body.toLowerCase()
            //Weed out unwanted messages
            if (body.includes('failed') || body.includes('wrong') || body.includes('cancelled') 
                || body.includes('m-shwari') || body.includes('cash to') || body.includes('currently underway') 
                || body.includes('account balance')) {
                    //Push to unwantedSMS Array
                    unwantedSMS.push(iterator)
            }
            //!!!---This is what we want---!!!
            else if (body.includes('confirmed') && (body.includes('sent to') || body.includes('received'))) {
                wantedSMS.push(iterator)
            }
            //Go ahead and dump the rest
            else {
                miscSMS.push(iterator)
            }
        }

        analyzeWanted(wantedSMS) 
        savePastSMS(arrayPast)
        //analyzeUnwanted(unwantedSMS)
        //analyzeMisc(miscSMS)
        
        response.status(200).json({status: true, "message": "SMS data retrieved successfully"})
    } catch (error) {
        response.status(400).json({status: false, "message": `${error}`})
    }
}
        
// function analyzeUnwanted(data: Array<SMS>) {
//     console.log(`Unwanted SMS Count: ${data.length}`)
// }

function savePastSMS(data: Array<SMS>) {
    // const batch = db.batch()
    // let counter: number = 0
    // for (const doc of data) {
    //     if (doc.body.includes('confirmed')) {
    //         let trx_code: string = doc.body.toLowerCase().split(' confirmed')[0].toUpperCase()
    //         trx_code = (trx_code.includes('CONGRATULATIONS')) ? trx_code.split('CONGRATULATIONS! ')[1] : trx_code
    //         const docRef: FirebaseFirestore.DocumentReference = db.collection('sms').doc(doc.uid).collection('history').doc(trx_code)
    //         batch.set(docRef, {
    //             'address': doc.address,
    //             'body': doc.body,
    //             'date': doc.date
    //         })
    //         counter++
    //         if (counter === 450) {
    //             batch.commit()
    //                 .then(value => {
    //                     console.log('A batch has been committed successfully')
    //                     counter = 0
    //                 })
    //                 .catch(error => console.error('A batch operation has failed', error))
    //         }
    //     }
    // }
    const batches = _.chunk(data, 450).map(async docs => {
        const batch = db.batch()
        docs.forEach(doc => {
            if (doc.body.includes('confirmed')) {
                let trx_code: string = doc.body.toLowerCase().split(' confirmed')[0].toUpperCase()
                const docRef: FirebaseFirestore.DocumentReference = db.collection('sms').doc(doc.uid).collection('history').doc(trx_code)
                batch.set(docRef, {
                    'address': doc.address,
                    'body': doc.body,
                    'date': doc.date
                })
            }
        })
        await batch.commit()
    })
    
    Promise.all(batches)
        .then(value => console.log('past SMS ingested'))
        .catch(error => console.error('write past sms batch ERROR', error))
}

function analyzeWanted(data: Array<SMS>) {
    //console.log(`Wanted SMS Count: ${wantedSMS.length}`)
    if (data.length >= 1) {
        const batch = db.batch()
        let amountTotal: number = 0
        const uid: string = data[0].uid
        const promises: Promise<number>[] = [];

        data.forEach(element => {
            promises.push(parseMessage(element))
        })

        Promise.all(promises).then(numbers => {
            numbers.forEach(value => {
                amountTotal += value
            })
            // console.log(`Amount captured for ${uid} is ${amountTotal} KES`)
            const captureDocRef: FirebaseFirestore.DocumentReference = db.collection('capturepushes').doc()
            const userRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid)
            const now: firestore.Timestamp = firestore.Timestamp.now()
            batch.set(captureDocRef, {
                'transaction_user': uid,
                'transaction_fulfilled': false,
                'transaction_amount': amountTotal,
                'transaction_time': now
            })
            batch.update(userRef, {lastLogin: now})

            batch.commit()
                .then(value => console.log('SMS Analyzed successfully and sent for STK processing'))
                .catch(error => console.error('Analyze Wanted SMS ERROR',error))
        })
        .catch(error => console.error('Parse Message Promise ERROR',error));
    }
}

// function analyzeMisc(data: Array<SMS>) {
//     console.log(`Misc SMS Count: ${data.length}`)
// }

async function parseMessage(data: SMS): Promise<number> {
    //console.log(`This is a single message: ${data}`)
    //Placeholder for details we need
    const date: firestore.Timestamp = firestore.Timestamp.fromMillis(data.date)
    const msg: string = data.body.toLowerCase()
    //Retrieve transaction code
    //Split via 'confirmed'
    const array_trx_con: Array<string> = msg.toLowerCase().split(' confirmed')
    //console.log(array_trx_con)
    const trx_code: string =  array_trx_con[0].toUpperCase()
    // console.log(`Incoming message bears the transaction code: ${trx_code}`)
    let amountCaptured: number = 0

    try {
        //Check if transaction is Sortika Related
        const sortikaTransQuery = await db.collection('transactions').where('transactionCode','==',trx_code).get()
        const queryDocs: FirebaseFirestore.DocumentSnapshot[] = sortikaTransQuery.docs
        if (queryDocs.length === 0 || queryDocs === null) {
            if (msg.includes('sent')) {
                const origArray: Array<string> = msg.split('confirmed. ksh')
                const concernedSection: string = origArray[1]
                let amount: string = concernedSection.split(' sent to ')[0]
                amount = (amount.includes(',')) ? (amount.split(',')[0] + amount.split(',')[1]) : amount
                console.log(`Amount - ${amount}`)

                await db.collection('captures').doc().set({
                    'transaction_date': date,
                    'transaction_recorded': firestore.Timestamp.now(),
                    'transaction_code': trx_code,
                    'transaction_amount': amount,
                    'transaction_type': 'sent',
                    'transaction_user': data.uid,
                    'transaction_fulfilled': false
                })

                await db.collection('users').doc(data.uid).collection('notifications').doc().set({
                    'message': `A message with the M-PESA transaction code ${trx_code} has been captured as an expense`,
                    'time': firestore.Timestamp.now(),
                })

                const amountFormatted: string = amount.split('.')[0]
                amountCaptured += Number(amountFormatted)
                console.log(`Amount captured from ${trx_code} is ${amountCaptured} KES`)

                console.log(`An expense with the M-PESA transaction code ${trx_code} has been captured for ${data.uid}`)

                return amountCaptured
            }
            //Received
            if (msg.includes('received')) {
                const origArray: Array<string> = msg.split('from')
                const concernedSection: string = origArray[0]
                let amount: string = concernedSection.split('ksh')[1]
                amount = (amount.includes(',')) ? (amount.split(',')[0] + amount.split(',')[1]) : amount
                console.log(`Amount - ${amount}`)

                await db.collection('captures').doc().set({
                    'transaction_date': date,
                    'transaction_recorded': firestore.Timestamp.now(),
                    'transaction_code': trx_code,
                    'transaction_amount': amount,
                    'transaction_type': 'received',
                    'transaction_user': data.uid,
                    'transaction_fulfilled': false
                })

                await db.collection('users').doc(data.uid).collection('notifications').doc().set({
                    'message': `A message with the M-PESA transaction code ${trx_code} has been captured as an income`,
                    'time': firestore.Timestamp.now(),
                })

                const amountFormatted: string = amount.split('.')[0]
                amountCaptured += Number(amountFormatted)
                console.log(`Amount captured from ${trx_code} is ${amountCaptured} KES`)

                console.log(`An expense with the M-PESA transaction code ${trx_code} has been captured for ${data.uid}`)
                
                return amountCaptured
            }
        }
        console.log('Message parsed successfully')
        return amountCaptured
    } catch (error) {
        throw error
    }
}