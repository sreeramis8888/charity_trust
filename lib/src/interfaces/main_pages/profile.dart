import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:charity_trust/src/interfaces/main_pages/profile_pages/my_participations.dart';
import 'package:charity_trust/src/interfaces/components/confirmation_dialog.dart';
import 'package:charity_trust/src/data/services/secure_storage_service.dart';
import 'package:charity_trust/src/data/providers/auth_login_provider.dart';
import 'package:charity_trust/src/data/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: kWhite,
        elevation: 0,
        title: Text("Profile", style: kSubHeadingM),
      ),
      body: FutureBuilder(
        future: ref.read(secureStorageServiceProvider).getUserData(),
        builder: (context, snapshot) {
          final userData = snapshot.data;
          final userName = userData?.name ?? 'User';
          final userPhone = userData?.phone ?? 'Phone number';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromTop,
                  duration: anim.AnimationDuration.normal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: kGreyDark,
                            child: const Icon(Icons.person,
                                color: kWhite, size: 40),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: kHeadTitleR,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userPhone,
                                style: kBodyTitleR.copyWith(
                                    color: kSecondaryTextColor),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('EditProfile');
                          },
                          icon:
                              const Icon(Icons.edit_square, color: kTextColor),
                        )
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 22),
                // Text("Account Statistics", style: kBodyTitleM),
                // const SizedBox(height: 10),
                // Container(
                //     padding: const EdgeInsets.all(18),
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //           colors: [Color(0xFFFFFFFF), Color(0xFFEEEDFF)],
                //           begin: AlignmentGeometry.topCenter,
                //           end: AlignmentGeometry.bottomCenter),
                //       borderRadius: BorderRadius.circular(22),
                //     ),
                //     child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           _statItem("10", "My Participations"),
                //           _statItem("₹12,500", "Contributions"),
                //         ],
                //       ),
                //       const SizedBox(height: 18),
                //       Container(height: 2, color: kStrokeColor.withOpacity(0.06)),
                //       const SizedBox(height: 18),
                //       _statItem("₹10,000", "Zakat"),
                //     ],
                //   ),
                // ),
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
                              builder: (context) =>
                                  const MyParticipationsPage(),
                            ),
                          );
                        },
                        child: _tile(
                            Icons.volunteer_activism, "My Participations"),
                      ),
                      _divider(),
                      GestureDetector(
                        onTap: () => _handleLogout(context, ref),
                        child: _tile(Icons.logout, "Logout"),
                      ),
                      _divider(),
                      GestureDetector(
                        onTap: () => _handleDeleteAccount(context, ref),
                        child: _tile(Icons.delete_outline, "Delete Account",
                            isDestructive: true),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: kBodyTitleSB.copyWith(
            color: kThirdTextColor,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          label,
          style: kSmallTitleM,
        ),
      ],
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

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Logout',
        message: 'Are you sure you want to logout?',
        confirmButtonText: 'Logout',
        onConfirm: () => _performLogout(context, ref),
      ),
    );
  }

  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      final authLoginApi = ref.read(authLoginApiProvider);
      final authProvider = ref.read(authProviderProvider);

      // Call logout API
      final response = await authLoginApi.logout();

      // Clear local storage regardless of API response
      await authProvider.clearAllData();

      if (context.mounted) {
        // Navigate to login screen
        Navigator.of(context)
            .pushNamedAndRemoveUntil('Phone', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  void _handleDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Account',
        message:
            'Are you sure you want to delete your account? This action cannot be undone.',
        confirmButtonText: 'Delete',
        onConfirm: () => _performDeleteAccount(context, ref),
      ),
    );
  }

  Future<void> _performDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    try {
      final authLoginApi = ref.read(authLoginApiProvider);
      final authProvider = ref.read(authProviderProvider);

      // Call logout API (using same functionality for now)
      final response = await authLoginApi.logout();

      // Clear local storage regardless of API response
      await authProvider.clearAllData();

      if (context.mounted) {
        // Navigate to login screen
        Navigator.of(context)
            .pushNamedAndRemoveUntil('Phone', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete account failed: $e')),
        );
      }
    }
  }
}
