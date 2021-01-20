import africastalking
import logging
import random
import firebase_admin
import google.cloud
from firebase_admin import credentials, firestore, auth, messaging
import csv
from datetime import datetime, timedelta

log = logging.getLogger(__name__)

cred = credentials.Certificate('sortika-c0f5c-firebase-adminsdk-j7mps-4c2ca8bb56.json')
app = firebase_admin.initialize_app(cred)

store = firestore.client()

# Spreadsheet
file_path = 'users2.csv'
goal_path = 'goals.csv'

def create_and_add(line):
    try:
        fullName = line['First Name'] + " " + line['Last Name']
        natId = line['ID Number']
        email = line['E-Mail Address']
            
        # Convert to int
        passiveSavingsRate = line['Passive S.P.']
        if passiveSavingsRate.isnumeric():
            passiveSavingsRate = int(line['Passive S.P.'])
        else:
            passiveSavingsRate = 5
        
        loanLimitRatio = line['Loan Limit']
        if loanLimitRatio.isnumeric():
            loanLimitRatio = int(line['Loan Limit'])
        else:
            loanLimitRatio = 5
        
        wallet = line['Wallet Amount']
        if wallet.isnumeric():
            wallet = int(line['Wallet Amount'])
        else:
            wallet = 0
            
        phone = '0' + line['Phone Number']
        # Use phone to filter goals and retrieve saved amount which will be used added to loanfund goal
        loan_fund = 0
        loan_fund += associate_goal_user(phone)
        
        if loan_fund not in [0,'0']:

            # Create a user
            user = auth.create_user(
                email = email,
                email_verified = True,
                password = 'secretPassword',
                disabled = False,
                
            )
            uid = user.uid
            print('Sucessfully created new user: {}'.format(uid))
            
            link = auth.generate_password_reset_link(email)
            
            # Add user document
            store.collection('users').document(uid).set({
                'dailySavingsTarget': 0,
                'designation': None,
                'dob': None,
                'gender': None,
                'kinID': None,
                'kinKraUrl': None,
                'kinName': None,
                'kinNatIdURL': None,
                'kinPhone': None,
                'kinPhotoURL': None,
                'kraURL': None,
                'natIDURL': None,
                'natId': natId,
                'photoURL': None,
                'dailyTarget': 14.24,
                'email': email,
                'phoneVerified': False,
                'fullName': fullName,
                'pre-existing': True,
                'loanLimitRatio': loanLimitRatio,
                'monthlyTarget': 427.39,
                'passiveSavingsRate': passiveSavingsRate,
                'phone': phone,
                'platform': 'android',
                'points': 0,
                'uid': uid,
                'token': uid,
                'weeklyTarget': 99.72,
                'registerDate': firestore.SERVER_TIMESTAMP
            })
            
            # Wallet Collection
            store.collection('users').document(uid).collection('wallet').document(uid).set({
                'amount': wallet
            })
            
            # Notifications
            store.collection('users').document(uid).collection('notifications').document().set({
                'message': 'Welcome to the new and improved Sortika. We listened to you and included new features to make your experience better. Pick up right where you left off. Create your new savings and investment goals. Contact us to redistribute funds to the goals from your loan fund.',
                'time': firestore.SERVER_TIMESTAMP
            })
            
            # Activity
            store.collection('users').document(uid).collection('activity').document().set({
                'activity': 'Welcome to the new and improved Sortika. We listened to you and included new features to make your experience better. Pick up right where you left off',
                'activityDate': firestore.SERVER_TIMESTAMP
            })
            
            # Loan Fund Goal
            # One year from now end date
            now = datetime.now()
            then = now + timedelta(days = 365)

            loan_fund_limit = 5200
            if loan_fund > 5200:
                loan_fund_limit = loan_fund
            
            store.collection('users').document(uid).collection('goals').document().set({
                'goalAllocation': 100,
                'goalAmount': loan_fund_limit,
                'goalAmountSaved': loan_fund,
                'goalClass': None,
                'goalCategory': 'Loan Fund',
                'goalCreateDate': firestore.SERVER_TIMESTAMP,
                'goalEndDate': then,
                'uid': uid,
                'goalName': None,
                'goalType': None,
                'growth': None,
                'interest': None,
                'isGoalDeletable': False
            })

            # Send Link via SMS
            edited_phone = phone[1::]
            edited_phone = '+254' + edited_phone

            numbers = []
            numbers.append(edited_phone) 

            username = 'pcm'
            key = "aa74a18bd6b9ea15734c26806d14446fd2ee7643a73d35bb02dbec98fe8121d2"

            africastalking.initialize(username, key)
            sms = africastalking.SMS

            sms.send('Welcome to the new and improved Sortika. Download the new app from playstore & use the following link to reset your password. {}'.format(link),numbers)
        else:
            pass
    except Exception as e:
        log.error('---IMPORT ERROR---\n{}'.format(e))
    finally:
        log.info('The import function has completed for {}'.format(email))

def associate_goal_user(phone):
    saved_amount = 0
    with open(goal_path,'r') as goals_file:
        csv_goal_reader = csv.DictReader(goals_file, delimiter = ',')
        for line in csv_goal_reader:
            user = line['User']
            if phone == user:
                saved = line['Saved']
                saved_amount += float(saved)
    return saved_amount


with open(file_path, 'r') as csv_file:
    csv_reader = csv.DictReader(csv_file, delimiter = ',')
    for line in csv_reader:
        if line['Status'] == 'ACTIVE':
            if len(line['Phone Number']) == 9:
                create_and_add(line)



# # Test
# associate_goal_user('0719114831')


        