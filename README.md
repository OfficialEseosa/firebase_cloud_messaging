# Firebase Cloud Messaging — Activity 14

A Flutter app demonstrating Firebase Cloud Messaging (FCM) integration for CSC 4360 Mobile App Development.

## What it does

- Requests notification permissions on launch
- Handles incoming FCM messages in all three app states: foreground, background, and terminated
- Displays the FCM device token for use in Firebase Console test sends
- Updates the UI (status text + image) based on the `asset` key in the message data payload

## Payload format

```json
{
  "notification": {
    "title": "Activity 14 Test",
    "body": "Show the promo asset now"
  },
  "data": {
    "asset": "promo",
    "action": "show_animation"
  }
}
```

Supported `asset` values: `default`, `promo`, `alert`.

## Firebase project

Project ID: `fcm-inclass14-mad`
