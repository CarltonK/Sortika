'''
B2C
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
        consumer_key = "lwi5J03VlKtbxel9xcz13SWH4kFaCz0q"
        consumer_secret = "9bif4W1BgmITsUD9"
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
        log.error('---ACCESS TOKEN EXCEPTION---\n{}'.format(e))
        return False
    finally:
        # Close the connection
        r.close()


def initiate_b2c(token,amount,phone):
    if token == False:
        print('The token could not be generated')
    else:
        # B2C - 193293
        # Request URL
        # Sandbox - https://sandbox.safaricom.co.ke/mpesa/b2c/v1/paymentrequest
        # Production - https://api.safaricom.co.ke/mpesa/b2c/v1/paymentrequest
        api_url = 'https://api.safaricom.co.ke/mpesa/b2c/v1/paymentrequest'
        # Request Header
        headers = { "Authorization": "Bearer {}".format(token)}
        try:
            request = {
                "InitiatorName": "Bundi",
                "SecurityCredential":"l12lxysBDwP/6VOUAFcqvpt+7bnYWb2rWCeVcE4Bn2uJTPDhJTl5mW/KbVdWq+Djt3DYVmRu6DzoOmJBYRMdkov1ng3ZDH8J+wFcUqVV4KV6kmq7tXPXuQ7KUTGYdmIrc33pOJ7ev/PlDxmazKNZZPA1a9dNO9pliE1bsqSaE78D9wOXFJ6C1FaayBTDBXELahKUduZgu3+a94FpXDRsUP+oiP0JMr9I8/j+HtX6KQsmOKODHSfO33s2LJpxwiQZvOBzdLnrKCtkjQ18/qNjA/3F3KICy9jPOHnrGdjHXp22G5ipOHid9gFNL3R2GnJqq8Jgyq65ANtkyExIMh/wEA==",
                "CommandID": "BusinessPayment",
                "Amount": amount,
                "PartyA": 193293,
                "PartyB": phone,
                "Remarks": "You have withdrawn KES 1 from your wallet",
                "QueueTimeOutURL": "https://europe-west1-sortika-c0f5c.cloudfunctions.net/sortikaMain/api/v1/oyab2cimetimeout/Mm6rm3JwcExVNFk82l9X",
                "ResultURL": "https://europe-west1-sortika-c0f5c.cloudfunctions.net/sortikaMain/api/v1/wolandehb2cimeingia/SV02a3Lpqi883ZNfjIma",
                "Occasion": "Wallet withdrawal"
            }
            # Actual request
            b2c_request = requests.post(api_url, json=request, headers=headers)
        except Exception as e:
            log.error('---B2C EXCEPTION---\n{}'.format(e))
        finally:
            b2c_request.close()