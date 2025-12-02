// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:charity_trust/src/data/utils/globals.dart';

// class SecureStorage {
//   static const _storage = FlutterSecureStorage(
//     aOptions: AndroidOptions(
//       encryptedSharedPreferences: true,
//     ),
//   );

//   static Future<void> write(String key, String value) async {
//     await _storage.write(key: key, value: value);
//   }

//   static Future<String?> read(String key) async {
//     try {
//       return await _storage.read(key: key);
//     } catch (e) {
//       await _storage.delete(key: key);
//       return null;
//     }
//   }

//   static Future<void> delete(String key) async {
//     await _storage.delete(key: key);
//   }

//   static Future<void> deleteAll() async {
//     await _storage.deleteAll();
//   }
// }

// Future<void> loadSecureData() async {
//   token = await SecureStorage.read('token') ?? '';
//   LoggedIn = (await SecureStorage.read('LoggedIn')) == 'true';
//   id = await SecureStorage.read('id') ?? '';
//   fcmToken = await SecureStorage.read('fcmToken') ?? '';
// }

// Future<void> saveSecureData() async {
//   await SecureStorage.write('token', token);
//   await SecureStorage.write('LoggedIn', LoggedIn.toString());
//   await SecureStorage.write('id', id);
//   await SecureStorage.write('fcmToken', fcmToken);
// }
