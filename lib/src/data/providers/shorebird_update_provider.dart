import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../services/shorebird_update_service.dart';

final shorebirdUpdateServiceProvider = Provider<ShorebirdUpdateService>((ref) {
  return ShorebirdUpdateService();
});

final updateAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(shorebirdUpdateServiceProvider);
  return await service.isUpdateAvailable();
});

final updateStatusProvider = FutureProvider<UpdateStatus>((ref) async {
  final service = ref.watch(shorebirdUpdateServiceProvider);
  return await service.checkForUpdate();
});

final currentPatchNumberProvider = FutureProvider<int?>((ref) async {
  final service = ref.watch(shorebirdUpdateServiceProvider);
  return await service.getCurrentPatchNumber();
});
