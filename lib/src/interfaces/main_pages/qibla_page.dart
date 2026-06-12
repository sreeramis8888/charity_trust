import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text('qiblaFinder'.tr(), style: kSubHeadingM),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.explore_outlined,
                  color: kPrimaryColor,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'qiblaFinder'.tr(),
                style: kBodyTitleM,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'qiblaComingSoon'.tr(),
                textAlign: TextAlign.center,
                style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
