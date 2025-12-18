import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/providers/auth_provider.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';

class RequestSentState extends ConsumerWidget {
  const RequestSentState({super.key});

  void _handleStatusCheck(BuildContext context, WidgetRef ref) async {
    final userStatus = await ref.read(fetchCurrentUserStatusProvider.future);

    if (!context.mounted) return;

    if (userStatus == null) return;

    // Save updated user status to secure storage
    final secureStorage = ref.read(secureStorageServiceProvider);
    await secureStorage.saveUserData(userStatus);

    switch (userStatus.status) {
      case 'active':
        Navigator.of(context).pushNamedAndRemoveUntil(
          'navbar',
          (route) => false,
        );
        break;
      case 'rejected':
        Navigator.of(context).pushNamedAndRemoveUntil(
          'RequestRejected',
          (route) => false,
        );
        break;
      case 'suspended':
        Navigator.of(context).pushNamedAndRemoveUntil(
          'AccountSuspended',
          (route) => false,
        );
        break;
      default:
        // pending or other statuses - stay on current screen
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => _handleStatusCheck(context, ref),
                child: Row(
                  children: [
                    const Icon(
                      Icons.refresh,
                      color: kPrimaryColor,
                      size: 24,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Refresh',
                      style: kBodyTitleM.copyWith(color: kPrimaryColor),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/request_sent.svg',
              ),
              const SizedBox(height: 40),
              Text(
                'Your request to join has been sent',
                style: kHeadTitleSB,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Our team will review your details and enable your access shortly. Please stay tuned.',
                style: kSmallTitleR.copyWith(
                  color: kSecondaryTextColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () async {
                  final authProvider = ref.read(authProviderProvider);
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      'Phone',
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
