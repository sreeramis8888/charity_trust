import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/shorebird_update_provider.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import 'primaryButton.dart';

class UpdateCheckerWidget extends ConsumerStatefulWidget {
  final Widget child;
  final bool showUpdateDialog;

  const UpdateCheckerWidget({
    required this.child,
    this.showUpdateDialog = true,
    super.key,
  });

  @override
  ConsumerState<UpdateCheckerWidget> createState() =>
      _UpdateCheckerWidgetState();
}

class _UpdateCheckerWidgetState extends ConsumerState<UpdateCheckerWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.showUpdateDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUpdates();
      });
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      final isAvailable = await ref.read(updateAvailableProvider.future);

      if (isAvailable && mounted) {
        _showUpdateDialog();
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: kWhite,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: kPrimaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'New Update Available!',
                style: kHeadTitleSB,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'A newer version of the app is available for download. Update now to get the latest features and improvements.',
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              primaryButton(
                label: 'Update Now',
                onPressed: () {
                  Navigator.pop(context);
                  _downloadUpdate();
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: kGreyDark,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Maybe Later',
                  style: kSmallTitleM.copyWith(color: kGreyDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadUpdate() async {
    if (!mounted) return;

    // Show downloading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: kWhite,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Downloading Update...',
                style: kSubHeadingSB,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we prepare the best experience for you.',
                style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final service = ref.read(shorebirdUpdateServiceProvider);
      final success = await service.downloadAndInstallUpdate();

      if (!mounted) return;
      Navigator.pop(context); // Close downloading dialog

      if (success) {
        _showRestartDialog();
      } else {
        _showErrorSnackBar('Failed to download update. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close downloading dialog
      _showErrorSnackBar('Error downloading update: $e');
    }
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: kWhite,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Update Ready!',
                style: kHeadTitleSB,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'The update has been downloaded successfully. Look out for the changes on the next restart.',
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              primaryButton(
                label: 'Got it',
                onPressed: () => Navigator.pop(context),
                buttonColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: kWhite, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: kSmallTitleM.copyWith(color: kWhite))),
          ],
        ),
        backgroundColor: kRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class UpdateBadge extends ConsumerWidget {
  const UpdateBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patchNumberAsync = ref.watch(currentPatchNumberProvider);

    return patchNumberAsync.when(
      data: (patchNumber) {
        if (patchNumber == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.system_update_alt_rounded,
                color: kWhite,
                size: 10,
              ),
              const SizedBox(width: 4),
              Text(
                'v$patchNumber',
                style: kSmallerTitleSB.copyWith(color: kWhite),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

