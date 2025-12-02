import 'dart:developer';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:charity_trust/src/data/models/user_model.dart';
import 'package:charity_trust/src/data/providers/api_provider.dart';
import 'package:charity_trust/src/data/services/secure_storage_service.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  UserModel? build() {
    return null;
  }

  void setUser(UserModel user) {
    state = user;
    _syncUserToStorage(user);
  }

  void clearUser() {
    state = null;
    _clearUserFromStorage();
  }

  bool get isUserActive => state?.status == 'active';
  bool get isUserInactive => state?.status == 'inactive';
  bool get isUserPending => state?.status == 'pending';
  bool get isUserRejected => state?.status == 'rejected';
  bool get isUserSuspended => state?.status == 'suspended';

  Future<void> _syncUserToStorage(UserModel user) async {
    try {
      final secureStorage = ref.read(secureStorageServiceProvider);
      await secureStorage.saveUserData(user);
      log('User data synced to secure storage', name: 'UserNotifier');
    } catch (e) {
      log('Error syncing user to storage: $e', name: 'UserNotifier');
    }
  }

  Future<void> _clearUserFromStorage() async {
    try {
      final secureStorage = ref.read(secureStorageServiceProvider);
      await secureStorage.clearAll();
      log('User data cleared from storage', name: 'UserNotifier');
    } catch (e) {
      log('Error clearing user from storage: $e', name: 'UserNotifier');
    }
  }
}

@riverpod
Future<UserModel?> fetchUserProfile(Ref ref) async {
  try {
    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.get('/user/profile', requireAuth: true);

    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>?;
      if (data != null) {
        final user = UserModel.fromJson(data);
        ref.read(userProvider.notifier).setUser(user);
        return user;
      }
    }
    return null;
  } catch (e) {
    log('Error fetching user profile: $e', name: 'fetchUserProfile');
    return null;
  }
}

@riverpod
Future<UserModel?> updateUserProfile(Ref ref, Map<String, dynamic> userData) async {
  try {
    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.post(
      '/user/update',
      userData,
      requireAuth: true,
    );

    if (response.success) {
      final user = UserModel.fromJson(userData);
      ref.read(userProvider.notifier).setUser(user);
      return user;
    }
    return null;
  } catch (e) {
    log('Error updating user profile: $e', name: 'updateUserProfile');
    return null;
  }
}
