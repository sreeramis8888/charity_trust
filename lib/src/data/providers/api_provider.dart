import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:charity_trust/src/data/services/crashlytics_service.dart';
import 'package:charity_trust/src/data/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_provider.g.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final int? statusCode;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.statusCode,
    this.message,
  });

  factory ApiResponse.success(T data, [int? statusCode]) {
    return ApiResponse(success: true, data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse(
        success: false, message: message, statusCode: statusCode);
  }
}

class ApiProvider {
  final String baseUrl;
  final String apiKey;
  final AuthProvider authProvider;
  final http.Client _client;

  ApiProvider({
    required this.baseUrl,
    required this.apiKey,
    required this.authProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _buildHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'accept': '*/*',
      'x-api-key': apiKey,
    };

    if (requireAuth) {
      final token = await authProvider.getBearerToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      log(name: 'API GET', '$baseUrl$endpoint');
      final decoded = json.decode(response.body);
      log(name: 'DATA', response.body);
      if (response.statusCode == 200) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to load data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'GET');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      log(name: 'API POST', '$baseUrl$endpoint');
      final decoded = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to post data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'POST');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> patch(
    String endpoint,
    Map<String, dynamic>? data, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      log(name: 'API PATCH', '$baseUrl$endpoint');
      final response = await _client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: data != null ? json.encode(data) : null,
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to patch data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'PATCH');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to put data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'PUT');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      log(name: 'API DELETE', '$baseUrl$endpoint');
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to delete data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'DELETE');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

@riverpod
ApiProvider apiProvider(Ref ref) {
  final authProvider = ref.watch(authProviderProvider);
  return ApiProvider(
    apiKey: dotenv.env['API_KEY'] ?? '',
    baseUrl: dotenv.env['BASE_URL'] ?? '',
    authProvider: authProvider,
  );
}
