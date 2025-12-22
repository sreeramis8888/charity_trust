import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/global_variables.dart' show GlobalVariables;
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/providers/notifications_provider.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/interfaces/components/cards/notification_card.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(notificationsProvider.notifier).loadNextPage();
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'justNow'.tr();
    } else if (difference.inMinutes < 60) {
      return 'minutesAgo'.tr(args: ['${difference.inMinutes}']);
    } else if (difference.inHours < 24) {
      return 'hoursAgo'.tr(args: ['${difference.inHours}']);
    } else if (difference.inDays < 7) {
      return 'daysAgo'.tr(args: ['${difference.inDays}']);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  String _getDateSection(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (notificationDate == today) {
      return 'today'.tr();
    } else if (notificationDate == yesterday) {
      return 'yesterday'.tr();
    } else {
      return DateFormat('MMMM d, yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('notifications'.tr(), style: kBodyTitleM),
        actions: [
          notificationsAsync.when(
            data: (state) {
              final unreadCount =
                  state.notifications.where((n) => !n.isRead).length;
              return unreadCount > 0
                  ? TextButton(
                      onPressed: () {
                        ref
                            .read(notificationsProvider.notifier)
                            .markAllAsRead();
                      },
                      child: Text(
                        'markAllRead'.tr(),
                        style: kSmallTitleM.copyWith(color: kThirdTextColor),
                      ),
                    )
                  : SizedBox.shrink();
            },
            loading: () => SizedBox.shrink(),
            error: (_, __) => SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (state) {
          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: kGreyLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'noNotificationsYet'.tr(),
                    style: kBodyTitleM.copyWith(color: kSecondaryTextColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.notifications.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: LoadingAnimation(),
                  ),
                );
              }

              final notification = state.notifications[index];

              final showDateHeader = index == 0 ||
                  _getDateSection(notification.createdAt) !=
                      _getDateSection(state.notifications[index - 1].createdAt);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDateHeader)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Text(
                        _getDateSection(notification.createdAt),
                        style: kSmallerTitleM.copyWith(
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ),
                  ..._buildNotificationCard(notification),
                ],
              );
            },
          );
        },
        loading: () => Center(
          child: LoadingAnimation(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('errorLoadingNotifications'.tr()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(notificationsProvider.notifier).refresh();
                },
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNotificationCard(dynamic notification) {
    final userRole = GlobalVariables.getUserRole();
    final isApprovalNotification = notification.tag == 'approval';
    final isNotMember = userRole != 'member';
    final shouldShowReviewButton = isApprovalNotification && isNotMember;

    return [
      NotificationCard(
        notification: notification,
        onTap: () {
          if (!notification.isRead) {
            ref
                .read(notificationsProvider.notifier)
                .markAsRead(notification.id);
          }
        },
      ),
      if (shouldShowReviewButton)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: SizedBox(
            width: 120,
            child: primaryButton(
              label: 'reviewNow'.tr(),
              onPressed: () {
                Navigator.of(context).pushNamed('MyReferrals');
              },
              buttonHeight: 32,
              fontSize: 12,
            ),
          ),
        ),
    ];
  }
}
