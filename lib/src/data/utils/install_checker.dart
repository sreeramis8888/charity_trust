import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallChecker {
  static const _installFlagKey = 'install_flag';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> checkFirstInstall() async {
    final prefs = await SharedPreferences.getInstance();
    final hasInstallFlag = prefs.getBool(_installFlagKey) ?? false;

    if (!hasInstallFlag) {
      await _secureStorage.deleteAll(); 
      await prefs.setBool(_installFlagKey, true);
    }
  }
}
