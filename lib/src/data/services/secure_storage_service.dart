import 'dart:convert';
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

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveBearerToken(String token) async {
    await _storage.write(key: _bearerTokenKey, value: token);
  }

  Future<String?> getBearerToken() async {
    return await _storage.read(key: _bearerTokenKey);
  }

  /// Save user ID for reference
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Save user data as JSON
  Future<void> saveUserData(UserModel user) async {
    final jsonString = json.encode(user.toJson());
    await _storage.write(key: _userDataKey, value: jsonString);
  }

  /// Retrieve user data from local storage
  Future<UserModel?> getUserData() async {
    final jsonString = await _storage.read(key: _userDataKey);
    if (jsonString != null) {
      try {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      } catch (e) {
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
    await _storage.write(key: _fcmTokenKey, value: token);
  }

  /// Retrieve FCM token
  Future<String?> getFcmToken() async {
    return await _storage.read(key: _fcmTokenKey);
  }

  /// Check if current user is the demo account for App Store Connect
  Future<bool> isDemoAccount() async {
    final user = await getUserData();
    return user?.phone == '+919645398555';
  }

  /// Save registration data temporarily during the registration process
  Future<void> saveRegistrationData(Map<String, dynamic> data) async {
    final jsonString = json.encode(data);
    await _storage.write(key: 'registration_data', value: jsonString);
  }

  /// Retrieve registration data
  Future<Map<String, dynamic>?> getRegistrationData() async {
    final jsonString = await _storage.read(key: 'registration_data');
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
    await _storage.write(key: _preferredLanguageKey, value: languageCode);
  }

  /// Retrieve preferred language
  Future<String?> getPreferredLanguage() async {
    return await _storage.read(key: _preferredLanguageKey);
  }
}

@riverpod
SecureStorageService secureStorageService(Ref ref) {
  return SecureStorageService();
}
