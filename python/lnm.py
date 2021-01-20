'''
Lipa Na Mpesa
'''
import requests
from requests.auth import HTTPBasicAuth
import json
from datetime import datetime
import base64
import logging

log = logging.getLogger(__name__)

def getAccessToken():
    try:
        # Consumer key and secret are required
        consumer_key = "lJKCm77DSreze78TlW2ZVaoA9DSNp31n"
        consumer_secret = "67KGqmsFFeNsfLRT"
        # Endpoint
        api_url = "https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
        # Initialize the request
        r = requests.get(api_url, auth=HTTPBasicAuth(consumer_key, consumer_secret))
        # Get the status code and issue response based on that
        
        if r.status_code == 200:
            # print('Success')
            # Convert object from string notation to object
            data = json.loads(r.text)
            # Retrieve the access token from the dictionary
            access_token = data["access_token"]
            # print('Your access token is {}'.format(access_token))
            # log.info('---TOKEN---\n{}'.format(access_token))
            return access_token
        else:
            # print('Fail')
            # print('The status code is {}'.format(r.status_code))
            log.info('---ACCESS TOKEN ERROR---\nSTATUS CODE \t{}\nRESPONSE \t{}\nCAUSE \t{}'.format(r.status_code,r.text,r.reason))
            return False

    except Exception as e:
        # print('This is the exception: \n{}'.format(e))
        log.error('---ACCESS TOKEN EXCEPTION---\nEXCEPTION \t{}'.format(e))
        return False
    finally:
        # Close the connection
        r.close()

# token = getAccessToken()
# print('Token: {}'.format(token))
# print('...XXX...XXX...XXX...')

def lipaNaMpesaPassword(paybill,token):
    if token == False:
        print('The token could not be generated')
    else:
        try:
            #Get current time
            pay_time = datetime.now().strftime('%Y%m%d%H%M%S')
            #Paybill or Till Number
            Business_short_code = paybill
            #Passkey provided in sandbox
            passkey = 'de5f48c37e649d3dd7956281187b06b397fcfce602b0739db80afd898634e7a6'

            #Concatenate the above three pieces of data for encoding
            data_to_encode = Business_short_code + passkey + pay_time
            #Actual encoding to base64 string
            online_password = base64.b64encode(data_to_encode.encode())
            #decode to UTF-8
            decode_password = online_password.decode('utf-8')
            # log.info('---PASSWORD GENERATOR RESULTS---\nTIME \t{}\nPAYBILL \t{}\nPASSWORD \t{}'.format(pay_time,Business_short_code,decode_password))
            return {"time":pay_time,"code":Business_short_code,"pass":decode_password}
        except Exception as e:
            # print('This is the exception {}'.format(e))
            log.error('---PASSWORD GENERATE EXCEPTION---\n{}'.format(e))
            return False

# #Paybill should be a string
# paybill = "287450"
# passDict = lipaNaMpesaPassword(paybill, token)
# print(passDict)
# print('...XXX...XXX...XXX...')

def lipaNaMpesaOnline(pass_dict,access_token,number,amount):
    if pass_dict == False:
        print('There was an error generating the password')
    else:
        code = pass_dict['code']
        time = pass_dict['time']
        pass_decoded = pass_dict['pass']

        try:
            #Stk Url
            stk_url = "https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
            #Request header
            stk_header = {"Authorization": "Bearer {}".format(access_token)}
            request = {
                "BusinessShortCode": code,
                "Password": pass_decoded,
                "Timestamp": time,
                "TransactionType": "CustomerPayBillOnline",
                "Amount": amount,
                "PartyA": number,  # replace with your phone number to get stk push
                "PartyB": code,
                "PhoneNumber": number,  # replace with your phone number to get stk push
                "CallBackURL": "https://europe-west1-sortika-c0f5c.cloudfunctions.net/sortikaMain/api/v1/nitumiekakitu/0CCX2LkvU7kG8cSHU2Ez",
                "AccountReference": number,
                "TransactionDesc": "Deposit"
            }
            #Initiate the POST request
            response = requests.post(stk_url, json=request, headers=stk_header)
        except Exception as e:
            # print('This is the exception: \n{}'.format(e))
            log.error('---STK PUSH EXCEPTION---\n{}'.format(e))
        finally:
            response.close()

# lipaNaMpesaOnline(passDict, token,254727286123,1)

def lipaNaMpesaOnlineCapture(pass_dict,access_token,number,amount):
    if pass_dict == False:
        print('There was an error generating the password')
    else:
        code = pass_dict['code']
        time = pass_dict['time']
        pass_decoded = pass_dict['pass']

        try:
            #Stk Url
            stk_url = "https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
            #Request header
            stk_header = {"Authorization": "Bearer {}".format(access_token)}
            request = {
                "BusinessShortCode": code,
                "Password": pass_decoded,
                "Timestamp": time,
                "TransactionType": "CustomerPayBillOnline",
                "Amount": amount,
                "PartyA": number,  # replace with your phone number to get stk push
                "PartyB": code,
                "PhoneNumber": number,  # replace with your phone number to get stk push
                "CallBackURL": "https://europe-west1-sortika-c0f5c.cloudfunctions.net/sortikaMain/api/v1/tumecapturekitu/CBCwudDBSn46CVuz1wnn",
                "AccountReference": number,
                "TransactionDesc": "Passive Saving"
            }
            #Initiate the POST request
            response = requests.post(stk_url, json=request, headers=stk_header)
        except Exception as e:
            log.error('---STK PUSH EXCEPTION---\n{}'.format(e))
        finally:
            response.close()

# lipaNaMpesaOnlineCapture(passDict, token,254727286123,1)