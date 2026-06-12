import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/providers/subscription_provider.dart';
import 'package:Annujoom/src/data/utils/date_formatter.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/main_pages/subscription/my_subscriptions_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SubscriptionSuccessPage extends StatelessWidget {
  final SubscriptionCheckoutDetails details;

  const SubscriptionSuccessPage({
    super.key,
    required this.details,
  });

  String _billingPeriodLabel() {
    return details.billingPeriod == 'weekly' ? 'perWeek'.tr() : 'perMonth'.tr();
  }

  String _planLabel() {
    return '₹${details.amount.toStringAsFixed(0)} ${_billingPeriodLabel()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.close, color: kTextColor, size: 28),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C851).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF00C851),
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'subscriptionSetupSuccess'.tr(),
                textAlign: TextAlign.center,
                style: kBodyTitleM,
              ),
              const SizedBox(height: 8),
              Text(
                'subscriptionSetupSuccessMessage'.tr(),
                textAlign: TextAlign.center,
                style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'amount'.tr(),
                      value: '₹${details.amount.toStringAsFixed(0)}',
                    ),
                    const _DetailDivider(),
                    _DetailRow(
                      label: 'planLabel'.tr(),
                      value: _planLabel(),
                    ),
                    const _DetailDivider(),
                    _DetailRow(
                      label: 'billingPeriod'.tr(),
                      value: _billingPeriodLabel(),
                    ),
                    const _DetailDivider(),
                    _DetailRow(
                      label: 'razorpaySubscriptionId'.tr(),
                      value: details.subscriptionId,
                    ),
                    const _DetailDivider(),
                    _DetailRow(
                      label: 'planId'.tr(),
                      value: details.planId,
                    ),
                    const _DetailDivider(),
                    _DetailRow(
                      label: 'startDate'.tr(),
                      value: formatDate(details.startDate),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              primaryButton(
                label: 'viewMySubscriptions'.tr(),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MySubscriptionsPage(),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
              const SizedBox(height: 12),
              primaryButton(
                label: 'backToHome'.tr(),
                buttonColor: kWhite,
                labelColor: kPrimaryColor,
                sideColor: kPrimaryColor,
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: kSmallerTitleSB,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFEDEDED));
  }
}
