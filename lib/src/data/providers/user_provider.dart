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

    log('fetchUserProfile: API response - success: ${response.success}, data: ${response.data}',
        name: 'fetchUserProfile');

    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>?;
      log('fetchUserProfile: Extracted data: $data', name: 'fetchUserProfile');
      if (data != null) {
        final user = UserModel.fromJson(data);
        log('fetchUserProfile: User created - id: ${user.id}, status: ${user.status}',
            name: 'fetchUserProfile');
        try {
          if (ref.mounted) {
            ref.read(userProvider.notifier).setUser(user);
          }
        } catch (e) {
          log('Could not update user state (provider disposed): $e',
              name: 'fetchUserProfile');
        }
        return user;
      }
    }
    log('fetchUserProfile: Response not successful or data is null',
        name: 'fetchUserProfile');
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

    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>?;
      if (data != null) {
        final user = UserModel.fromJson(data);
        // Try to update state as backup (widget will also attempt this)
        try {
          if (ref.mounted) {
            ref.read(userProvider.notifier).setUser(user);
          }
        } catch (e) {
          log('Could not update user state from provider (will be updated from widget): $e',
              name: 'updateUserProfile');
        }
        return (user: user, error: null);
      }
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

    // Try to update state, but don't fail if provider is disposed
    try {
      if (ref.mounted) {
        ref.read(userProvider.notifier).setUser(user);
      }
    } catch (e) {
      log('Could not update user state (provider disposed): $e',
          name: 'handleSuccessfulRegistration');
    }

    log('User registration successful and data stored',
        name: 'handleSuccessfulRegistration');
    return (user: user, error: null);
  } catch (e) {
    log('Error handling successful registration: $e',
        name: 'handleSuccessfulRegistration');
    return (user: null, error: e.toString());
  }
}

class UsersListParams {
  final List<String> roles;
  final int pageNo;
  final String? search;

  UsersListParams({
    required this.roles,
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

    // Build query string with multiple role[] parameters
    final queryParts = <String>[];
    for (final role in params.roles) {
      queryParts.add('role[]=${Uri.encodeComponent(role)}');
    }
    queryParts.add('page_no=${params.pageNo}');
    queryParts.add('limit=15');

    final search = params.search;
    if (search != null && search.isNotEmpty) {
      queryParts.add('search=${Uri.encodeComponent(search)}');
    }

    final queryString = queryParts.join('&');

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

        // Try to update state, but don't fail if provider is disposed
        try {
          if (ref.mounted) {
            ref.read(userProvider.notifier).setUser(updatedUser);
          }
        } catch (e) {
          log('Could not update user state (provider disposed): $e',
              name: 'fetchCurrentUserStatus');
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
      '/user',
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

@Riverpod(keepAlive: true)
class ReferralTypeFilter extends _$ReferralTypeFilter {
  @override
  bool build() {
    return false; // false = Direct Referrals, true = Indirect Referrals
  }

  void setFilter(bool isIndirect) {
    state = isIndirect;
  }
}

@Riverpod(keepAlive: true)
class ReferralSearch extends _$ReferralSearch {
  @override
  String build() => '';

  void setSearch(String query) {
    print('🟣 [ReferralSearch] setSearch called with: "$query"');
    state = query;
    print('🟣 [ReferralSearch] state updated to: "$state"');
  }
}

@Riverpod(keepAlive: true)
class ReferralStatusFilter extends _$ReferralStatusFilter {
  @override
  String build() => ''; // Empty means all statuses

  void setStatus(String status) {
    print('🟣 [ReferralStatusFilter] setStatus called with: "$status"');
    state = status;
    print('🟣 [ReferralStatusFilter] state updated to: "$state"');
  }

  void clear() {
    print('🟣 [ReferralStatusFilter] clear called');
    state = '';
    print('🟣 [ReferralStatusFilter] state cleared to: "$state"');
  }
}

@Riverpod(keepAlive: true)
class ReferralDateFilter extends _$ReferralDateFilter {
  @override
  Map<String, String?> build() => {
        'start_date': null,
        'end_date': null,
      };

  void setDates(String? startDate, String? endDate) {
    print(
        '🟣 [ReferralDateFilter] setDates called with startDate: $startDate, endDate: $endDate');
    state = {
      'start_date': startDate,
      'end_date': endDate,
    };
    print('🟣 [ReferralDateFilter] state updated to: $state');
  }

  void clear() {
    print('🟣 [ReferralDateFilter] clear called');
    state = {
      'start_date': null,
      'end_date': null,
    };
    print('🟣 [ReferralDateFilter] state cleared to: $state');
  }
}

class ReferralPaginationState {
  final int currentPage;
  final int limit;
  final int totalCount;
  final int uiTotalCount;
  final List<UserModel> referrals;
  final int totalPending;
  final int totalApproved;
  final int totalRejected;
  final double totalMemberDonations;
  final bool hasMore;

  ReferralPaginationState({
    required this.currentPage,
    required this.limit,
    required this.totalCount,
    required this.referrals,
    this.uiTotalCount = 0,
    this.totalPending = 0,
    this.totalApproved = 0,
    this.totalRejected = 0,
    this.totalMemberDonations = 0,
  }) : hasMore = (currentPage * limit) < totalCount;

  ReferralPaginationState copyWith({
    int? currentPage,
    int? limit,
    int? totalCount,
    int? uiTotalCount,
    List<UserModel>? referrals,
    int? totalPending,
    int? totalApproved,
    int? totalRejected,
    double? totalMemberDonations,
  }) {
    return ReferralPaginationState(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalCount: totalCount ?? this.totalCount,
      referrals: referrals ?? this.referrals,
      uiTotalCount: uiTotalCount ?? this.uiTotalCount,
      totalPending: totalPending ?? this.totalPending,
      totalApproved: totalApproved ?? this.totalApproved,
      totalRejected: totalRejected ?? this.totalRejected,
      totalMemberDonations: totalMemberDonations ?? this.totalMemberDonations,
    );
  }
}

@riverpod
class AllReferralsNotifier extends _$AllReferralsNotifier {
  bool _isLoadingMore = false;

  @override
  Future<ReferralPaginationState> build() async {
    print('🔵 [AllReferralsNotifier] BUILD CALLED');

    final secureStorage = ref.watch(secureStorageServiceProvider);
    final userId = await secureStorage.getUserId();
    final search = ref.watch(referralSearchProvider);
    final status = ref.watch(referralStatusFilterProvider);
    final dates = ref.watch(referralDateFilterProvider);

    print('🔵 [AllReferralsNotifier] userId: $userId');
    print('🔵 [AllReferralsNotifier] search: "$search"');
    print('🔵 [AllReferralsNotifier] status: "$status"');
    print('🔵 [AllReferralsNotifier] dates: $dates');

    if (userId == null || userId.isEmpty) {
      log('User ID not found', name: 'AllReferralsNotifier');
      return ReferralPaginationState(
        currentPage: 1,
        limit: 10,
        totalCount: 0,
        referrals: [],
      );
    }

    final apiProvider = ref.watch(apiProviderProvider);

    final queryParams = <String>[];
    queryParams.add('page_no=1');
    queryParams.add('limit=10');

    print(
        '🔵 [AllReferralsNotifier] Before adding filters - queryParams: $queryParams');

    if (search.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search)}');
      print('🔵 [AllReferralsNotifier] Added search parameter: $search');
    }
    if (status.isNotEmpty) {
      queryParams.add('status=${Uri.encodeComponent(status)}');
      print('🔵 [AllReferralsNotifier] Added status parameter: $status');
    }
    if (dates['start_date'] != null && dates['start_date']!.isNotEmpty) {
      queryParams
          .add('start_date=${Uri.encodeComponent(dates['start_date']!)}');
      print(
          '🔵 [AllReferralsNotifier] Added start_date parameter: ${dates['start_date']}');
    }
    if (dates['end_date'] != null && dates['end_date']!.isNotEmpty) {
      queryParams.add('end_date=${Uri.encodeComponent(dates['end_date']!)}');
      print(
          '🔵 [AllReferralsNotifier] Added end_date parameter: ${dates['end_date']}');
    }

    final queryString = queryParams.join('&');
    final url = '/user/approvals?$queryString';

    print('🔵 [AllReferralsNotifier] Final queryParams: $queryParams');
    print('🔵 [AllReferralsNotifier] Final URL: $url');
    log('AllReferralsNotifier API call: $url', name: 'AllReferralsNotifier');

    final response = await apiProvider.get(
      url,
      requireAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>?;
      if (data != null) {
        final users = data['users'] as List?;
        // Use the outer total_count for pagination
        final paginationTotalCount = response.data!['total_count'];
        final totalCountForPagination = paginationTotalCount is int
            ? paginationTotalCount
            : int.tryParse(paginationTotalCount.toString()) ?? 0;

        // Use the inner total_count for UI display
        final uiTotalCount = data['total_count'] is int
            ? data['total_count']
            : int.tryParse(data['total_count'].toString()) ?? 0;

        final totalPending = data['total_pending'] is int
            ? data['total_pending']
            : int.tryParse(data['total_pending'].toString()) ?? 0;
        final totalApproved = data['total_approved'] is int
            ? data['total_approved']
            : int.tryParse(data['total_approved'].toString()) ?? 0;
        final totalRejected = data['total_rejected'] is int
            ? data['total_rejected']
            : int.tryParse(data['total_rejected'].toString()) ?? 0;
        final totalMemberDonations =
            data['total_amount_referral_donated'] is double
                ? data['total_amount_referral_donated']
                : double.tryParse(
                        data['total_amount_referral_donated'].toString()) ??
                    0.0;

        final referrals = users != null
            ? users
                .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
                .toList()
                .cast<UserModel>()
            : <UserModel>[];

        return ReferralPaginationState(
            currentPage: 1,
            limit: 10,
            totalCount: totalCountForPagination,
            referrals: referrals,
            uiTotalCount: uiTotalCount,
            totalPending: totalPending,
            totalApproved: totalApproved,
            totalRejected: totalRejected,
            totalMemberDonations: totalMemberDonations);
      }
    }
    return ReferralPaginationState(
      currentPage: 1,
      limit: 10,
      totalCount: 0,
      referrals: [],
    );
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;

    // Don't call API if we've already loaded all items
    if (!currentState.hasMore) {
      print(
          '🔵 [AllReferralsNotifier] loadNextPage skipped - hasMore is false, all items loaded');
      return;
    }

    // Prevent duplicate API calls while one is already in progress
    if (_isLoadingMore) {
      print(
          '🔵 [AllReferralsNotifier] loadNextPage skipped - already loading more');
      return;
    }

    _isLoadingMore = true;
    print(
        '🔵 [AllReferralsNotifier] loadNextPage started - loading page ${currentState.currentPage + 1}');

    state = await AsyncValue.guard(() async {
      final search = ref.read(referralSearchProvider);
      final status = ref.read(referralStatusFilterProvider);
      final dates = ref.read(referralDateFilterProvider);

      if (currentState.referrals.isEmpty) {
        return currentState;
      }

      final apiProvider = ref.watch(apiProviderProvider);
      final nextPage = currentState.currentPage + 1;

      final queryParams = <String>[];
      queryParams.add('page_no=$nextPage');
      queryParams.add('limit=${currentState.limit}');

      if (search.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search)}');
      }
      if (status.isNotEmpty) {
        queryParams.add('status=${Uri.encodeComponent(status)}');
      }
      if (dates['start_date'] != null && dates['start_date']!.isNotEmpty) {
        queryParams
            .add('start_date=${Uri.encodeComponent(dates['start_date']!)}');
      }
      if (dates['end_date'] != null && dates['end_date']!.isNotEmpty) {
        queryParams.add('end_date=${Uri.encodeComponent(dates['end_date']!)}');
      }

      final queryString = queryParams.join('&');
      final response = await apiProvider.get(
        '/user/approvals?$queryString',
        requireAuth: true,
      );

      if (response.success && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) {
          final users = data['users'] as List?;
          // Use the outer total_count for pagination
          final paginationTotalCount = response.data!['total_count'];
          final totalCountForPagination = paginationTotalCount is int
              ? paginationTotalCount
              : int.tryParse(paginationTotalCount.toString()) ?? 0;

          final referrals = users != null
              ? users
                  .map((item) =>
                      UserModel.fromJson(item as Map<String, dynamic>))
                  .toList()
                  .cast<UserModel>()
              : <UserModel>[];

          return currentState.copyWith(
            currentPage: nextPage,
            totalCount: totalCountForPagination,
            referrals: <UserModel>[...currentState.referrals, ...referrals],
          );
        }
      }
      return currentState;
    });
    _isLoadingMore = false;
    print('🔵 [AllReferralsNotifier] loadNextPage completed');
  }

  Future<void> refresh() async {
    _isLoadingMore = false;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

@riverpod
class IndirectReferralsNotifier extends _$IndirectReferralsNotifier {
  bool _isLoadingMore = false;

  @override
  Future<ReferralPaginationState> build() async {
    print('🟣 [IndirectReferralsNotifier] BUILD CALLED - Indirect Referrals');

    final search = ref.watch(referralSearchProvider);
    final status = ref.watch(referralStatusFilterProvider);
    final dates = ref.watch(referralDateFilterProvider);

    print('🟣 [IndirectReferralsNotifier] search: "$search"');
    print('🟣 [IndirectReferralsNotifier] status: "$status"');
    print('🟣 [IndirectReferralsNotifier] dates: $dates');

    final apiProvider = ref.watch(apiProviderProvider);

    final queryParams = <String>[];
    queryParams.add('page_no=1');
    queryParams.add('limit=10');

    if (search.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search)}');
      print('🟣 [IndirectReferralsNotifier] Added search parameter: $search');
    }
    if (status.isNotEmpty) {
      queryParams.add('status=${Uri.encodeComponent(status)}');
      print('🟣 [IndirectReferralsNotifier] Added status parameter: $status');
    }
    if (dates['start_date'] != null && dates['start_date']!.isNotEmpty) {
      queryParams.add('from_date=${Uri.encodeComponent(dates['start_date']!)}');
      print(
          '🟣 [IndirectReferralsNotifier] Added from_date parameter: ${dates['start_date']}');
    }
    if (dates['end_date'] != null && dates['end_date']!.isNotEmpty) {
      queryParams.add('to_date=${Uri.encodeComponent(dates['end_date']!)}');
      print(
          '🟣 [IndirectReferralsNotifier] Added to_date parameter: ${dates['end_date']}');
    }

    final queryString = queryParams.join('&');
    final url = '/user/indirect-referrals?$queryString';

    print('🟣 [IndirectReferralsNotifier] Final URL: $url');
    log('IndirectReferralsNotifier API call: $url',
        name: 'IndirectReferralsNotifier');

    final response = await apiProvider.get(
      url,
      requireAuth: true,
    );

    if (response.success && response.data != null) {
      final responseData = response.data!['data'];

      // Get total count from outer response for pagination
      final paginationTotalCount = response.data!['total_count'];
      final totalCountForPagination = paginationTotalCount is int
          ? paginationTotalCount
          : int.tryParse(paginationTotalCount.toString()) ?? 0;

      // Handle case where 'data' is a List (direct referrals array)
      if (responseData is List) {
        final referrals = responseData
            .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
            .toList()
            .cast<UserModel>();

        return ReferralPaginationState(
          currentPage: 1,
          limit: 10,
          totalCount: totalCountForPagination,
          referrals: referrals,
        );
      }

      // Handle case where 'data' is a Map (with metadata)
      if (responseData is Map<String, dynamic>) {
        final data = responseData;
        final users = data['users'] as List?;

        final referrals = users != null
            ? users
                .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
                .toList()
                .cast<UserModel>()
            : <UserModel>[];

        return ReferralPaginationState(
          currentPage: 1,
          limit: 10,
          totalCount: totalCountForPagination,
          referrals: referrals,
        );
      }
    }
    return ReferralPaginationState(
      currentPage: 1,
      limit: 10,
      totalCount: 0,
      referrals: [],
    );
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;

    if (!currentState.hasMore) {
      print(
          '🟣 [IndirectReferralsNotifier] loadNextPage skipped - hasMore is false');
      return;
    }

    if (_isLoadingMore) {
      print(
          '🟣 [IndirectReferralsNotifier] loadNextPage skipped - already loading more');
      return;
    }

    _isLoadingMore = true;
    print(
        '🟣 [IndirectReferralsNotifier] loadNextPage started - loading page ${currentState.currentPage + 1}');

    state = await AsyncValue.guard(() async {
      final search = ref.read(referralSearchProvider);
      final status = ref.read(referralStatusFilterProvider);
      final dates = ref.read(referralDateFilterProvider);

      if (currentState.referrals.isEmpty) {
        return currentState;
      }

      final apiProvider = ref.watch(apiProviderProvider);
      final nextPage = currentState.currentPage + 1;

      final queryParams = <String>[];
      queryParams.add('page_no=$nextPage');
      queryParams.add('limit=${currentState.limit}');

      if (search.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search)}');
      }
      if (status.isNotEmpty) {
        queryParams.add('status=${Uri.encodeComponent(status)}');
      }
      if (dates['start_date'] != null && dates['start_date']!.isNotEmpty) {
        queryParams
            .add('from_date=${Uri.encodeComponent(dates['start_date']!)}');
      }
      if (dates['end_date'] != null && dates['end_date']!.isNotEmpty) {
        queryParams.add('to_date=${Uri.encodeComponent(dates['end_date']!)}');
      }

      final queryString = queryParams.join('&');
      final response = await apiProvider.get(
        '/user/indirect-referrals?$queryString',
        requireAuth: true,
      );

      if (response.success && response.data != null) {
        final responseData = response.data!['data'];
        final paginationTotalCount = response.data!['total_count'];
        final totalCountForPagination = paginationTotalCount is int
            ? paginationTotalCount
            : int.tryParse(paginationTotalCount.toString()) ?? 0;

        // Handle case where 'data' is a List (direct referrals array)
        if (responseData is List) {
          final referrals = responseData
              .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
              .toList()
              .cast<UserModel>();

          return currentState.copyWith(
            currentPage: nextPage,
            totalCount: totalCountForPagination,
            referrals: <UserModel>[...currentState.referrals, ...referrals],
          );
        }

        // Handle case where 'data' is a Map (with metadata)
        if (responseData is Map<String, dynamic>) {
          final data = responseData;
          final users = data['users'] as List?;

          final referrals = users != null
              ? users
                  .map((item) =>
                      UserModel.fromJson(item as Map<String, dynamic>))
                  .toList()
                  .cast<UserModel>()
              : <UserModel>[];

          return currentState.copyWith(
            currentPage: nextPage,
            totalCount: totalCountForPagination,
            referrals: <UserModel>[...currentState.referrals, ...referrals],
          );
        }
      }
      return currentState;
    });
    _isLoadingMore = false;
    print('🟣 [IndirectReferralsNotifier] loadNextPage completed');
  }

  Future<void> refresh() async {
    _isLoadingMore = false;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
