import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:charity_trust/src/data/services/secure_storage_service.dart';

part 'auth_provider.g.dart';

class AuthProvider {
  final SecureStorageService _secureStorage;

  AuthProvider({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  Future<String?> getBearerToken() async {
    return await _secureStorage.getBearerToken();
  }

  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasBearerToken();
  }

  Future<void> login(String token, {String? refreshToken, String? userId}) async {
    await _secureStorage.saveBearerToken(token);
    if (refreshToken != null) {
      await _secureStorage.saveRefreshToken(refreshToken);
    }
    if (userId != null) {
      await _secureStorage.saveUserId(userId);
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  Future<bool> refreshToken() async {
    // TODO: Call refresh token endpoint with refresh token
    // If successful, save new bearer token
    // If failed, clear tokens and return false
    return false;
  }
}

@riverpod
AuthProvider authProvider(Ref ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthProvider(secureStorage: secureStorage);
}

@riverpod
Future<bool> isAuthenticated(Ref ref) async {
  final authProvider = ref.watch(authProviderProvider);
  return await authProvider.isAuthenticated();
}

@riverpod
Future<String?> bearerToken(Ref ref) async {
  final authProvider = ref.watch(authProviderProvider);
  return await authProvider.getBearerToken();
}
