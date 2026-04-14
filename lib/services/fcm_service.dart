import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

class FCMService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize({required void Function(RemoteMessage) onData}) async {
    // Set up local notifications so foreground messages appear in the tray
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // Create a high-importance channel for FCM
    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'fcm_channel',
          'FCM Notifications',
          importance: Importance.high,
        ));

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      _showLocalNotification(message);
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

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final imageUrl = message.data['image'] ?? notification.android?.imageUrl;
    BigPictureStyleInformation? bigPicture;

    if (imageUrl != null && imageUrl.toString().startsWith('http')) {
      try {
        final response = await http.get(Uri.parse(imageUrl.toString()));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;
          bigPicture = BigPictureStyleInformation(
            ByteArrayAndroidBitmap(bytes),
            contentTitle: notification.title,
            summaryText: notification.body,
          );
        }
      } catch (e) {
        debugPrint('Failed to download notification image: $e');
      }
    }

    await localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'fcm_channel',
          'FCM Notifications',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: bigPicture,
        ),
      ),
    );
  }

  Future<String?> getToken() async {
    final token = await messaging.getToken();
    debugPrint('FCM token: $token');
    return token;
  }
}
