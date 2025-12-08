import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/models/user_model.dart';

part 'secure_storage_service.g.dart';

class SecureStorageService {
  static const String _bearerTokenKey = 'bearer_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';
  static const String _fcmTokenKey = 'fcm_token';

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
}

@riverpod
SecureStorageService secureStorageService(Ref ref) {
  return SecureStorageService();
}
