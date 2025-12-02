import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:charity_trust/src/data/utils/globals.dart';
import 'package:charity_trust/src/data/services/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> getFcmToken(BuildContext context, WidgetRef ref) async {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  final notificationStatus = await Permission.notification.status;

  if (isIOS || notificationStatus.isGranted) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        print("APNs Token: $apnsToken");
      }
      String? token = await messaging.getToken();
      fcmToken = token ?? '';
      final secureStorage = ref.read(secureStorageServiceProvider);
      await secureStorage.saveFcmToken(fcmToken);
      print("FCM Token: $token");
    } else {
      print('User declined or has not accepted permission');
    }
  } else if (notificationStatus.isDenied ||
      notificationStatus.isPermanentlyDenied) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Notifications Disabled"),
        content: Text(
            "Notifications are disabled. You can enable them later in settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Continue"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
