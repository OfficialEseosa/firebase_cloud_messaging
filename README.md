# Firebase Cloud Messaging — Activity 14

A Flutter app demonstrating Firebase Cloud Messaging (FCM) integration for CSC 4360 Mobile App Development.

## What it does

- Requests notification permissions on launch
- Handles incoming FCM messages in all three app states: foreground, background, and terminated
- Displays the FCM device token for use in Firebase Console test sends
- Updates the UI (status text + image) based on the message data payload

## Payload format

```json
{
  "notification": {
    "title": "Activity 14 Test",
    "body": "Check out this image"
  },
  "data": {
    "image": "https://example.com/photo.png"
  }
}
```

The `image` key accepts any public URL. The image displays in the app when a message is received.

## Firebase project

Project ID: `fcm-inclass14-mad`
