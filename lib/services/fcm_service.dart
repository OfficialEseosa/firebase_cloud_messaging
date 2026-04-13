import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize({required void Function(RemoteMessage) onData}) async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      onData(message);
    });

    // App opened from background via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened app from background: ${message.messageId}');
      onData(message);
    });

    // App launched from terminated state via notification tap
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Initial message on cold start: ${initialMessage.messageId}');
      onData(initialMessage);
    }
  }

  Future<String?> getToken() async {
    final token = await messaging.getToken();
    debugPrint('FCM token: $token');
    return token;
  }
}
