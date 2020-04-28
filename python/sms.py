'''
This script reads data from firestore document create
users/{user}

For debugging purposes, the trigger-event should be set to document update
'''

import requests
import logging
import firebase_admin
from firebase_admin import firestore

log = logging.getLogger(__name__)
client = firestore.client()

def on_user_registration(data, context):
    # Path breakdown
    path_parts = context.resource.split('/documents')[1].split('/')
    # Collection Path
    collection_path = path_parts[0]
    log.info('collection path: {}'.format(collection_path))
    # Document Path
    document_path = '/'.join(path_parts[1:])
    log.info('document path: {}'.format(document_path))
    # Data Retrieval
    all_data = data['value']['fields']
    log.info('data: {}'.format(all_data))
    # The type of data returned should be a dictionary
    log.info('data type: {}'.format(type(all_data)))
    # Retreieve the phone number
    phone = all_data['phone']
    # Initiate a welcome sms
    send_welcome_sms(phone)

    

def send_welcome_sms(phone):
    uname = 'Sortika'
    akey = 'MWQ5MWZiMzAwODMyNzk4NzFjYTlmOT'
    url = 'www.api.254sms.com/version1/send_sms'

    
