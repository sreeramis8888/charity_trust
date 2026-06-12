import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/main_pages/subscription/subscription_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SubscriptionFailedPage extends StatelessWidget {
  final String? errorMessage;

  const SubscriptionFailedPage({
    super.key,
    this.errorMessage,
  });

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: kRed.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: kRed,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'subscriptionSetupFailed'.tr(),
                textAlign: TextAlign.center,
                style: kBodyTitleM,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'subscriptionSetupFailedMessage'.tr(),
                textAlign: TextAlign.center,
                style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
              ),
              const Spacer(),
              primaryButton(
                label: 'tryAgain'.tr(),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionPage(),
                    ),
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
