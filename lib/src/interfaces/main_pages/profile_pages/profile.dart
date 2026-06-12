import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:Annujoom/src/data/services/webview_services.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/my_participations.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/about_us.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/refer_friend_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/change_phone_number.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/zakat_calculator.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/quran_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/subscription_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/my_subscriptions_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/referrals/my_referrals_page.dart';
import 'package:Annujoom/src/interfaces/components/confirmation_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/services/notification_service/get_fcm.dart';
import 'package:Annujoom/src/data/providers/auth_login_provider.dart';
import 'package:Annujoom/src/data/providers/auth_provider.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (mounted) {
      setState(() {
        _notificationsEnabled =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
                settings.authorizationStatus == AuthorizationStatus.provisional;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(fetchUserProfileProvider);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: kWhite,
        elevation: 0,
        title: Text("profile".tr(), style: kSubHeadingM),
      ),
      body: userDataAsync.when(
        data: (userData) {
          if (userData == null) {
            return Center(
              child: Text(
                'Unable to load profile data',
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
              ),
            );
          }

          final userName = userData.name ?? 'User';
          final userPhone = userData.phone ?? 'Phone number';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_notificationsEnabled)
                  anim.AnimatedWidgetWrapper(
                    animationType: anim.AnimationType.fadeSlideInFromTop,
                    duration: anim.AnimationDuration.fast,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimaryColor.withOpacity(0.1),
                            kPrimaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_off_outlined,
                              color: kPrimaryColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'notificationsDisabled'.tr(),
                                  style: kSmallTitleSB.copyWith(
                                    color: kTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'enableToStayUpdated'.tr(),
                                  style: kSmallerTitleR.copyWith(
                                    color: kSecondaryTextColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              await handleNotificationPermissions(context, ref);
                              await _checkNotificationStatus();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'enable'.tr(),
                              style: kSmallerTitleSB.copyWith(
                                color: kWhite,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromTop,
                  duration: anim.AnimationDuration.normal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Avatar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: kGreyDark,
                            child: userData.image != null &&
                                    userData.image!.isNotEmpty
                                ? Image.network(
                                    userData.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      color: kWhite,
                                      size: 36,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: kWhite,
                                    size: 36,
                                  ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  /// Name
                                  Expanded(
                                    child: Text(
                                      userName,
                                      style: kHeadTitleR.copyWith(height: 1.0),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  /// Verified icon
                                  if (userData.role != null &&
                                      userData.role != 'member') ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified,
                                      color: Color(0xFFFFC107),
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                userPhone,
                                style: kBodyTitleR.copyWith(
                                  color: kSecondaryTextColor,
                                  height: 0.9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 2),

                        /// Edit button
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.of(context).pushNamed('EditProfile');
                          },
                          icon: const Icon(
                            Icons.edit_square,
                            color: kTextColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text("accountStatistics".tr(), style: kBodyTitleM),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFEEEDFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              value:
                                  "${userData.totalCampaignsParticipated ?? 0}",
                              label: "myParticipations",
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _StatItem(
                              value: "₹${userData.totalAmountDonated ?? 0}",
                              label: "amountDonated",
                            ),
                          ),
                        ],
                      ),
                      if (userData.role != null &&
                          userData.role != 'member') ...[
                        const SizedBox(height: 18),
                        Divider(height: 1, color: Color(0xFFCEE8F8)),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _StatItem(
                                value: "${userData.totalReferrals ?? 0}",
                                label: "totalReferrals",
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _StatItem(
                                value: "${userData.activeReferrals ?? 0}",
                                label: "activeReferrals",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFD8DADC)),
                    color: kCardBackgroundColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MySubscriptionsPage(),
                            ),
                          );
                        },
                        child: _tile(
                          Icons.subscriptions_outlined,
                          "viewMySubscriptions".tr(),
                        ),
                      ),
                      _divider(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionPage(),
                            ),
                          );
                        },
                        child: _tile(Icons.autorenew, "subscription".tr()),
                      ),
                      _divider(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MyParticipationsPage(),
                            ),
                          );
                        },
                        child: _tile(
                          Icons.volunteer_activism,
                          userData.role != null && userData.role != 'member'
                              ? "myCampaigns".tr()
                              : "myParticipations".tr(),
                        ),
                      ),
                      if (userData.role != null &&
                          userData.role != 'member') ...[
                        _divider(),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MyReferralsPage(),
                              ),
                            );
                          },
                          child: _tile(Icons.people, "referrals".tr()),
                        ),
                      ],
                      _divider(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AboutUsPage(),
                            ),
                          );
                        },
                        child: _tile(Icons.info_outline, "aboutUs".tr()),
                      ),
                      _divider(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ReferFriendPage(),
                            ),
                          );
                        },
                        child: _tile(Icons.card_giftcard, "referAFriend".tr()),
                      ),
                      _divider(),
                      GestureDetector(
                        onTap: () => _handleRateApp(context),
                        child: _tile(Icons.star_outline, "rateApp".tr()),
                      ),
                      // _divider(),
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (context) => const ChangePhoneNumberPage(),
                      //       ),
                      //     );
                      //   },
                      //   child: _tile(Icons.phone, "changePhoneNumber".tr()),
                      // ),
                      _divider(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ZakatCalculatorPage(),
                            ),
                          );
                        },
                        child: _tile(Icons.calculate, "zakatCalculator".tr()),
                      ),
                      _divider(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const QuranPage(),
                            ),
                          );
                        },
                        child: _tile(Icons.menu_book, "quran".tr()),
                      ),
                      _divider(),
                      GestureDetector(
                        onTap: () => _handleLanguageChange(context, ref),
                        child: _tile(Icons.language, "language".tr()),
                      ),
                      _divider(),
                      GestureDetector(
                        onTap: () => _handleLogout(context, ref),
                        child: _tile(Icons.logout, "logout".tr()),
                      ),
                      _divider(),
                      GestureDetector(
                        onTap: () => _handleDeleteAccount(context, ref),
                        child: _tile(Icons.delete_outline, "deleteAccount".tr(),
                            isDestructive: true),
                      ),
                      _divider(),
                      // Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WebViewScreen(
                                        url: 'https://www.skybertech.com/',
                                        title: 'Skybertech',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Color(0xFFDADADA)),
                                    color: Color(0xFFF3F3F3),
                                  ),
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top: 10, left: 22, right: 22),
                                        child: Text(
                                          'Powered by',
                                          style: TextStyle(
                                              fontSize: 12, color: kBlack),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 80,
                                        width: 100,
                                        child: Image.asset(
                                          'assets/png/skybertech.png',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WebViewScreen(
                                        url: 'https://www.xyvin.com/',
                                        title: 'Xyvin Technologies',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Color(0xFFDADADA)),
                                    // color: Color.fromARGB(255, 197, 195, 195),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 8),
                                    child: Column(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              top: 2, bottom: 3),
                                          child: Text(
                                            'Developed by',
                                            style: TextStyle(
                                                fontSize: 12, color: kBlack),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        SizedBox(
                                          height: 60,
                                          width: 120,
                                          child: Image.asset(
                                            fit: BoxFit.contain,
                                            'assets/png/xyvin.png',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
        loading: () => const Center(
          child: LoadingAnimation(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error loading profile: $error'),
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          _iconCircle(icon, isDestructive: isDestructive),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: kSmallerTitleL.copyWith(
                color: isDestructive ? kPrimaryColor : kTextColor,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: isDestructive ? kPrimaryColor : kTextColor,
          ),
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon, {bool isDestructive = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDestructive
            ? kPrimaryColor.withOpacity(0.1)
            : const Color(0xFF0601B4).withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 15,
        color: isDestructive ? kPrimaryColor : Colors.black54,
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Divider(
        color: Color(0xFFDADADA),
        thickness: 1,
        height: 0,
      ),
    );
  }

  void _handleLanguageChange(BuildContext context, WidgetRef ref) {
    final currentLanguage = GlobalVariables.preferredLanguage;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: kWhite,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'language'.tr(),
                style: kHeadTitleSB.copyWith(
                  fontSize: 18,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 20),
              _languageOption(
                context,
                ref,
                'english'.tr(),
                'en',
                isSelected: currentLanguage == 'en',
              ),
              const SizedBox(height: 10),
              _languageOption(
                context,
                ref,
                'malayalam'.tr(),
                'ml',
                isSelected: currentLanguage == 'ml',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'close'.tr(),
                    style: kSmallerTitleL.copyWith(
                      color: kSecondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageOption(
    BuildContext context,
    WidgetRef ref,
    String languageName,
    String languageCode, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () async {
        // If already selected, just close the dialog
        if (isSelected) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          return;
        }

        try {
          // Update global language
          GlobalVariables.setPreferredLanguage(languageCode);

          // Update easy_localization locale
          await context.setLocale(Locale(languageCode));

          // Save to secure storage
          final secureStorage = SecureStorageService();
          await secureStorage.setPreferredLanguage(languageCode);

          // Update language in user profile via API
          await ref.read(updateUserProfileProvider(
            {'preferred_language': languageCode},
          ).future);

          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${'languageChanged'.tr()} $languageName'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${'errorChangingLanguage'.tr()} $e'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0601B4).withOpacity(0.08)
              : kBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0601B4).withOpacity(0.3)
                : kStrokeColor.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              languageName,
              style: kSmallerTitleL.copyWith(
                color: isSelected ? const Color(0xFF0601B4) : kTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 18,
                color: Color(0xFF0601B4),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: kSecondaryTextColor,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRateApp(BuildContext context) async {
    try {
      String appUrl;
      String errorKey;

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        appUrl = 'https://apps.apple.com/in/app/annujoom-connect/id6756281138';
        errorKey = 'couldNotOpenAppStore';
      } else {
        appUrl =
            'https://play.google.com/store/apps/details?id=com.annujoomconnect';
        errorKey = 'couldNotOpenPlayStore';
      }

      await launchUrl(
        Uri.parse(appUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'errorOpeningStore'.tr()}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'logout'.tr(),
        message: 'logoutConfirmation'.tr(),
        confirmButtonText: 'logout'.tr(),
        onConfirm: () {
          _performLogout(context, ref);
        },
      ),
    );
  }

  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      final authLoginApi = ref.read(authLoginApiProvider);
      final authProvider = ref.read(authProviderProvider);

      // Call logout API
      await authLoginApi.logout();

      // Clear local storage regardless of API response
      await authProvider.clearAllData();

      if (context.mounted) {
        // Navigate to Phone screen and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil(
          'Phone',
          (route) => false,
        );
      }
    } catch (e) {
      // Clear local storage even if API fails
      try {
        final authProvider = ref.read(authProviderProvider);
        await authProvider.clearAllData();
      } catch (_) {}

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'logoutFailed'.tr()}: $e')),
        );
        // Still navigate to login even if there was an error
        Navigator.of(context).pushNamedAndRemoveUntil(
          'Phone',
          (route) => false,
        );
      }
    }
  }

  void _handleDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'deleteAccount'.tr(),
        message: 'deleteAccountConfirmation'.tr(),
        confirmButtonText: 'delete'.tr(),
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          _performDeleteAccount(context, ref);
        },
      ),
    );
  }

  Future<void> _performDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    try {
      final authLoginApi = ref.read(authLoginApiProvider);
      final authProvider = ref.read(authProviderProvider);

      // Call logout API (using same functionality for now)
      await authLoginApi.logout();

      // Clear local storage regardless of API response
      await authProvider.clearAllData();

      if (context.mounted) {
        // Navigate to login screen and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil(
          'Phone',
          (route) => false,
        );
      }
    } catch (e) {
      // Clear local storage even if API fails
      try {
        final authProvider = ref.read(authProviderProvider);
        await authProvider.clearAllData();
      } catch (_) {}

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'deleteAccountFailed'.tr()}: $e')),
        );
        // Still navigate to login even if there was an error
        Navigator.of(context).pushNamedAndRemoveUntil(
          'Phone',
          (route) => false,
        );
      }
    }
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          softWrap: true,
          style: kBodyTitleSB.copyWith(
            color: kThirdTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label.tr(),
          softWrap: true,
          style: kSmallTitleM,
        ),
      ],
    );
  }
}
