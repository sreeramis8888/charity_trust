import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';
import 'package:Annujoom/src/data/providers/auth_provider.dart';
import 'package:Annujoom/src/data/providers/firebase_auth_provider.dart';
import 'dart:developer';

part 'auth_login_provider.g.dart';

class AuthLoginApi {
  static const String _endpoint = '/auth';

  final ApiProvider _apiProvider;
  final AuthProvider _authProvider;

  AuthLoginApi({
    required ApiProvider apiProvider,
    required AuthProvider authProvider,
  })  : _apiProvider = apiProvider,
        _authProvider = authProvider;

  Future<ApiResponse<Map<String, dynamic>>> firebaseLogin(
    String clientToken,
    String fcmToken,
  ) async {
    return await _apiProvider.post(
      '$_endpoint/firebase-login',
      {'client_token': clientToken, 'fcm': fcmToken},
      requireAuth: false,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    return await _apiProvider.post(
      '$_endpoint/logout',
      {},
      requireAuth: true,
    );
  }
}

@riverpod
AuthLoginApi authLoginApi(Ref ref) {
  final apiProvider = ref.watch(apiProviderProvider);
  final authProvider = ref.watch(authProviderProvider);
  return AuthLoginApi(
    apiProvider: apiProvider,
    authProvider: authProvider,
  );
}
