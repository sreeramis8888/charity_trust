import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/models/user_model.dart';

part 'secure_storage_service.g.dart';

class SecureStorageService {
  static const String _bearerTokenKey = 'bearer_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _preferredLanguageKey = 'preferred_language';
  static const String _mswipeEnabledKey = 'mswipe_enabled';
  static const String _razorpayEnabledKey = 'razorpay_enabled';
  static const String _easebuzzEnabledKey = 'easebuzz_enabled';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  bool _isDecryptError(Object error) {
    final message = error.toString().toLowerCase();
    return error is PlatformException &&
        (message.contains('badpadding') ||
            message.contains('bad_decrypt') ||
            message.contains('javax.crypto') ||
            message.contains('exception encountered'));
  }

  Future<void> _resetCorruptedStorage() async {
    try {
      await _storage.deleteAll();
      log('Cleared corrupted secure storage', name: 'SecureStorage');
    } catch (e) {
      log('Failed to clear corrupted secure storage: $e',
          name: 'SecureStorage');
    }
  }

  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (_isDecryptError(e)) {
        log('Decrypt error reading "$key": $e', name: 'SecureStorage');
        await _resetCorruptedStorage();
        return null;
      }
      rethrow;
    }
  }

  Future<void> _safeWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      if (_isDecryptError(e)) {
        log('Decrypt error writing "$key": $e — resetting and retrying',
            name: 'SecureStorage');
        await _resetCorruptedStorage();
        await _storage.write(key: key, value: value);
        return;
      }
      rethrow;
    }
  }

  Future<void> saveMswipeEnabled(bool value) async {
    await _safeWrite(_mswipeEnabledKey, value.toString());
  }

  Future<bool?> getMswipeEnabled() async {
    final value = await _safeRead(_mswipeEnabledKey);
    return value != null ? value == 'true' : null;
  }

  Future<void> saveRazorpayEnabled(bool value) async {
    await _safeWrite(_razorpayEnabledKey, value.toString());
  }

  Future<bool?> getRazorpayEnabled() async {
    final value = await _safeRead(_razorpayEnabledKey);
    return value != null ? value == 'true' : null;
  }

  Future<void> saveEasebuzzEnabled(bool value) async {
    await _safeWrite(_easebuzzEnabledKey, value.toString());
  }

  Future<bool?> getEasebuzzEnabled() async {
    final value = await _safeRead(_easebuzzEnabledKey);
    return value != null ? value == 'true' : null;
  }

  Future<void> saveBearerToken(String token) async {
    await _safeWrite(_bearerTokenKey, token);
  }

  Future<String?> getBearerToken() async {
    return await _safeRead(_bearerTokenKey);
  }

  /// Save user ID for reference
  Future<void> saveUserId(String userId) async {
    await _safeWrite(_userIdKey, userId);
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    return await _safeRead(_userIdKey);
  }

  /// Save user data as JSON
  Future<void> saveUserData(UserModel user) async {
    final jsonString = json.encode(user.toJson());
    await _safeWrite(_userDataKey, jsonString);
  }

  /// Retrieve user data from local storage
  Future<UserModel?> getUserData() async {
    try {
      final jsonString = await _safeRead(_userDataKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      }
    } catch (e) {
      log('Error reading user data: $e', name: 'SecureStorage');
      if (_isDecryptError(e)) {
        await _resetCorruptedStorage();
        return null;
      }
    }
    return null;
  }

  /// Clear all stored tokens and user data
  /// Called on logout
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Check if bearer token exists
  Future<bool> hasBearerToken() async {
    final token = await getBearerToken();
    return token != null && token.isNotEmpty;
  }

  /// Save FCM token
  Future<void> saveFcmToken(String token) async {
    await _safeWrite(_fcmTokenKey, token);
  }

  /// Retrieve FCM token
  Future<String?> getFcmToken() async {
    return await _safeRead(_fcmTokenKey);
  }

  /// Check if current user is the demo account for App Store Connect
  Future<bool> isDemoAccount() async {
    final user = await getUserData();
    return user?.phone == '+919645398555';
  }

  /// Save registration data temporarily during the registration process
  Future<void> saveRegistrationData(Map<String, dynamic> data) async {
    final jsonString = json.encode(data);
    await _safeWrite('registration_data', jsonString);
  }

  /// Retrieve registration data
  Future<Map<String, dynamic>?> getRegistrationData() async {
    final jsonString = await _safeRead('registration_data');
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Clear registration data after successful registration
  Future<void> clearRegistrationData() async {
    await _storage.delete(key: 'registration_data');
  }

  /// Save preferred language
  Future<void> setPreferredLanguage(String languageCode) async {
    await _safeWrite(_preferredLanguageKey, languageCode);
  }

  /// Retrieve preferred language
  Future<String?> getPreferredLanguage() async {
    return await _safeRead(_preferredLanguageKey);
  }
}

@riverpod
SecureStorageService secureStorageService(Ref ref) {
  return SecureStorageService();
}
