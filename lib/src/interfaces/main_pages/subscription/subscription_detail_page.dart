import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/subscription_model.dart';
import 'package:Annujoom/src/data/providers/subscription_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/data/utils/date_formatter.dart';
import 'package:Annujoom/src/interfaces/components/confirmation_dialog.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _SubscriptionAction { pause, resume, cancel }

class SubscriptionDetailPage extends ConsumerStatefulWidget {
  final String subscriptionId;

  const SubscriptionDetailPage({
    super.key,
    required this.subscriptionId,
  });

  @override
  ConsumerState<SubscriptionDetailPage> createState() =>
      _SubscriptionDetailPageState();
}

class _SubscriptionDetailPageState extends ConsumerState<SubscriptionDetailPage> {
  _SubscriptionAction? _loadingAction;

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

  String _localizedCategory(String category) {
    switch (category) {
      case 'General Funding':
        return 'generalFunding'.tr();
      case 'Zakat':
        return 'zakat'.tr();
      case 'Orphan':
        return 'orphan'.tr();
      case 'Widow':
        return 'widow'.tr();
      case 'Ghusl Mayyit':
        return 'ghusalMayyit'.tr();
      case 'Patient Relief':
        return 'patientRelief'.tr();
      case 'Food Kit':
        return 'foodKit'.tr();
      default:
        return category;
    }
  }

  bool _canPause(String status) {
    return !['paused', 'cancelled'].contains(status);
  }

  bool _canResume(String status) => status == 'paused';

  bool _canCancel(String status) => status != 'cancelled';

  void _confirmAction(
    _SubscriptionAction action, {
    required String title,
    required String message,
    required String confirmText,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: title,
        message: message,
        confirmButtonText: confirmText,
        onConfirm: () => _performAction(action),
      ),
    );
  }

  Future<void> _performAction(_SubscriptionAction action) async {
    if (!mounted) return;

    setState(() => _loadingAction = action);

    try {
      final api = ref.read(subscriptionApiProvider);
      final response = switch (action) {
        _SubscriptionAction.pause =>
          await api.pauseSubscription(widget.subscriptionId),
        _SubscriptionAction.resume =>
          await api.resumeSubscription(widget.subscriptionId),
        _SubscriptionAction.cancel =>
          await api.cancelSubscription(widget.subscriptionId),
      };

      if (!response.success) {
        throw Exception(response.message ?? 'Subscription action failed');
      }

      ref.invalidate(mySubscriptionsProvider);
      await ref.refresh(
        subscriptionDetailProvider(widget.subscriptionId).future,
      );

      if (mounted) {
        SnackbarService().showSnackBar(
          'subscriptionActionSuccess'.tr(),
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarService().showSnackBar(
          '${'subscriptionActionFailed'.tr()}: $e',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingAction = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(subscriptionDetailProvider(widget.subscriptionId));
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
        title: Text('subscriptionDetails'.tr(), style: kSubHeadingM),
      ),
      body: detailAsync.when(
        data: (subscription) => Column(
          children: [
            Expanded(
              child: _SubscriptionDetailBody(
                subscription: subscription,
                preferredLanguage: preferredLanguage,
                statusLabel: _localizedStatus(subscription.status),
                statusColor: _statusColor(subscription.status),
                categoryLabel: subscription.campaignCategory != null
                    ? _localizedCategory(subscription.campaignCategory!)
                    : null,
              ),
            ),
            if (_canPause(subscription.status) ||
                _canResume(subscription.status) ||
                _canCancel(subscription.status))
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                decoration: const BoxDecoration(
                  color: kWhite,
                  border: Border(top: BorderSide(color: Color(0xFFDADADA))),
                ),
                child: Column(
                  children: [
                    if (_canPause(subscription.status)) ...[
                      primaryButton(
                        label: 'subscriptionPause'.tr(),
                        buttonColor: const Color(0xFFFF8800),
                        isLoading: _loadingAction == _SubscriptionAction.pause,
                        onPressed: _loadingAction != null
                            ? null
                            : () => _confirmAction(
                                  _SubscriptionAction.pause,
                                  title: 'subscriptionPause'.tr(),
                                  message: 'pauseSubscriptionConfirmation'.tr(),
                                  confirmText: 'subscriptionPause'.tr(),
                                ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_canResume(subscription.status)) ...[
                      primaryButton(
                        label: 'subscriptionResume'.tr(),
                        buttonColor: const Color(0xFF00C851),
                        isLoading: _loadingAction == _SubscriptionAction.resume,
                        onPressed: _loadingAction != null
                            ? null
                            : () => _confirmAction(
                                  _SubscriptionAction.resume,
                                  title: 'subscriptionResume'.tr(),
                                  message:
                                      'resumeSubscriptionConfirmation'.tr(),
                                  confirmText: 'subscriptionResume'.tr(),
                                ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_canCancel(subscription.status))
                      primaryButton(
                        label: 'subscriptionCancel'.tr(),
                        buttonColor: const Color(0xFFFF4D4F),
                        isLoading: _loadingAction == _SubscriptionAction.cancel,
                        onPressed: _loadingAction != null
                            ? null
                            : () => _confirmAction(
                                  _SubscriptionAction.cancel,
                                  title: 'subscriptionCancel'.tr(),
                                  message: 'cancelSubscriptionConfirmation'.tr(),
                                  confirmText: 'subscriptionCancel'.tr(),
                                ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        loading: () => const Center(child: LoadingAnimation()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${'errorLoadingSubscriptionDetails'.tr()}: $error',
                  textAlign: TextAlign.center,
                  style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.invalidate(
                    subscriptionDetailProvider(widget.subscriptionId),
                  ),
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

class _SubscriptionDetailBody extends StatelessWidget {
  final SubscriptionModel subscription;
  final String preferredLanguage;
  final String statusLabel;
  final Color statusColor;
  final String? categoryLabel;

  const _SubscriptionDetailBody({
    required this.subscription,
    required this.preferredLanguage,
    required this.statusLabel,
    required this.statusColor,
    this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final description = subscription.getDescription(preferredLanguage);
    final periodLabel =
        subscription.period == 'weekly' ? 'perWeek'.tr() : 'perMonth'.tr();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subscription.campaignCoverImage != null &&
              subscription.campaignCoverImage!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                subscription.campaignCoverImage!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (subscription.campaignCoverImage != null &&
              subscription.campaignCoverImage!.isNotEmpty)
            const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDADADA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subscription.getTitle(preferredLanguage),
                        style: kBodyTitleM,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                if (categoryLabel != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    categoryLabel!,
                    style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                  ),
                ],
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: kSmallerTitleR.copyWith(
                      color: kSecondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'planDetails'.tr(),
            children: [
              _DetailRow(
                label: 'amount'.tr(),
                value:
                    '₹${subscription.amount.toStringAsFixed(0)} $periodLabel',
              ),
              _DetailRow(
                label: 'selectPlan'.tr(),
                value: subscription.planType.replaceAll('_', ' '),
              ),
              _DetailRow(
                label: 'billingPeriod'.tr(),
                value: subscription.period,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'subscriptionInfo'.tr(),
            children: [
              _DetailRow(
                label: 'razorpaySubscriptionId'.tr(),
                value: subscription.subscriptionId,
              ),
              _DetailRow(
                label: 'planId'.tr(),
                value: subscription.planId,
              ),
              if (subscription.customerId != null &&
                  subscription.customerId!.isNotEmpty)
                _DetailRow(
                  label: 'customerId'.tr(),
                  value: subscription.customerId!,
                ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'dates'.tr(),
            children: [
              if (subscription.startDate != null)
                _DetailRow(
                  label: 'startDate'.tr(),
                  value: formatDate(subscription.startDate),
                ),
              if (subscription.nextBillingDate != null)
                _DetailRow(
                  label: 'nextBillingDate'.tr(),
                  value: formatDate(subscription.nextBillingDate),
                ),
              if (subscription.endDate != null)
                _DetailRow(
                  label: 'endDate'.tr(),
                  value: formatDate(subscription.endDate),
                ),
              if (subscription.createdAt != null)
                _DetailRow(
                  label: 'createdOn'.tr(),
                  value: formatDate(subscription.createdAt),
                ),
              if (subscription.updatedAt != null)
                _DetailRow(
                  label: 'updatedOn'.tr(),
                  value: formatDate(subscription.updatedAt),
                ),
            ],
          ),
          if (subscription.userName != null || subscription.userEmail != null)
            const SizedBox(height: 12),
          if (subscription.userName != null || subscription.userEmail != null)
            _SectionCard(
              title: 'subscriberInfo'.tr(),
              children: [
                if (subscription.userName != null)
                  _DetailRow(
                    label: 'name'.tr(),
                    value: subscription.userName!,
                  ),
                if (subscription.userEmail != null)
                  _DetailRow(
                    label: 'email'.tr(),
                    value: subscription.userEmail!,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDADADA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: kSmallerTitleSB),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: kSmallerTitleR.copyWith(
                color: kSecondaryTextColor,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: kSmallerTitleSB.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
