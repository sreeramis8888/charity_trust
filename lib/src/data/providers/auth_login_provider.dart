import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';
import 'package:Annujoom/src/data/providers/auth_provider.dart';
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

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String phone) async {
    return await _apiProvider.post(
      '$_endpoint/login',
      {'phone': phone},
      requireAuth: false,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp(
    String phone,
    String otp,
    String fcmToken,
  ) async {
    final response = await _apiProvider.post(
      '$_endpoint/verify',
      {'phone': phone, 'otp': otp, 'fcm': fcmToken},
      requireAuth: false,
    );

    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>?;
      if (data != null) {
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await _authProvider.login(token);
          log('Bearer token saved securely via AuthProvider',
              name: 'AuthLoginApi');
        }
      }
    }

    return response;
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

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  Future<Map<String, dynamic>> build() async {
    return {};
  }

  Future<String?> sendOtp(String phone) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authLoginApi = ref.watch(authLoginApiProvider);
      final response = await authLoginApi.sendOtp(phone);

      if (response.success && response.data != null) {
        final otp = response.data!['data'] as String?;
        if (otp != null) {
          log('OTP received: $otp', name: 'LoginNotifier');
          return {'otp': otp};
        }
        throw Exception('No OTP in response');
      } else {
        throw Exception(response.message ?? 'Failed to send OTP');
      }
    });

    if (state.hasValue) {
      return state.value?['otp'] as String?;
    }
    return null;
  }

  Future<bool> verifyOtp(String phone, String otp, String fcmToken) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authLoginApi = ref.watch(authLoginApiProvider);
      final response = await authLoginApi.verifyOtp(phone, otp, fcmToken);

      if (response.success) {
        log('OTP verified successfully', name: 'LoginNotifier');
        return {'verified': true};
      } else {
        throw Exception(response.message ?? 'Failed to verify OTP');
      }
    });

    return state.hasValue && (state.value?['verified'] as bool? ?? false);
  }
}
