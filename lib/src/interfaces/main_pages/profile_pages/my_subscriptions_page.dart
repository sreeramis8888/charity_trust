import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/subscription_model.dart';
import 'package:Annujoom/src/data/providers/subscription_provider.dart';
import 'package:Annujoom/src/data/utils/date_formatter.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/subscription_detail_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MySubscriptionsPage extends ConsumerWidget {
  const MySubscriptionsPage({super.key});

  String _localizedStatus(String status) {
    switch (status) {
      case 'active':
        return 'subscriptionStatusActive'.tr();
      case 'created':
        return 'subscriptionStatusCreated'.tr();
      case 'paused':
        return 'subscriptionStatusPaused'.tr();
      case 'cancelled':
        return 'subscriptionStatusCancelled'.tr();
      case 'resumed':
        return 'subscriptionStatusResumed'.tr();
      case 'charged':
        return 'subscriptionStatusCharged'.tr();
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
      case 'resumed':
      case 'charged':
        return const Color(0xFF00C851);
      case 'paused':
        return const Color(0xFFFF8800);
      case 'cancelled':
        return const Color(0xFFFF4D4F);
      default:
        return kSecondaryTextColor;
    }
  }

  String _periodLabel(String period) {
    return period == 'weekly' ? 'perWeek'.tr() : 'perMonth'.tr();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(mySubscriptionsProvider);
    final preferredLanguage = GlobalVariables.getPreferredLanguage();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('mySubscriptions'.tr(), style: kSubHeadingM),
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'noSubscriptionsFound'.tr(),
                  textAlign: TextAlign.center,
                  style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(mySubscriptionsProvider);
              await ref.read(mySubscriptionsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              itemCount: subscriptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];
                return _SubscriptionCard(
                  subscription: subscription,
                  campaignTitle: subscription.getTitle(preferredLanguage),
                  statusLabel: _localizedStatus(subscription.status),
                  statusColor: _statusColor(subscription.status),
                  periodLabel: _periodLabel(subscription.period),
                  onTap: subscription.id == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SubscriptionDetailPage(
                                subscriptionId: subscription.id!,
                              ),
                            ),
                          );
                        },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: LoadingAnimation()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${'errorLoadingSubscriptions'.tr()}: $error',
                  textAlign: TextAlign.center,
                  style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.invalidate(mySubscriptionsProvider),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final String campaignTitle;
  final String statusLabel;
  final Color statusColor;
  final String periodLabel;
  final VoidCallback? onTap;

  const _SubscriptionCard({
    required this.subscription,
    required this.campaignTitle,
    required this.statusLabel,
    required this.statusColor,
    required this.periodLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDADADA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  campaignTitle,
                  style: kSmallerTitleSB,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: kSmallerTitleSB.copyWith(
                    color: statusColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(
                Icons.payments_outlined,
                '₹${subscription.amount.toStringAsFixed(0)} $periodLabel',
              ),
              const SizedBox(width: 8),
              _infoChip(
                Icons.calendar_today_outlined,
                subscription.planType.replaceAll('_', ' '),
              ),
            ],
          ),
          if (subscription.startDate != null) ...[
            const SizedBox(height: 10),
            _detailRow('startDate'.tr(), formatDate(subscription.startDate)),
          ],
          if (subscription.nextBillingDate != null) ...[
            const SizedBox(height: 6),
            _detailRow(
              'nextBillingDate'.tr(),
              formatDate(subscription.nextBillingDate),
            ),
          ],
          if (subscription.createdAt != null) ...[
            const SizedBox(height: 6),
            _detailRow('createdOn'.tr(), formatDate(subscription.createdAt)),
          ],
          if (onTap != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'viewDetails'.tr(),
                  style: kSmallerTitleSB.copyWith(
                    color: const Color(0xFF0601B4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Color(0xFF0601B4),
                ),
              ],
            ),
          ],
        ],
      ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0601B4).withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0601B4)),
          const SizedBox(width: 6),
          Text(
            label,
            style: kSmallerTitleR.copyWith(
              color: const Color(0xFF0601B4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: kSmallerTitleR.copyWith(
            color: kSecondaryTextColor,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: kSmallerTitleSB.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
