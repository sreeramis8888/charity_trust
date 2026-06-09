import 'dart:developer';

import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/campaign_model.dart';
import 'package:Annujoom/src/data/providers/razorpay_provider.dart';
import 'package:Annujoom/src/data/providers/subscription_provider.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/interfaces/components/additional_pages/payment_failed_page.dart';
import 'package:Annujoom/src/interfaces/components/additional_pages/payment_success_page.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  CampaignModel? _selectedCampaign;
  SubscriptionPlan? _selectedPlan;
  bool _isProcessing = false;

  String _getLocalizedCategory(String category) {
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

  Future<void> _handleSubscribe() async {
    if (_selectedCampaign?.id == null || _selectedPlan == null) {
      SnackbarService().showSnackBar(
        'pleaseSelectCampaignAndPlan'.tr(),
        type: SnackbarType.warning,
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final subscriptionApi = ref.read(subscriptionApiProvider);
      final response = await subscriptionApi.createSubscription(
        campaignId: _selectedCampaign!.id!,
        planType: _selectedPlan!.planType,
      );

      if (!response.success || response.data == null) {
        final message = response.message ?? 'Failed to create subscription';
        if (message.contains('Route not found')) {
          throw Exception('subscriptionApiNotAvailable'.tr());
        }
        throw Exception(message);
      }

      final data = response.data!['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid subscription response');
      }

      final subscriptionData = CreateSubscriptionResponse.fromJson(data);
      final userData = await ref.read(fetchUserProfileProvider.future);

      await _openRazorpaySubscription(
        subscriptionId: subscriptionData.subscriptionId,
        razorpayKey: subscriptionData.razorpayKey,
        email: userData?.email ?? '',
        phone: userData?.phone ?? '',
        amount: _selectedPlan!.amount.toDouble(),
      );
    } catch (e) {
      log('Subscription error: $e', name: 'SubscriptionPage');
      if (mounted) {
        SnackbarService().showSnackBar(
          '${'subscriptionFailed'.tr()}: $e',
          type: SnackbarType.error,
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _openRazorpaySubscription({
    required String subscriptionId,
    required String razorpayKey,
    required String email,
    required String phone,
    required double amount,
  }) async {
    final razorpayService = ref.read(razorpayServiceProvider);
    final campaignTitle = _selectedCampaign?.getTitle(
          GlobalVariables.getPreferredLanguage(),
        ) ??
        'Subscription';

    razorpayService.setCallbacks(
      onSuccess: (PaymentSuccessResponse response) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaymentSuccessPage(
                paymentId: response.paymentId,
                amount: amount,
              ),
            ),
          );
        }
      },
      onError: (PaymentFailureResponse response) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PaymentFailurePage()),
          );
        }
      },
      onExternalWallet: (ExternalWalletResponse response) {
        if (!mounted) return;
        SnackbarService().showSnackBar(
          '${'externalWalletSelected'.tr()}: ${response.walletName}',
          type: SnackbarType.info,
        );
        setState(() => _isProcessing = false);
      },
    );

    razorpayService.openSubscriptionCheckout(
      subscriptionId: subscriptionId,
      razorpayKey: razorpayKey,
      email: email,
      phone: phone,
      description: '${'subscription'.tr()} - $campaignTitle',
    );
  }

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(staticCampaignsForSubscriptionProvider);
    final plans = ref.watch(subscriptionPlansProvider);
    final weeklyPlans = plans.where((plan) => plan.isWeekly).toList();
    final monthlyPlans = plans.where((plan) => plan.isMonthly).toList();
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
        title: Text('subscription'.tr(), style: kSubHeadingM),
      ),
      body: campaignsAsync.when(
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'noStaticCampaignsFound'.tr(),
                  textAlign: TextAlign.center,
                  style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('selectCampaign'.tr(), style: kBodyTitleM),
                      const SizedBox(height: 10),
                      ...campaigns.map(
                        (campaign) => _CampaignOptionTile(
                          campaign: campaign,
                          title: campaign.getTitle(preferredLanguage),
                          categoryLabel:
                              _getLocalizedCategory(campaign.category),
                          isSelected: _selectedCampaign?.id == campaign.id,
                          onTap: () {
                            setState(() => _selectedCampaign = campaign);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('selectPlan'.tr(), style: kBodyTitleM),
                      const SizedBox(height: 10),
                      Text('weeklyPlans'.tr(), style: kSmallerTitleSB),
                      const SizedBox(height: 8),
                      _PlanGrid(
                        plans: weeklyPlans,
                        selectedPlan: _selectedPlan,
                        amountSuffix: 'perWeek'.tr(),
                        onSelect: (plan) {
                          setState(() => _selectedPlan = plan);
                        },
                      ),
                      const SizedBox(height: 18),
                      Text('monthlyPlans'.tr(), style: kSmallerTitleSB),
                      const SizedBox(height: 8),
                      _PlanGrid(
                        plans: monthlyPlans,
                        selectedPlan: _selectedPlan,
                        amountSuffix: 'perMonth'.tr(),
                        onSelect: (plan) {
                          setState(() => _selectedPlan = plan);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                decoration: const BoxDecoration(
                  color: kWhite,
                  border: Border(
                    top: BorderSide(color: Color(0xFFDADADA)),
                  ),
                ),
                child: primaryButton(
                  label: 'subscribe'.tr(),
                  isLoading: _isProcessing,
                  onPressed: _isProcessing ? null : _handleSubscribe,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: LoadingAnimation()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '${'errorLoadingCampaigns'.tr()}: $error',
              textAlign: TextAlign.center,
              style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _CampaignOptionTile extends StatelessWidget {
  final CampaignModel campaign;
  final String title;
  final String categoryLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _CampaignOptionTile({
    required this.campaign,
    required this.title,
    required this.categoryLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0601B4)
                    : const Color(0xFFDADADA),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: campaign.coverImage.isNotEmpty
                      ? Image.network(
                          campaign.coverImage,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _campaignPlaceholder(),
                        )
                      : _campaignPlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: kSmallerTitleSB,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryLabel,
                        style: kSmallerTitleR.copyWith(
                          color: kSecondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected
                      ? const Color(0xFF0601B4)
                      : kSecondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campaignPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: kGreyDark,
      child: const Icon(Icons.campaign, color: kWhite, size: 24),
    );
  }
}

class _PlanGrid extends StatelessWidget {
  final List<SubscriptionPlan> plans;
  final SubscriptionPlan? selectedPlan;
  final String amountSuffix;
  final ValueChanged<SubscriptionPlan> onSelect;

  const _PlanGrid({
    required this.plans,
    required this.selectedPlan,
    required this.amountSuffix,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: plans.map((plan) {
        final isSelected = selectedPlan?.planType == plan.planType;
        return GestureDetector(
          onTap: () => onSelect(plan),
          child: Container(
            width: (MediaQuery.of(context).size.width - 56) / 3,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0601B4).withOpacity(0.08)
                  : kWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0601B4)
                    : const Color(0xFFDADADA),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '₹${plan.amount}',
                  style: kBodyTitleSB.copyWith(
                    color: isSelected
                        ? const Color(0xFF0601B4)
                        : kTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amountSuffix,
                  textAlign: TextAlign.center,
                  style: kSmallerTitleR.copyWith(
                    color: kSecondaryTextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
