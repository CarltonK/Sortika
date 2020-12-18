import * as functions from 'firebase-functions'
import * as superadmin from 'firebase-admin'

superadmin.initializeApp()

import * as express from 'express'
import * as goals from './goal_allocations'
import * as mpesa from './mpesa'
import * as sms from './sms'
import * as loan from './loan'
import * as scheduled from './scheduled'
import * as lottery from './lottery'
import * as groups from './groups'
import * as redeem from './redeem'
import * as backup from './backup'
import * as bookings from './bookings'
import * as user from './user_management'
import * as creates from './autocreate'
import * as points from './points'

const db = superadmin.firestore()

// Initialize Express Server
const app = express()
const main = express()

// /*
// SERVER CONFIGURATION
// 1) Base Path
// 2) Set JSON as main parser
// */
main.use('/api/v1', app)
main.use(express.json())

//Expose the db
export const firestoreInstance = db

// /*
// API
// */
export const sortikaMain = functions.region('europe-west1').https.onRequest(main)

// M-PESA Endpoints
// 1) Lipa Na Mpesa Online Callback URL
app.post('/nitumiekakitu/0CCX2LkvU7kG8cSHU2Ez', mpesa.mpesaLnmCallback)
//2) Lipa Na Mpesa Online Callback URL (Captures)
app.post('/tumecapturekitu/CBCwudDBSn46CVuz1wnn', mpesa.mpesaLnmCallbackForCapture)
// 2) B2C Timeout URL
app.post('/oyab2cimetimeout/Mm6rm3JwcExVNFk82l9X', mpesa.mpesaB2cTimeout)
// 3) B2C Result URL
app.post('/wolandehb2cimeingia/SV02a3Lpqi883ZNfjIma', mpesa.mpesaB2cResult)
// 4) C2B Validation URL
app.post('/wolandehvalidatec2b/eCcjec4GImjejAm9sfAz', mpesa.mpesaC2bValidation)
// 5) C2B Confirmation URL
app.post('/wolandehconfirmationc2b/e1wlv2pVt0DheiDAPixv', mpesa.mpesaC2bConfirmation)

// 6) SMS ANALYSIS Endpoints
app.post('/tusomerecords/9z5JjD9bGODXeSVpdNFW', sms.receiveSMS)


/*
ALLOCATIONS CALCULATOR
Version 1: onCreate
Version 2: onDelete
Version 3: onWrite - Whenever goalAmountSaved or goalCreateDate changes
*/
export const allocationsCalculatorV1 = goals.AllocationV1
export const allocationsCalculatorV2 = goals.AllocationV2
export const allocationsCalculatorV3 = goals.AllocationV3

export const goalAutoCreate = creates.goalAutoCreate

export const sortikaPoints = points.sortikaPoints

/*
Sortika Points
Record Points every time a transaction is carried out
*/


//User Registration
export const newUser = user.userCreated

//Scheduled Functions
export const currentSavingsRateCalculator = scheduled.scheduledRateCalculator
export const scheduledMidnightFunction =  scheduled.ScheduledMidnightFunction
export const scheduledThresholdFunction =  scheduled.ScheduledThresholdFunction
export const scheduledNotifierFunctionMorning = scheduled.MorningNotifier
export const scheduledNotifierFunctionEvening = scheduled.EveningNotifier

//Lottery Functions
export const joinLottery = lottery.joinALottery
export const announceLottery = lottery.announceLotteryCreation

//Redeem
export const redeemGoal = redeem.RedeemGoal

//Loan Functions
export const loanCreated =  loan.LoanCreate
export const loanUpdate = loan.LoanStatusUpdate
export const loanRepaid = loan.LoanRepaid
export const loanPayment = loan.LoanPayment

//Groups functions
export const groupWrite = groups.groupMembers
export const groupDeletion = groups.deleteGroup

//Backup Function
export const sortikaBackup = backup.SortikaBackup

//Booking Function
export const bookingCalulator = bookings.BookingCalculator







