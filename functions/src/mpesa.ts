import { Request, Response } from "express";
import * as superadmin from 'firebase-admin'
import { DocumentSnapshot } from "firebase-functions/lib/providers/firestore";

//M-PESA RESPONSE INTERFACE
export interface MpesaResponse {
    Body: Body;
}

export interface Body {
    stkCallback: StkCallback;
}

export interface StkCallback {
    MerchantRequestID: string;
    CheckoutRequestID: string;
    ResultCode:        number;
    ResultDesc:        string;
    CallbackMetadata:  CallbackMetadata;
}

export interface CallbackMetadata {
    Item: Item[];
}

export interface Item {
    Name:   string;
    Value?: number | string;
}

// Converts JSON strings to/from your types
export class Convert {
    public static toMpesaResponse(json: string): MpesaResponse {
        return JSON.parse(json);
    }

    public static mpesaResponseToJson(value: MpesaResponse): string {
        return JSON.stringify(value);
    }
}

export function mpesaCallback(request: Request, response: Response) {
    try {
        console.log('---Received Safaricom M-PESA Webhook---')
        const serverRequest = request.body
        //Get the ResponseCode
        const code: number = serverRequest['Body']['stkCallback']['ResultCode']
        if (code === 0) {
            const transactionAmount: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][0]['Value']
            const transactionCode: string = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][1]['Value']
            const transactionTime: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][3]['Value']
            const transactionPhone: number = serverRequest['Body']['stkCallback']['CallbackMetadata']['Item'][4]['Value']

            console.log(`Amount: ${transactionAmount}`)
            console.log(`Code: ${transactionCode}`)
            console.log(`Time: ${transactionTime}`)
            console.log(`Phone: ${transactionPhone}`)

            let transactionPhoneFormatted: string = transactionPhone.toString().slice(3)
            transactionPhoneFormatted = "0" + transactionPhoneFormatted

            console.log(transactionPhoneFormatted)

            const db = superadmin.firestore()
            //Search for user with matching phone number
            db.collection('users').where('phone' ,'==', transactionPhoneFormatted).limit(1).get()
                .then(async (value) => {
                    if (value.docs.length === 1) {
                        await db.collection('transactions').doc(transactionCode).set({
                            'transactionAmount': transactionAmount,
                            'transactionCode': transactionCode,
                            'transactionTime': transactionTime,
                            'transactionPhone': transactionPhone,
                        })

                        const document: DocumentSnapshot = value.docs[0]
                        const uid: string = document.get('uid')

                        const docRef: FirebaseFirestore.DocumentReference = db.collection('users').doc(uid).collection('wallet').doc(uid);
                        db.runTransaction(async transaction => {
                            return transaction.get(docRef)
                                .then(doc => {
                                    transaction.update(docRef, {amount: superadmin.firestore.FieldValue.increment(transactionAmount)})
                                });
                        })
                        .then(result => {
                            console.log('Transaction success')
                        })
                        .catch(err => {
                            console.log('Transaction failure:', err)
                        })
                    }
                })
                .catch((error) => {
                    console.error(error)
                })
        }

        //Send a Response back to Safaricom
        const message = {
            "ResponseCode": "00000000",
	        "ResponseDesc": "success"
        }
        response.json(message)
    } catch (error) {
        console.error(error)
    }
}