import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

Future<FirebaseOptions> loadFirebaseOptionsFromJson() async {
  try {
    if (kDebugMode) {
      print("🔍 Loading google-services.json from assets...");
    }

    // Load the JSON file as a string
    final String jsonStr =
        await rootBundle.loadString('android/app/google-services.json');
    if (kDebugMode) {
      print("📄 Raw JSON content loaded:\n$jsonStr");
    }

    // Decode the JSON string to a map
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    if (kDebugMode) {
      print("✅ JSON decoded successfully.");
    }

    // Check for the client list
    final clientList = jsonMap['client'];
    if (clientList == null || clientList.isEmpty) {
      throw Exception(
          "❌ 'client' field is missing or empty in google-services.json");
    }

    final client = clientList[0];
    if (kDebugMode) {
      print("📦 Extracted client[0]: $client");
    }

    // Check for the API key list
    final apiKeyList = client['api_key'];
    if (apiKeyList == null || apiKeyList.isEmpty) {
      throw Exception("❌ 'api_key' field is missing or empty in client");
    }

    // Extract required fields with null checks
    final String? currentKey = apiKeyList[0]['current_key'];
    final String? appId = client['client_info']['mobilesdk_app_id'];
    final String? messagingSenderId = jsonMap['project_info']['project_number'];
    final String? projectId = jsonMap['project_info']['project_id'];
    final String? storageBucket = jsonMap['project_info']['storage_bucket'];

    if (currentKey == null ||
        appId == null ||
        messagingSenderId == null ||
        projectId == null) {
      throw Exception("❌ Required Firebase config fields are missing.");
    }

    if (kDebugMode) {
      print("✅ Extracted Firebase config:");
      print("- apiKey: $currentKey");
      print("- appId: $appId");
      print("- messagingSenderId: $messagingSenderId");
      print("- projectId: $projectId");
      print("- storageBucket: $storageBucket");
    }

    // Return FirebaseOptions with non-null values
    return FirebaseOptions(
      apiKey: currentKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket ?? '', // Optional field
    );
  } catch (e) {
    // Handle any unexpected errors
    if (kDebugMode) {
      print("🚨 Error loading Firebase options: $e");
    }
    rethrow; // Propagate the error
  }
}

Future<void> initializeFirebase() async {
  try {
    if (kDebugMode) {
      print("🔍 Initializing Firebase...");
    }

    // Use default initialization which will automatically use google-services.json
    await Firebase.initializeApp();

    if (kDebugMode) {
      print("✅ Firebase initialized successfully");
    }
  } catch (e) {
    if (kDebugMode) {
      print("🚨 Error initializing Firebase: $e");
    }
    rethrow;
  }
}

// Future<FirebaseOptions> loadFirebaseOptionsFromJson() async {
//   if (kDebugMode) {
//     print("🔍 Loading google-services.json from assets...");
//   }
//
//   final jsonStr = await rootBundle.loadString('assets/google-services.json');
//   if (kDebugMode) {
//     print("📄 Raw JSON content loaded:\n$jsonStr");
//   }
//
//   final jsonMap = json.decode(jsonStr);
//   if (kDebugMode) {
//     print("✅ JSON decoded successfully.");
//   }
//
//   final clientList = jsonMap['client'];
//   if (clientList == null || clientList.isEmpty) {
//     throw Exception("❌ 'client' field is missing or empty in google-services.json");
//   }
//
//   final client = clientList[0];
//   if (kDebugMode) {
//     print("📦 Extracted client[0]: $client");
//   }
//
//   final apiKeyList = client['api_key'];
//   if (apiKeyList == null || apiKeyList.isEmpty) {
//     throw Exception("❌ 'api_key' field is missing or empty in client");
//   }
//
//   final currentKey = apiKeyList[0]['current_key'];
//   final appId = client['client_info']['mobilesdk_app_id'];
//   final messagingSenderId = jsonMap['project_info']['project_number'];
//   final projectId = jsonMap['project_info']['project_id'];
//   final storageBucket = jsonMap['project_info']['storage_bucket'];
//
//   if (kDebugMode) {
//     print("✅ Extracted Firebase config:");
//     print("- apiKey: $currentKey");
//     print("- appId: $appId");
//     print("- messagingSenderId: $messagingSenderId");
//     print("- projectId: $projectId");
//     print("- storageBucket: $storageBucket");
//   }
//
//
//   return FirebaseOptions(
//     apiKey: currentKey,
//     appId: appId,
//     messagingSenderId: messagingSenderId,
//     projectId: projectId,
//     storageBucket: storageBucket,
//   );
// }

// Future<FirebaseOptions> loadFirebaseOptionsFromJson() async {
//   final jsonStr = await rootBundle.loadString('assets/google-services.json');
//   final jsonMap = json.decode(jsonStr);
//   final client = jsonMap['client'][0];
//   return FirebaseOptions(
//     apiKey: client['api_key'][0]['current_key'],
//     appId: client['client_info']['mobilesdk_app_id'],
//     messagingSenderId: jsonMap['project_info']['project_number'],
//     projectId: jsonMap['project_info']['project_id'],
//     storageBucket: jsonMap['project_info']['storage_bucket'],
//   );
// }
