import * as superadmin from 'firebase-admin'
import * as functions from 'firebase-functions'

const db = superadmin.firestore()

export const groupMembers = functions.region('europe-west1').firestore
    .document('groups/{group}')
    .onWrite(async snapshot => {
        try {
            //const admin: string = snapshot.before.get('groupAdmin')
            const membersBefore: Array<string> = snapshot.before.get('members')
            const membersAfter: Array<string> = snapshot.after.get('members');
            console.log(`Members Before: ${membersBefore}`)
            console.log(`Members After: ${membersAfter}`)

            if (!snapshot.before.exists) {
                membersAfter.forEach(async (element) => {
                    const user: FirebaseFirestore.DocumentSnapshot = await db.collection('users').doc(element).get()
                    //console.log(`Requesting USER: ${user.get('uid')}`)
                    await db.collection('groups').doc(snapshot.after.id).collection('members').doc(element).set({
                        "fullName": user.get('fullName'),
                        "photoURL": user.get('photoURL'),
                        "token": user.get('token'),
                    })
                })
            }
            if (!snapshot.after.exists) {
                deleteGroup
            }
            if (snapshot.before.exists && snapshot.after.exists) {
                if (membersAfter.length > membersBefore.length) {
                    const diff: number = membersAfter.length - membersBefore.length
                    await db.collection('groups').doc(snapshot.after.id).update({
                        'groupMembers': superadmin.firestore.FieldValue.increment(diff)
                    });
                }
                if (membersBefore.length > membersAfter.length) {
                    const diff: number = membersBefore.length - membersAfter.length
                    await db.collection('groups').doc(snapshot.after.id).update({
                        'groupMembers': superadmin.firestore.FieldValue.increment(-diff)
                    });
                }

                for (let index = 0; index < membersAfter.length; index ++) {
                    if (membersBefore[index] === membersAfter[index]) {
                        continue
                    }
                    else {
                        const user: FirebaseFirestore.DocumentSnapshot = await db.collection('users').doc(membersAfter[index]).get()
                        console.log(`Requesting USER: ${user.get('uid')}`)
                        await db.collection('groups').doc(snapshot.after.id).collection('members').doc(membersAfter[index]).set({
                            "fullName": user.get('fullName'),
                            "photoURL": user.get('photoURL'),
                            "token": user.get('token'),
                        })
                    }
                }
            }
        } catch (error) {
            throw error
        }
    })

export const deleteGroup = functions.region('europe-west1').firestore
    .document('groups/{group}')
    .onDelete(async snapshot => {
        const uid: string = snapshot.id
        const queries: FirebaseFirestore.QuerySnapshot = await db.collection('groups').doc(uid).collection('members').get()
        try {
            queries.forEach(async (element) => {
                await db.collection('groups').doc(uid).collection('members').doc(element.id).delete()
            })
        } catch (error) {
            throw error
            
        }
    })