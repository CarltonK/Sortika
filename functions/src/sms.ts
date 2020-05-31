import { Request, Response } from "express"
import {firestore} from 'firebase-admin'

interface SMS {
    address: string
    body: string
    date: number
    uid: string
}

const db = firestore()

export function receiveSMS(request: Request, response: Response) {
    try {
        const serverRequest = request.body
        const obj = JSON.parse(serverRequest)
        const arrayObjects: Array<SMS> = obj['sms_data']
        
        const unwantedSMS: Array<SMS> = []
        const wantedSMS: Array<SMS> = []
        const miscSMS: Array<SMS> = []
        //Iterate
        for (const iterator of arrayObjects) {
            const body: string = iterator.body.toLowerCase()
            //Weed out unwanted messages
            if (body.includes('failed') || body.includes('wrong') || body.includes('cancelled') 
                || body.includes('m-shwari') || body.includes('cash to') || body.includes('currently underway') 
                || body.includes('confirmed. your account balance was:')) {
                    //Push to unwantedSMS Array
                    unwantedSMS.push(iterator)
                }
            else if (body.includes('confirmed')) {
                wantedSMS.push(iterator)
            }
            else {
                miscSMS.push(iterator)
            }
        }
        
        analyzeWanted(wantedSMS)
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

function analyzeWanted(data: Array<SMS>) {
    //console.log(`Wanted SMS Count: ${wantedSMS.length}`)

    data.forEach(async element => {
        await parseMessage(element)
    })
    //console.log(`Sent SMS Count: ${sentSMS.length}`)
    //console.log(`Received SMS Count: ${receivedSMS.length}`
    
}

// function analyzeMisc(data: Array<SMS>) {
//     console.log(`Misc SMS Count: ${data.length}`)
// }

async function parseMessage(data: SMS) {
    //console.log(`This is a single message: ${data}`)
    //Placeholder for details we need
    const date: firestore.Timestamp = firestore.Timestamp.fromMillis(data.date)

    const msg: string = data.body.toLowerCase()
    //Retrieve transaction code
    //Split via 'confirmed'
    const array_trx_con: Array<string> = msg.toLowerCase().split('confirmed')
    //console.log(array_trx_con)
    const trx_code: string =  array_trx_con[0].toUpperCase()

    //Sent
    if (msg.includes('sent')) {
        const origArray: Array<string> = msg.split('confirmed. ksh')
        const concernedSection: string = origArray[1]
        const amount: string = concernedSection.split(' sent to ')[0]

        //Push to Firestore
        await db.collection('captures').doc().set({
            'transaction_date': date,
            'transaction_code': trx_code,
            'transaction_amount': amount,
            'transaction_type': 'sent',
            'transaction_user': data.uid
        })
        .then(value => {
            console.log('Document added in database')
        })
        .catch(error => {
            console.error(error)
        })
    }
    //Received
    if (msg.includes('received')) {
        const origArray: Array<string> = msg.split('from')
        const concernedSection: string = origArray[0]
        const amount: string = concernedSection.split('ksh')[1]
        
        //Push to Firestore
        await db.collection('captures').doc().set({
            'transaction_date': date,
            'transaction_code': trx_code,
            'transaction_amount': amount,
            'transaction_type': 'received',
            'transaction_user': data.uid
        })
        .then(value => {
            console.log('Document added in database')
        })
        .catch(error => {
            console.error(error)
        })
    }

    console.log('Message parsed successfully')
}