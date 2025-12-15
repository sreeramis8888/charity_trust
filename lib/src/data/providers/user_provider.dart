import 'dart:developer';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/models/user_model.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';

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
Future<({UserModel? user, String? error})> updateUserProfile(
  Ref ref,
  Map<String, dynamic> userData,
) async {
  try {
    final cleanedData = Map<String, dynamic>.from(userData)
      ..removeWhere((key, value) => value == "" || value == null);

    log("Cleaned data: $cleanedData");

    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.patch(
      '/user/update',
      cleanedData,
      requireAuth: true,
    );

    if (response.success) {
      final user = UserModel.fromJson(cleanedData);
      // Check if ref is still valid before using it
      if (ref.mounted) {
        ref.read(userProvider.notifier).setUser(user);
      }
      return (user: user, error: null);
    }

    return (user: null, error: response.message ?? 'Failed to update profile');
  } catch (e) {
    log('Error updating user profile: $e', name: 'updateUserProfile');
    return (user: null, error: e.toString());
  }
}

@riverpod
Future<({UserModel? user, String? error})> handleSuccessfulRegistration(
  Ref ref,
  UserModel user,
) async {
  try {
    final secureStorage = ref.watch(secureStorageServiceProvider);
    
    // Save user data to secure storage
    await secureStorage.saveUserData(user);
    
    // Save user ID for reference
    if (user.id != null) {
      await secureStorage.saveUserId(user.id!);
    }
    
    // Clear any temporary registration data
    await secureStorage.clearRegistrationData();
    
    // Update the user provider
    if (ref.mounted) {
      ref.read(userProvider.notifier).setUser(user);
    }
    
    log('User registration successful and data stored', name: 'handleSuccessfulRegistration');
    return (user: user, error: null);
  } catch (e) {
    log('Error handling successful registration: $e', name: 'handleSuccessfulRegistration');
    return (user: null, error: e.toString());
  }
}

class UsersListParams {
  final String role;
  final int pageNo;
  final String? search;

  UsersListParams({
    required this.role,
    this.pageNo = 1,
    this.search,
  });
}

@riverpod
Future<List<UserModel>> fetchUsersByRole(
  Ref ref,
  UsersListParams params,
) async {
  try {
    final apiProvider = ref.watch(apiProviderProvider);
    final queryParams = {
      'role[]': params.role,
      'page_no': params.pageNo,
      'limit': 10,
    };
    final search = params.search;
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response = await apiProvider.get(
      '/user?$queryString',
      requireAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!['data']['users'] as List?;
      if (data != null) {
        return data
            .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  } catch (e) {
    log('Error fetching users by role: $e', name: 'fetchUsersByRole');
    return [];
  }
}

@riverpod
Future<bool> verifyOtpForCharityMember(
  Ref ref,
  String charityMemberId,
  String otp,
) async {
  try {
    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.post(
      '/user/verify-otp',
      {
        'charity_member_id': charityMemberId,
        'otp': otp,
      },
      requireAuth: true,
    );

    if (response.success) {
      log('OTP verified successfully for charity member: $charityMemberId',
          name: 'verifyOtpForCharityMember');
      return true;
    }
    return false;
  } catch (e) {
    log('Error verifying OTP for charity member: $e',
        name: 'verifyOtpForCharityMember');
    return false;
  }
}

@riverpod
Future<UserModel?> fetchCurrentUserStatus(Ref ref) async {
  try {
    final apiProvider = ref.watch(apiProviderProvider);
    final secureStorage = ref.watch(secureStorageServiceProvider);

    final response =
        await apiProvider.get('/user/current-status', requireAuth: true);

    if (response.success && response.data != null) {
      final statusData = response.data!['data'];

      if (statusData != null) {
        // Get existing user from local storage to preserve other fields
        var existingUser = await secureStorage.getUserData();

        // Create updated user with current status, preserving existing data
        final updatedUser = (existingUser ?? UserModel()).copyWith(
          id: statusData['_id'] ?? existingUser?.id,
          status: statusData['status'] ?? existingUser?.status,
        );

        // Only update provider if ref is still mounted
        if (ref.mounted) {
          ref.read(userProvider.notifier).setUser(updatedUser);
        }
        return updatedUser;
      }
    }
    return null;
  } catch (e) {
    log('Error fetching current user status: $e',
        name: 'fetchCurrentUserStatus');
    return null;
  }
}

@riverpod
Future<({UserModel? user, String? error})> createNewUser(
  Ref ref,
  Map<String, dynamic> userData,
) async {
  try {
    final cleanedData = Map<String, dynamic>.from(userData)
      ..removeWhere((key, value) => value == "" || value == null);

    log("Creating new user with data: $cleanedData");

    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.post(
      '/user/create',
      cleanedData,
      requireAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>?;
      if (data != null) {
        final user = UserModel.fromJson(data);
        return (user: user, error: null);
      }
    }

    return (user: null, error: response.message ?? 'Failed to create user');
  } catch (e) {
    log('Error creating new user: $e', name: 'createNewUser');
    return (user: null, error: e.toString());
  }
}

@riverpod
Future<List<UserModel>> fetchPendingApprovals(Ref ref) async {
  try {
    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.get(
      '/user/appovals',
      requireAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!['data'] as List?;
      if (data != null) {
        return data
            .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  } catch (e) {
    log('Error fetching pending approvals: $e', name: 'fetchPendingApprovals');
    return [];
  }
}

@riverpod
Future<List<UserModel>> fetchUserReferrals(Ref ref) async {
  try {
    final secureStorage = ref.watch(secureStorageServiceProvider);
    final userId = await secureStorage.getUserId();

    if (userId == null || userId.isEmpty) {
      log('User ID not found', name: 'fetchUserReferrals');
      return [];
    }

    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.get(
      '/user/referals/$userId',
      requireAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!['data'] as List?;
      if (data != null) {
        return data
            .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  } catch (e) {
    log('Error fetching user referrals: $e', name: 'fetchUserReferrals');
    return [];
  }
}

@riverpod
Future<bool> approveUser(
  Ref ref,
  String userId,
) async {
  try {
    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.patch(
      '/user/action/$userId',
      {'action': 'active'},
      requireAuth: true,
    );

    if (response.success) {
      log('User approved successfully: $userId', name: 'approveUser');
      return true;
    }
    return false;
  } catch (e) {
    log('Error approving user: $e', name: 'approveUser');
    return false;
  }
}

@riverpod
Future<bool> rejectUser(
  Ref ref,
  String userId,
  String reason,
) async {
  try {
    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.patch(
      '/user/action/$userId',
      {
        'action': 'rejected',
        'reason': reason,
      },
      requireAuth: true,
    );

    if (response.success) {
      log('User rejected successfully: $userId', name: 'rejectUser');
      return true;
    }
    return false;
  } catch (e) {
    log('Error rejecting user: $e', name: 'rejectUser');
    return false;
  }
}

@riverpod
class PendingApprovalsNotifier extends _$PendingApprovalsNotifier {
  @override
  Future<List<UserModel>> build() async {
    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.get(
      '/user/appovals',
      requireAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!['data'] as List?;
      if (data != null) {
        return data
            .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

@riverpod
class UserReferralsNotifier extends _$UserReferralsNotifier {
  @override
  Future<List<UserModel>> build() async {
    final secureStorage = ref.watch(secureStorageServiceProvider);
    final userId = await secureStorage.getUserId();

    if (userId == null || userId.isEmpty) {
      log('User ID not found', name: 'UserReferralsNotifier');
      return [];
    }

    final apiProvider = ref.watch(apiProviderProvider);
    final response = await apiProvider.get(
      '/user/referals/$userId',
      requireAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!['data'] as List?;
      if (data != null) {
        return data
            .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
