import { Request, Response} from "express";
import * as admin from 'firebase-admin'
import { UserRecord } from "firebase-functions/lib/providers/auth";

admin.initializeApp()
//Initialize Firebase Authentication
const auth = admin.auth()
//Initialize Firestore
const db = admin.firestore()

class User {
    fullName: string
    phone: string
    email: string
    password: string
    confirmPass: string
    uid: any
    emailVerified: any
    registerDate: any
    photoURL: any
    nationalID: any
    dob: any
    gender: any
    idetifierURL: any
    kraURL: any

    constructor(fullName:string, phone: string, email: string, password: string, 
        confirmPass: string) { 

        this.fullName = fullName
        this.phone = phone
        this.email = email
        this.password = password
        this.confirmPass = confirmPass

    }
}


/*
CREATE A USER
POST Endpoint: /users
Required fields:
1) fullName - Must contain a space
2) phone - Must be 10 digits, must start with "07"
3) email - Must contain "@"
4) password - Must be 7 characters or more
5) confirmPass - Must be equal to password
*/

export async function createUser (request: Request, response: Response) {
    try {
        //Request header
        request.headers = {'Content-Type':'application/json'}

        const user:User = {
            fullName: request.body['fullName'],
            phone: request.body['phone'],
            email: request.body['email'],
            password: request.body['password'],
            confirmPass: request.body['confirmPass'],
            uid: null,
            emailVerified: false,
            registerDate: new Date(),
            photoURL: null,
            nationalID: null,
            dob: null,
            gender: null,
            idetifierURL: null,
            kraURL: null
            
        }

        if (!user.fullName || !user.phone || !user.email || !user.password || !user.confirmPass) {
            return response.status(400).send({
                status: false,
                message: 'One or more fields are missing'
            })
        }

        if (!user.fullName.includes(' ')) {
            return response.status(400).send({
                status: false,
                message: "Your full name must contain a space between your names"
            })
        }

        if (!user.phone.startsWith('07')) {
            return response.status(400).send({
                status: false,
                message: 'You phone number must start with 07'
            })
        }

        if (user.phone.length != 10) {
            return response.status(400).send({
                status: false,
                message: 'You phone number must be 10 digits'
            })
        }

        if (!user.email.includes('@')) {
            return response.status(400).send({
                status: false,
                message: "Your email must contain @"
            })
        }

        if (user.password.length < 8 && user.confirmPass.length < 8) {
            return response.status(400).send({
                status: false,
                message: "Your password is weak. A strong password has 7 or more characters and includes a mixture of lower case characters, upper case characters, numbers and symbols"
            })
        }

        if (user.confirmPass != user.password) {
            return response.status(400).send({
                status: false,
                message: "Passwords do not match"
            })
        }

        //Create a user
        const newUser: UserRecord = await auth.createUser({
            displayName: user.fullName,
            email: user.email,
            password: user.password
        })
        console.log(`USER: ${JSON.stringify(newUser)}`)

        //Get uid and assign to user
        const uid: string = newUser.uid
        user.uid = uid

        //Remove passwords
        user.password = ''
        user.confirmPass = ''

        //Store user details in Firestore collection "users"
        await db.collection('users').doc(uid).create(user)

        //Return 201 - Account created
        return response.status(201).send({
            status: true,
            //Personalized welcome message using first name
            message: `Welcome to Sortika ${user.fullName.split(' ')[0]}`,
            uid: uid 
        }) 
    }
    catch (error) {
       return handleError(response, error)
    }
}

//Error Handler
function handleError(response: Response, error: any) {
    return response.status(500).send({status: false ,message: `${error.message}`});
 }
