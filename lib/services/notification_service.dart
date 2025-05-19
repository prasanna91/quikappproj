import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings, onDidReceiveNotificationResponse: (response) {
    debugPrint("🔔 Notification tapped: ${response.payload}");
  });
}

Future<void> initializeFirebaseMessaging() async {
  // await Firebase.initializeApp(options: await loadFirebaseOptionsFromJson());
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.setAutoInitEnabled(true);
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  messaging.getToken().then((token) => debugPrint("✅ FCM Token: $token"));

  FirebaseMessaging.onBackgroundMessage((message) async {
    await Firebase.initializeApp();
    debugPrint("🔔 Background message: ${message.messageId}");
  });
}
