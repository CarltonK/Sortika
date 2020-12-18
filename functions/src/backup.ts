import * as functions from 'firebase-functions'
const fb = require('simple-firestore-backup')

export const SortikaBackup = functions.region('europe-west1').runWith({
    timeoutSeconds: 540, 
    memory: '512MB', 
}).pubsub.schedule('every 48 hours').onRun(fb.createBackupHandler(
    'backup-storage-bucket-sortika', // Optionally: The Google Cloud Storage Bucket to use (without gs://). Use the name you gave your bucket in step 1 or remove this line if you skipped step 1. Defaults to the default bucket ('your-project-id.appspot.com')
    'firestore', // Optionally: the path inside the bucket. Defaults to 'firestore'
    'default' // Optionally: the Firestore instance id to backup. If you did not create a second Firestore instance, you can leave this out. Defaults to '(default)'
  ))