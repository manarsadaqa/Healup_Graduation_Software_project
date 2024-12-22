import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while the app is in the foreground');
      showNotification(message.notification?.title ?? 'No title', message.notification?.body ?? 'No body');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification');
      showNotification(message.notification?.title ?? 'No title', message.notification?.body ?? 'No body');
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print("Background message received: ${message.notification?.title}");
    showNotification(message.notification?.title ?? 'No title', message.notification?.body ?? 'No body');
  }

  // Handle showing push notifications
  static Future<void> showNotification(String title, String body) async {
    print('Push Notification: $title - $body');
  }
}
