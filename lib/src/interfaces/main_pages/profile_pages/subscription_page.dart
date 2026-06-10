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

  void _showPlanBottomSheet(CampaignModel campaign) {
    final plans = ref.read(subscriptionPlansProvider);
    final weeklyPlans = plans.where((plan) => plan.isWeekly).toList();
    final monthlyPlans = plans.where((plan) => plan.isMonthly).toList();
    final preferredLanguage = GlobalVariables.getPreferredLanguage();
    SubscriptionPlan? sheetSelectedPlan = _selectedPlan;
    bool sheetProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: SafeArea(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDADADA),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('selectPlan'.tr(), style: kBodyTitleM),
                          const SizedBox(height: 6),
                          Text(
                            campaign.getTitle(preferredLanguage),
                            style: kSmallerTitleR.copyWith(
                              color: kSecondaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 18),
                          Text('weeklyPlans'.tr(), style: kSmallerTitleSB),
                          const SizedBox(height: 8),
                          _PlanGrid(
                            plans: weeklyPlans,
                            selectedPlan: sheetSelectedPlan,
                            amountSuffix: 'perWeek'.tr(),
                            onSelect: (plan) {
                              setSheetState(() => sheetSelectedPlan = plan);
                            },
                          ),
                          const SizedBox(height: 18),
                          Text('monthlyPlans'.tr(), style: kSmallerTitleSB),
                          const SizedBox(height: 8),
                          _PlanGrid(
                            plans: monthlyPlans,
                            selectedPlan: sheetSelectedPlan,
                            amountSuffix: 'perMonth'.tr(),
                            onSelect: (plan) {
                              setSheetState(() => sheetSelectedPlan = plan);
                            },
                          ),
                          const SizedBox(height: 20),
                          primaryButton(
                            label: 'submit'.tr(),
                            isLoading: sheetProcessing,
                            onPressed: sheetProcessing
                                ? null
                                : () async {
                                    if (sheetSelectedPlan == null) {
                                      SnackbarService().showSnackBar(
                                        'pleaseSelectPlan'.tr(),
                                        type: SnackbarType.warning,
                                      );
                                      return;
                                    }

                                    setSheetState(() => sheetProcessing = true);
                                    setState(() {
                                      _selectedCampaign = campaign;
                                      _selectedPlan = sheetSelectedPlan;
                                    });

                                    final success = await _handleSubscribe();
                                    if (!sheetContext.mounted) return;

                                    if (success) {
                                      Navigator.of(sheetContext).pop();
                                    } else {
                                      setSheetState(
                                          () => sheetProcessing = false);
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _handleSubscribe() async {
    if (_selectedCampaign?.id == null || _selectedPlan == null) {
      SnackbarService().showSnackBar(
        'pleaseSelectCampaignAndPlan'.tr(),
        type: SnackbarType.warning,
      );
      return false;
    }

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
      return true;
    } catch (e) {
      log('Subscription error: $e', name: 'SubscriptionPage');
      if (mounted) {
        SnackbarService().showSnackBar(
          '${'subscriptionFailed'.tr()}: $e',
          type: SnackbarType.error,
        );
      }
      return false;
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              Text('selectCampaign'.tr(), style: kBodyTitleM),
              const SizedBox(height: 10),
              ...campaigns.map(
                (campaign) => _CampaignOptionTile(
                  campaign: campaign,
                  title: campaign.getTitle(preferredLanguage),
                  categoryLabel: _getLocalizedCategory(campaign.category),
                  isSelected: _selectedCampaign?.id == campaign.id,
                  onTap: () => _showPlanBottomSheet(campaign),
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
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: kSecondaryTextColor,
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
                  : kBackgroundColor,
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
                    color: isSelected ? const Color(0xFF0601B4) : kTextColor,
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
