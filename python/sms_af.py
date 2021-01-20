'''
This Script holds everything SMS related
For debugging purposes, the trigger-event should be set to document update
'''
import africastalking
import logging
import random

log = logging.getLogger(__name__)

def send_verify_sms(phone, uid, client):
    if phone != '':
        phone = phone[1::]
        phone = '+254' + phone

        numbers = []
        numbers.append(phone)

        username = 'pcm'
        key = "aa74a18bd6b9ea15734c26806d14446fd2ee7643a73d35bb02dbec98fe8121d2"

        africastalking.initialize(username, key)
        sms = africastalking.SMS

        code = str(random.randint(0, 9))
        while len(code) < 5:
            code += str(random.randint(1,9))

        try:
            sms.send('Use {} to verify your phone number'.format(code),numbers)
            client.collection("verifications").document(uid).update({'gen_code':code})
            # log.info('Phone verification code sent successfully') 
        except Exception as e:
            log.info('SMS SEND ERROR: {}'.format(e))       
    else:
        log.warning('Phone number not supplied')
