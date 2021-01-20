'''
This script reads data from firestore
1) document create - deposits/{deposit}, func = on_deposit
1) document create - withdrawals/{withdraw}, func = on_withdraw
3) document write - captures/{capture}, func = sms_mpesa_express

For debugging purposes, the trigger-event should be set to document write
gcloud functions deploy on_deposit --region=europe-west1 --runtime python37 --trigger-event providers/cloud.firestore/eventTypes/document.create --trigger-resource projects/sortika-c0f5c/databases/(default)/documents/deposits/{deposit}
'''

import requests
import logging
import firebase_admin
from firebase_admin import firestore, credentials
import lnm as lnm
import sms_af as sms
import b2c as b2c
import math
import json
from google.cloud.firestore_v1 import Increment

cred = credentials.Certificate('sortika-c0f5c-firebase-adminsdk-j7mps-4c2ca8bb56.json')
firebase_admin.initialize_app(cred)

log = logging.getLogger(__name__)
client = firestore.client()
transaction = client.transaction()

#Global Variables

def on_deposit(data, context):
    # Path breakdown
    path_parts = context.resource.split('/documents')[1].split('/')
    # Collection Path
    # collection_path = path_parts[0]
    # log.info('collection path: {}'.format(path_parts))
    # Document Path
    document_path = '/'.join(path_parts[1:])
    # log.info('document path: {}'.format(document_path))
    # User ID
    uid = path_parts[-1]
    # log.info('UID: {}'.format(uid))
    # Data Retrieval
    all_data = data['value']['fields']
    # log.info('data: {}'.format(all_data))
    # The type of data returned should be a dictionary
    # log.info('data type: {}'.format(type(all_data)))
    amount = all_data['amount']['doubleValue']
    destination = all_data['destination']['stringValue']
    goalName = all_data['goalName']
    method = all_data['method']['stringValue']
    phone = all_data['phone']['stringValue']
    uid = all_data['uid']['stringValue']

    try:
        if method == 'M-PESA':
            # Have they supplied a phone number
            if phone != '':
                # Change the format of the phone number
                phone = phone[1::]
                phone = '254' + phone

                # Convert amount to integer
                amount = int(amount)
                # amount = 1

                # Paybill number
                # Production = 287450
                # Sandbox = 174379
                paybill = "287450"

                #Initialize Token
                token = lnm.getAccessToken()
                # log.info('Token: {}'.format(token))

                # retrieve password for transaction
                passDict = lnm.lipaNaMpesaPassword(paybill,token)
                # log.info('PassDict: {}'.format(passDict))

                # send passdict,token and number to actual stk push
                lnm.lipaNaMpesaOnline(passDict,token,phone,amount)
            else:
                log.warning('Phone number not supplied')
        else:
            log.info('The method is {}'.format(method))
    except Exception as e:
        log.error('Error: ${}'.format(e))
        # log.info('Mpesa function complete')


'''
This script reads data from firestore document create
withdrawals/{withdraw}

gcloud functions deploy on_withdraw --region=europe-west1 --runtime python37 --trigger-event providers/cloud.firestore/eventTypes/document.create --trigger-resource projects/sortika-c0f5c/databases/(default)/documents/withdrawals/{withdraw}
'''

def on_withdraw(data, context):
    # Path breakdown
    path_parts = context.resource.split('/documents')[1].split('/')
    # Collection Path
    # collection_path = path_parts[0]
    # log.info('collection path: {}'.format(path_parts))
    # Document Path
    document_path = '/'.join(path_parts[1:])
    # log.info('document path: {}'.format(document_path))
    # User ID
    uid = path_parts[-1]
    # log.info('UID: {}'.format(uid))
    # Data Retrieval
    all_data = data['value']['fields']
    log.info('data: {}'.format(all_data))
    # The type of data returned should be a dictionary
    # log.info('data type: {}'.format(type(all_data)))
    amount = all_data['amount']['doubleValue']
    phone = all_data['phone']['stringValue']

    try:
        # Have they supplied a phone number
        if phone != '':
            # Change the format of the phone number
            phone = phone[1::]
            phone = '254' + phone

            # Convert amount to integer
            amount = int(amount)
            # amount = 1

            #Initialize Token
            token = b2c.getAccessToken()
            # log.info('Token: {}'.format(token))
            b2c.initiate_b2c(token,amount,phone)
        else:
            log.warning('Phone number not supplied')
    except Exception as e:
        log.error('Error: ${}'.format(e))
        # log.info('Mpesa function complete')

'''
This script reads data from firestore document create
capturepushes/{capture}

gcloud functions deploy sms_mpesa_express --region=europe-west1 --runtime python37 --trigger-event providers/cloud.firestore/eventTypes/document.create --trigger-resource projects/sortika-c0f5c/databases/(default)/documents/capturepushes/{capture}
'''
def sms_mpesa_express(data, context):
    # Path breakdown
    path_parts = context.resource.split('/documents')[1].split('/')
    # Collection Path
    # collection_path = path_parts[0]
    # log.info('collection path: {}'.format(path_parts))
    # Document Path
    document_path = '/'.join(path_parts[1:])
    # log.info('document path: {}'.format(document_path))
    # Data Retrieval
    all_data = data['value']['fields']
    # log.info('data: {}'.format(all_data))
    # The type of data returned should be a dictionary
    # log.info('data type: {}'.format(type(all_data)))
    uid = all_data['transaction_user']['stringValue']
    fulfill = all_data['transaction_fulfilled']['booleanValue']

    # retrieve amount and convert to int
    amount = all_data['transaction_amount']['integerValue']
    amount = int(amount) 

    # retrieve user phone number and passive savings rate
    user_doc = client.collection('users').document(uid).get()
    user_doc_data = user_doc.to_dict()
    # log.info('user data: {}'.format(user_doc_data))
    phone = user_doc_data['phone']
    rate = user_doc_data['passiveSavingsRate']

    # Change the format of the phone number
    phone = phone[1::]
    phone = '254' + phone

    amount = ((rate / 100) * amount)
    amount = math.ceil(amount)
    # log.info('final amount: {}'.format(amount))

    if fulfill == False:
        # Paybill number
        # Production = 287450
        # Sandbox = 174379
        paybill = "287450"

        #Initialize Token
        token = lnm.getAccessToken()

        # retrieve password for transaction
        passDict = lnm.lipaNaMpesaPassword(paybill,token)

        # send passdict,token and number to actual stk push
        lnm.lipaNaMpesaOnlineCapture(passDict,token,phone,amount)
    else:
        pass

'''
This script reads data from firestore document create
verifications/{verify}

gcloud functions deploy on_phone_verify_request --region=europe-west1 --runtime python37 --trigger-event providers/cloud.firestore/eventTypes/document.create --trigger-resource projects/sortika-c0f5c/databases/(default)/documents/verifications/{verify}
'''

def on_phone_verify_request(data, context):
    # Path breakdown
    path_parts = context.resource.split('/documents')[1].split('/')
    # Collection Path
    collection_path = path_parts[0]
    # log.info('collection path: {}'.format(collection_path))
    # Document Path
    document_path = '/'.join(path_parts[1:])
    # log.info('document path: {}'.format(document_path))
    # Data Retrieval
    all_data = data['value']['fields']
    # log.info('data: {}'.format(all_data))
    # The type of data returned should be a dictionary
    # log.info('data type: {}'.format(type(all_data)))
    # Retreieve the phone number
    phone = all_data['phone']['stringValue']
    uid = all_data['uid']['stringValue']
    sms.send_verify_sms(phone, uid, client) 

# Transactions
# 1) Wallet
# @firestore.transactional
# def update_wallet(transaction, doc_ref, amount):
#     doc = doc_ref.get(transaction=transaction)
#     transaction.update(doc_ref, {
#         'amount': Increment(amount)
#     })

# # 2) General - Divide between goals based on allocation
# @firestore.transactional
# def general_deposit(transaction, doc_ref, amount):
#     doc = doc_ref.get(transaction=transaction)
#     increment_amount = (amount * doc.get('goalAllocation')) / 100
#     transaction.update(doc_ref, {
#         'goalAmountSaved': Increment(increment_amount)
#     })
