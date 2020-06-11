import * as superadmin from 'firebase-admin'

const fcm = superadmin.messaging()

export async function singleNotificationSend(tokens: Array<string>, message: string, title: string): Promise<void> {
    try {
        if (tokens.length > 0) {
            const payload = {
                notification: {
                    title: title,
                    body: message,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            tokens.forEach(async singleToken => {
                await fcm.sendToDevice(singleToken, payload)
            })
        }
    } catch (error) {
        console.error('singleNotificationSendERROR: ',error)
    }
}
