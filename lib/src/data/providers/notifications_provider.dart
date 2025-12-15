import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/models/notification_model.dart';

part 'notifications_provider.g.dart';

class NotificationsApi {
  static const String _endpoint = '/notification';

  final ApiProvider _apiProvider;

  NotificationsApi({required ApiProvider apiProvider})
      : _apiProvider = apiProvider;

  Future<ApiResponse<Map<String, dynamic>>> getNotifications({
    int pageNo = 1,
    int limit = 20,
  }) async {
    final queryParams = {'page_no': pageNo, 'limit': limit};
    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await _apiProvider.get(
      '$_endpoint?$queryString',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> markAsRead(
      String notificationId) async {
    return await _apiProvider.patch(
      '$_endpoint/$notificationId/read',
      {},
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> markAllAsRead() async {
    return await _apiProvider.patch(
      '$_endpoint/mark-all-as-read',
      {},
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteNotification(
      String notificationId) async {
    return await _apiProvider.delete(
      '$_endpoint/$notificationId',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getUnreadCount() async {
    return await _apiProvider.get(
      '$_endpoint/unread-count',
      requireAuth: true,
    );
  }
}

@riverpod
NotificationsApi notificationsApi(Ref ref) {
  final apiProvider = ref.watch(apiProviderProvider);
  return NotificationsApi(apiProvider: apiProvider);
}

class NotificationPaginationState {
  final int currentPage;
  final int limit;
  final int totalCount;
  final List<NotificationModel> notifications;
  final bool hasMore;

  NotificationPaginationState({
    required this.currentPage,
    required this.limit,
    required this.totalCount,
    required this.notifications,
  }) : hasMore = (currentPage * limit) < totalCount;

  NotificationPaginationState copyWith({
    int? currentPage,
    int? limit,
    int? totalCount,
    List<NotificationModel>? notifications,
  }) {
    return NotificationPaginationState(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalCount: totalCount ?? this.totalCount,
      notifications: notifications ?? this.notifications,
    );
  }
}

@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  Future<NotificationPaginationState> build() async {
    final notificationsApi = ref.watch(notificationsApiProvider);
    final user = ref.watch(userProvider);
    final secureStorage = ref.watch(secureStorageServiceProvider);
    
    // Get current user ID - try from userProvider first, then from secure storage
    String? currentUserId = user?.id;
    
    if (currentUserId == null || currentUserId.isEmpty) {
      final storedUser = await secureStorage.getUserData();
      currentUserId = storedUser?.id;
    }
    
    print('DEBUG PROVIDER: Current user ID from provider: ${user?.id}');
    print('DEBUG PROVIDER: Final current user ID: $currentUserId');

    final response = await notificationsApi.getNotifications(
      pageNo: 1,
      limit: 20,
    );

    if (response.success && response.data != null) {
      final notificationsList = (response.data!['data'] as List<dynamic>?)
              ?.map((item) =>
                  NotificationModel.fromJson(
                    item as Map<String, dynamic>,
                    currentUserId: currentUserId,
                  ))
              .toList() ??
          [];
      final totalCountValue = response.data!['total_count'];
      final totalCount = totalCountValue is int
          ? totalCountValue
          : int.tryParse(totalCountValue.toString()) ?? 0;

      return NotificationPaginationState(
        currentPage: 1,
        limit: 20,
        totalCount: totalCount,
        notifications: notificationsList,
      );
    } else {
      throw Exception(response.message ?? 'Failed to fetch notifications');
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final notificationsApi = ref.watch(notificationsApiProvider);
      final user = ref.watch(userProvider);
      final secureStorage = ref.watch(secureStorageServiceProvider);
      
      // Get current user ID - try from userProvider first, then from secure storage
      String? currentUserId = user?.id;
      
      if (currentUserId == null || currentUserId.isEmpty) {
        final storedUser = await secureStorage.getUserData();
        currentUserId = storedUser?.id;
      }

      final nextPage = currentState.currentPage + 1;
      final response = await notificationsApi.getNotifications(
        pageNo: nextPage,
        limit: currentState.limit,
      );

      if (response.success && response.data != null) {
        final notificationsList = (response.data!['data'] as List<dynamic>?)
                ?.map((item) =>
                    NotificationModel.fromJson(
                      item as Map<String, dynamic>,
                      currentUserId: currentUserId,
                    ))
                .toList() ??
            [];
        final totalCountValue = response.data!['total_count'];
        final totalCount = totalCountValue is int
            ? totalCountValue
            : int.tryParse(totalCountValue.toString()) ?? 0;

        return currentState.copyWith(
          currentPage: nextPage,
          totalCount: totalCount,
          notifications: [...currentState.notifications, ...notificationsList],
        );
      } else {
        throw Exception(
            response.message ?? 'Failed to load more notifications');
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final notificationsApi = ref.watch(notificationsApiProvider);
      final response = await notificationsApi.markAsRead(notificationId);
      if (response.success && state.hasValue) {
        // Update locally instead of refreshing
        final currentState = state.value!;
        final updatedNotifications = currentState.notifications.map((notif) {
          if (notif.id == notificationId) {
            return notif.copyWith(isRead: true);
          }
          return notif;
        }).toList();
        
        state = AsyncValue.data(currentState.copyWith(
          notifications: updatedNotifications,
        ));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final notificationsApi = ref.watch(notificationsApiProvider);
      final response = await notificationsApi.markAllAsRead();
      if (response.success && state.hasValue) {
        // Update locally instead of refreshing
        final currentState = state.value!;
        final updatedNotifications = currentState.notifications
            .map((notif) => notif.copyWith(isRead: true))
            .toList();
        
        state = AsyncValue.data(currentState.copyWith(
          notifications: updatedNotifications,
        ));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final notificationsApi = ref.watch(notificationsApiProvider);
      final response =
          await notificationsApi.deleteNotification(notificationId);
      if (response.success && state.hasValue) {
        // Update locally instead of refreshing
        final currentState = state.value!;
        final updatedNotifications = currentState.notifications
            .where((notif) => notif.id != notificationId)
            .toList();
        
        state = AsyncValue.data(currentState.copyWith(
          notifications: updatedNotifications,
          totalCount: currentState.totalCount - 1,
        ));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

@riverpod
Future<int> unreadNotificationCount(Ref ref) async {
  final notificationsApi = ref.watch(notificationsApiProvider);
  final response = await notificationsApi.getUnreadCount();

  if (response.success && response.data != null) {
    final count = response.data!['unread_count'];
    return count is int ? count : int.tryParse(count.toString()) ?? 0;
  }
  return 0;
}
