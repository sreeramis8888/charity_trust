import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Annujoom/src/data/utils/globals.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> handleNotificationPermissions(BuildContext context, WidgetRef ref) async {
  if (Platform.isIOS) {
    await _handleIOSPermissions(context, ref);
  } else {
    await _handleAndroidPermissions(context, ref);
  }
}

Future<void> _handleIOSPermissions(BuildContext context, WidgetRef ref) async {
  final settings = await FirebaseMessaging.instance.getNotificationSettings();

  if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
    final newSettings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (newSettings.authorizationStatus == AuthorizationStatus.authorized) {
      await _setupFCM(context, ref);
    } else {
      print('User declined notification permission');
    }
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    if (context.mounted) {
      _showNotificationPermissionDialog(context);
    }
  } else if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    await _setupFCM(context, ref);
  }
}

Future<void> _handleAndroidPermissions(BuildContext context, WidgetRef ref) async {
  final status = await Permission.notification.status;

  if (status.isGranted) {
    await _setupFCM(context, ref);
  } else if (status.isPermanentlyDenied) {
    if (context.mounted) {
      _showNotificationPermissionDialog(context);
    }
  } else {
    final result = await Permission.notification.request();
    if (result.isGranted) {
      await _setupFCM(context, ref);
    }
  }
}

Future<void> _setupFCM(BuildContext context, WidgetRef ref) async {
  try {
    final messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      String? apnsToken = await messaging.getAPNSToken();
      print("APNs Token: $apnsToken");
    }

    String? token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      final secureStorage = ref.read(secureStorageServiceProvider);
      await secureStorage.saveFcmToken(token);
      print("FCM Token: $token");
    }
  } catch (e) {
    print('Error setting up FCM: $e');
  }
}

Future<void> getFcmToken(BuildContext context, WidgetRef ref) async {
  await handleNotificationPermissions(context, ref);
}

void _showNotificationPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: kWhite,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: kPrimaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Stay Updated",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Enable notifications to receive important updates and stay connected with your community.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: kSecondaryTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: kBorder),
                      ),
                    ),
                    child: Text(
                      "Not Now",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Open Settings",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
