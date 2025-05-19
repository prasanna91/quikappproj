import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/env_config.dart';
import '../module/myapp.dart';
import '../services/notification_service.dart';
import '../utils/menu_parser.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initLocalNotifications();

  if (pushNotify) {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      if (kDebugMode) {
        print("✅ Firebase initialized successfully");
      }
      await initializeFirebaseMessaging();
    } catch (e) {
      if (kDebugMode) {
        print("🚨 Firebase initialization failed: $e");
      }
    }
  } else {
    debugPrint("🚫 Firebase not initialized (pushNotify: $pushNotify)");
  }

  if (webUrl.isEmpty) {
    debugPrint("❗ Missing WEB_URL environment variable.");
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text("WEB_URL not configured.")),
      ),
    ));
    return;
  }

  debugPrint("""
    🛠 Runtime Config:
    - pushNotify: $pushNotify
    - webUrl: $webUrl
    - isSplash: $isSplashEnabled,
    - splashLogo: $splashUrl,
    - splashBg: $splashBgUrl,
    - splashDuration: $splashDuration,
    - splashAnimation: $splashAnimation,
    - taglineColor: $splashTaglineColor,
    - spbgColor: $splashBgColor,
    - isBottomMenu: $isBottomMenu,
    - bottomMenuItems: ${parseBottomMenuItems(bottomMenuRaw)},
    - isDeeplink: $isDeepLink,
    - backgroundColor: $bottomMenuBgColor,
    - activeTabColor: $bottomMenuActiveTabColor,
    - textColor: $bottomMenuTextColor,
    - iconColor: $bottomMenuIconColor,
    - iconPosition: $bottomMenuIconPosition,
    - Permissions:
      - Camera: $isCameraEnabled
      - Location: $isLocationEnabled
      - Mic: $isMicEnabled
      - Notification: $isNotificationEnabled
      - Contact: $isContactEnabled
    """);

  runApp(MyApp(
    webUrl: webUrl,
    isSplash: isSplashEnabled,
    splashLogo: splashUrl,
    splashBg: splashBgUrl,
    splashDuration: splashDuration,
    splashAnimation: splashAnimation,
    taglineColor: splashTaglineColor,
    spbgColor: splashBgColor,
    isBottomMenu: isBottomMenu,
    bottomMenuItems: parseBottomMenuItems(bottomMenuRaw),
    isDeeplink: isDeepLink,
    backgroundColor: bottomMenuBgColor,
    activeTabColor: bottomMenuActiveTabColor,
    textColor: bottomMenuTextColor,
    iconColor: bottomMenuIconColor,
    iconPosition: bottomMenuIconPosition,
    isLoadIndicator: isLoadIndicator,
  ));
}
