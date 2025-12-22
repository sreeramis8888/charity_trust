import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends ConsumerState<LanguageSelectionPage> {
  Future<void> _selectLanguage(String languageCode) async {
    // 1. Save to Secure Storage
    final secureStorage = ref.read(secureStorageServiceProvider);
    await secureStorage.setPreferredLanguage(languageCode);

    // 2. Update Global Variable
    GlobalVariables.setPreferredLanguage(languageCode);

    // 3. Update App Locale
    if (mounted) {
      await context.setLocale(Locale(languageCode));
    }

    // 4. Navigate to Phone
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('Phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        size: 48,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'selectLanguage'.tr(),
                      style: kHeadTitleB.copyWith(color: kTextColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your preferred language to continue',
                      style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 200,
                child: _LanguageCard(
                  title: 'English',
                  subtitle: 'English',
                  code: 'en',
                  onTap: () => _selectLanguage('en'),
                ),
              ),
              const SizedBox(height: 16),
              anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 300,
                child: _LanguageCard(
                  title: 'മലയാളം',
                  subtitle: 'Malayalam',
                  code: 'ml',
                  onTap: () => _selectLanguage('ml'),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String code;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: kBorder.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  code.toUpperCase(),
                  style: kBodyTitleB.copyWith(color: kPrimaryColor),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: kBodyTitleSB.copyWith(color: kTextColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: kGreyDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
