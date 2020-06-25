const assert = require('assert')
const firebase = require('@firebase/testing')

const MY_PROJECT_ID = 'sortika-c0f5c'
const MY_ID = 'user_abc'
const THEIR_ID = 'user_xyz'
const MY_AUTH = {uid: 'user_abc', email: 'user_abc@test.com'}

function getFirestore(auth) {
    return firebase.initializeTestApp({projectId: MY_PROJECT_ID, auth: MY_AUTH}).firestore()
}
// Call firestore with argument 'null' where sign in is not essential

describe('Sortika',() => {
    // Anyone can read
    it('Can read items in a read-only collection', async () => {
        const db = getFirestore(null)
        const testDoc = db.collection('readonly').doc('testDoc')
        await firebase.assertSucceeds(testDoc.get())
    })

    // No one can write
    //  Test will pass if the request fails
    it ('Can\'t write in a read-only collection', async () => {
        const db = getFirestore(null)
        const testDoc = db.collection('readonly').doc('anotherDoc')
        await firebase.assertFails(testDoc.set({foo: 'bar'}))
    })


    // User can't write to another users document
    it('Can\'t write to a user doc with a different uid as our user', async () => {
        const db = getFirestore(MY_AUTH)
        const testDoc = db.collection('users').doc(THEIR_ID)
        await firebase.assertFails(testDoc.set({foo: 'bar'}))
    })

    // Only owner can write to their document
    it('Can write to a user doc with same uid as our user', async () => {
        
        const db = getFirestore(MY_AUTH)
        const testDoc = db.collection('users').doc(MY_ID)
        await firebase.assertSucceeds(testDoc.set({foo: 'bar'}))
    })

})