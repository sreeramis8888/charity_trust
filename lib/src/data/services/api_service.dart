import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:charity_trust/src/data/utils/globals.dart';
import 'package:charity_trust/src/data/services/crashlytics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_service.g.dart';

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

class ApiService {
  final String baseUrl;
  final String apiKey;
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<ApiResponse<Map<String, dynamic>>> get(String endpoint) async {
    try {
      log(token.toString(), name: 'Home page get user token');
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'x-api-key': apiKey
        },
      );

      log(name: 'HITTING API', '$baseUrl$endpoint');
      final decoded = json.decode(response.body);

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
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'x-api-key': apiKey
        },
        body: json.encode(data),
      );
      log(name: 'HITTING API', '$baseUrl$endpoint');
      final decoded = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to post data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      // Log error to Crashlytics
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'POST');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> patch(
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    try {
      log(name: 'HITTING API PATCH:', '$baseUrl$endpoint');
      final response = await _client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'x-api-key': apiKey
        },
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
      // Log error to Crashlytics
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'PATCH');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'x-api-key': apiKey
        },
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
      // Log error to Crashlytics
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'PUT');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'x-api-key': apiKey
        },
      );
      log(name: 'HITTING API', '$baseUrl$endpoint');
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to delete data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      // Log error to Crashlytics
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
ApiService apiService(Ref ref) {
  return ApiService(
    apiKey: dotenv.env['API_KEY'] ?? '',
    baseUrl: dotenv.env['BASE_URL'] ?? '',
  );
}
