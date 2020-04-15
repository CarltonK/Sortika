import * as functions from 'firebase-functions'
import * as express from 'express'
import * as bodyParser from "body-parser"
import * as auth from './authentication'


//Initialize Express Server
const app = express();
const main = express();

/*
SERVER CONFIGURATION
1) Base Path
2) Set JSON as main parser
*/
main.use('/api/v1', app);
main.use(bodyParser.json());

//Main Function
export const sortikaMain = functions.https.onRequest(main)


app.post('/users', auth.createUser)

