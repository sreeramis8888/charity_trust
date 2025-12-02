import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:charity_trust/src/data/providers/api_provider.dart';
import 'package:charity_trust/src/data/models/app_version_model.dart';

part 'version_check_service.g.dart';

class VersionCheckService {
  final ApiProvider _apiProvider;

  VersionCheckService({required ApiProvider apiProvider})
      : _apiProvider = apiProvider;

  Future<AppVersionResponse?> checkVersion() async {
    try {
      final response = await _apiProvider.get(
        '/app/version-check',
        requireAuth: false,
      );

      if (response.success && response.data != null) {
        return AppVersionResponse.fromJson(response.data!);
      }
      return null;
    } catch (e) {
      log('Error checking version: $e', name: 'VersionCheckService');
      return null;
    }
  }
}

@riverpod
VersionCheckService versionCheckService(Ref ref) {
  final apiProvider = ref.watch(apiProviderProvider);
  return VersionCheckService(apiProvider: apiProvider);
}

@riverpod
Future<AppVersionResponse?> checkAppVersion(Ref ref) async {
  final versionCheckService = ref.watch(versionCheckServiceProvider);
  return await versionCheckService.checkVersion();
}
