import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

class SecureStorageService {
  static const String _bearerTokenKey = 'bearer_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveBearerToken(String token) async {
    await _storage.write(key: _bearerTokenKey, value: token);
  }

  Future<String?> getBearerToken() async {
    return await _storage.read(key: _bearerTokenKey);
  }

  /// Save refresh token for token renewal
  /// TODO: Implement token refresh logic when backend is ready
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Retrieve refresh token
  /// TODO: Use this when implementing token refresh mechanism
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save user ID for reference
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
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
}

@riverpod
SecureStorageService secureStorageService(Ref ref) {
  return SecureStorageService();
}
