import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class ShorebirdUpdateService {
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  Future<int?> getCurrentPatchNumber() async {
    try {
      final currentPatch = await _updater.readCurrentPatch();
      return currentPatch?.number;
    } catch (e) {
      debugPrint('Error getting patch number: $e');
      return null;
    }
  }

  Future<UpdateStatus> checkForUpdate() async {
    try {
      return await _updater.checkForUpdate();
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return UpdateStatus.upToDate;
    }
  }

  Future<bool> isUpdateAvailable() async {
    try {
      final status = await _updater.checkForUpdate();
      return status == UpdateStatus.outdated;
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return false;
    }
  }

  Future<bool> downloadAndInstallUpdate() async {
    try {
      await _updater.update();
      return true;
    } on UpdateException catch (e) {
      debugPrint('Error downloading update: $e');
      return false;
    } catch (e) {
      debugPrint('Error downloading update: $e');
      return false;
    }
  }

  Future<bool> checkAndDownloadUpdate() async {
    try {
      final status = await checkForUpdate();
      if (status == UpdateStatus.outdated) {
        return await downloadAndInstallUpdate();
      }
      return false;
    } catch (e) {
      debugPrint('Error in checkAndDownloadUpdate: $e');
      return false;
    }
  }
}
