import 'dart:async';
import 'dart:developer';
import 'package:Annujoom/src/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/constants/color_constants.dart';
import '../../data/services/navigation_service.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/services/version_check_service.dart';
import '../../data/services/secure_storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool isAppUpdateRequired = false;
  bool forceUpdate = false;
  bool hasVersionCheckError = false;
  String errorMessage = '';
  String? updateLink;
  late AnimationController _controller;
  late AnimationController _backgroundController;
  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    log('SplashScreen initState called', name: 'SplashScreen');
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    );
    log('Animation controllers initialized', name: 'SplashScreen');
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.2, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 40),
    ]).animate(_controller);
    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.0)
        .chain(CurveTween(curve: Curves.easeOutExpo))
        .animate(_controller);
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(_controller);

    // Background image animations
    _backgroundController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    // Welcome text animations
    _textController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _controller.forward();
    log('Starting app initialization', name: 'SplashScreen');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      log('_initializeApp: Starting version check', name: 'SplashScreen');
      // Check version first
      await _checkAppVersion();

      // If update is required and forced, show dialog and don't proceed
      if (isAppUpdateRequired && forceUpdate) {
        log('_initializeApp: Force update required, stopping initialization',
            name: 'SplashScreen');
        return;
      }

      log('_initializeApp: Proceeding to authentication check',
          name: 'SplashScreen');
      // Check authentication and load user
      await _checkAuthenticationAndLoadUser();
    } catch (e) {
      log('Error initializing app: $e', name: 'SplashScreen');
      _startNavigationTimer();
    }
  }

  Future<void> _checkAppVersion() async {
    try {
      log('_checkAppVersion: Starting version check', name: 'SplashScreen');
      final versionCheckService = ref.read(versionCheckServiceProvider);
      final versionResponse = await versionCheckService.checkVersion();

      if (versionResponse != null) {
        log('_checkAppVersion: Version response received - force: ${versionResponse.force}, version: ${versionResponse.version}',
            name: 'SplashScreen');
        setState(() {
          isAppUpdateRequired = true;
          forceUpdate = versionResponse.force;
          errorMessage = versionResponse.updateMessage;
          updateLink = versionResponse.applink;
        });
        log('_checkAppVersion: State updated - isAppUpdateRequired: $isAppUpdateRequired, forceUpdate: $forceUpdate',
            name: 'SplashScreen');

        if (forceUpdate) {
          log('_checkAppVersion: Showing force update dialog',
              name: 'SplashScreen');
          _showForceUpdateDialog();
        } else {
          log('_checkAppVersion: Showing optional update dialog',
              name: 'SplashScreen');
          _showOptionalUpdateDialog();
        }
      } else {
        log('_checkAppVersion: No version response received',
            name: 'SplashScreen');
      }
    } catch (e) {
      log('Error checking version: $e', name: 'SplashScreen');
    }
  }

  void _showForceUpdateDialog() {
    log('_showForceUpdateDialog: Displaying force update dialog',
        name: 'SplashScreen');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Required'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              log('_showForceUpdateDialog: User tapped Update Now',
                  name: 'SplashScreen');
              _openAppStore();
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _showOptionalUpdateDialog() {
    log('_showOptionalUpdateDialog: Displaying optional update dialog',
        name: 'SplashScreen');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              log('_showOptionalUpdateDialog: User tapped Later',
                  name: 'SplashScreen');
              Navigator.pop(context);
              _checkAuthenticationAndLoadUser();
            },
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              log('_showOptionalUpdateDialog: User tapped Update',
                  name: 'SplashScreen');
              _openAppStore();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppStore() async {
    log('_openAppStore: Attempting to open app store with link: $updateLink',
        name: 'SplashScreen');
    if (updateLink != null && updateLink!.isNotEmpty) {
      try {
        if (await canLaunchUrl(Uri.parse(updateLink!))) {
          log('_openAppStore: URL is launchable, opening...',
              name: 'SplashScreen');
          await launchUrl(
            Uri.parse(updateLink!),
            mode: LaunchMode.externalApplication,
          );
          log('_openAppStore: URL launched successfully', name: 'SplashScreen');
        } else {
          log('Could not launch update link: $updateLink',
              name: 'SplashScreen');
        }
      } catch (e) {
        log('Error opening app store: $e', name: 'SplashScreen');
      }
    } else {
      log('_openAppStore: Update link is null or empty', name: 'SplashScreen');
    }
  }

  Future<void> _checkAuthenticationAndLoadUser() async {
    try {
      log('_checkAuthenticationAndLoadUser: Starting authentication check',
          name: 'SplashScreen');
      final authProvider = ref.read(authProviderProvider);
      final isAuthenticated = await authProvider.isAuthenticated();
      final bearer = await authProvider.getBearerToken();
      log('$bearer', name: 'Bearer');
      log('_checkAuthenticationAndLoadUser: isAuthenticated = $isAuthenticated',
          name: 'SplashScreen');

      if (isAuthenticated) {
        log('_checkAuthenticationAndLoadUser: User is authenticated, loading user data',
            name: 'SplashScreen');
        // Fetch current user status from API
        log('_checkAuthenticationAndLoadUser: Fetching current user status from API',
            name: 'SplashScreen');
        var user = await ref.read(fetchCurrentUserStatusProvider.future);

        if (!mounted) {
          log('_checkAuthenticationAndLoadUser: Widget not mounted after API call, skipping navigation',
              name: 'SplashScreen');
          return;
        }

        if (user != null) {
          log('_checkAuthenticationAndLoadUser: User status fetched from API - id: ${user.id}, status: ${user.status}',
              name: 'SplashScreen');
        } else {
          log('_checkAuthenticationAndLoadUser: Failed to fetch user status from API, trying local storage',
              name: 'SplashScreen');
          // Fallback to local storage if API fails
          final secureStorage = ref.read(secureStorageServiceProvider);
          user = await secureStorage.getUserData();
          if (user != null) {
            log('_checkAuthenticationAndLoadUser: User loaded from secure storage - id: ${user.id}, status: ${user.status}',
                name: 'SplashScreen');
          }
        }

        if (mounted) {
          log('_checkAuthenticationAndLoadUser: Widget mounted, navigating based on status: ${user?.status}',
              name: 'SplashScreen');
          _navigateBasedOnUserStatus(user?.status);
        } else {
          log('_checkAuthenticationAndLoadUser: Widget not mounted, skipping navigation',
              name: 'SplashScreen');
        }
      } else {
        log('_checkAuthenticationAndLoadUser: User is not authenticated, starting navigation timer to Phone screen',
            name: 'SplashScreen');
        // Not authenticated, go to phone login
        if (mounted) {
          _startNavigationTimer();
        }
      }
    } catch (e) {
      log('Error checking authentication: $e', name: 'SplashScreen');
      if (mounted) {
        log('_checkAuthenticationAndLoadUser: Error occurred, starting navigation timer to Phone screen',
            name: 'SplashScreen');
        _startNavigationTimer();
      }
    }
  }

  void _navigateBasedOnUserStatus(String? status) {
    if (!mounted) {
      log('_navigateBasedOnUserStatus: Widget not mounted, skipping navigation',
          name: 'SplashScreen');
      return;
    }

    log('_navigateBasedOnUserStatus: Navigating based on status: $status',
        name: 'SplashScreen');
    switch (status) {
      case 'active':
        log('_navigateBasedOnUserStatus: Navigating to navbar',
            name: 'SplashScreen');
        NavigationService().pushNamedAndRemoveUntil('navbar');
        break;
      case 'inactive':
        log('_navigateBasedOnUserStatus: Navigating to registration',
            name: 'SplashScreen');
        NavigationService().pushNamedAndRemoveUntil('registration');
        break;
      case 'pending':
        log('_navigateBasedOnUserStatus: Navigating to requestSent',
            name: 'SplashScreen');
        NavigationService().pushNamedAndRemoveUntil('requestSent');
        break;
      case 'rejected':
        log('_navigateBasedOnUserStatus: Navigating to requestRejected',
            name: 'SplashScreen');
        NavigationService().pushNamedAndRemoveUntil('requestRejected');
        break;
      case 'suspended':
        log('_navigateBasedOnUserStatus: Navigating to accountSuspended',
            name: 'SplashScreen');
        NavigationService().pushNamedAndRemoveUntil('accountSuspended');
        break;
      default:
        log('_navigateBasedOnUserStatus: Unknown status, navigating to Phone',
            name: 'SplashScreen');
        NavigationService().pushNamedAndRemoveUntil('Phone');
    }
  }

  void _startNavigationTimer() {
    log('_startNavigationTimer: Starting 2.5 second timer before navigating to Phone',
        name: 'SplashScreen');
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      if (mounted) {
        log('_startNavigationTimer: Timer completed, navigating to Phone',
            name: 'SplashScreen');
        NavigationService().pushNamedAndRemoveUntil('Phone');
      } else {
        log('_startNavigationTimer: Widget not mounted when timer completed',
            name: 'SplashScreen');
      }
    });
  }

  @override
  void dispose() {
    log('dispose: Cleaning up SplashScreen resources', name: 'SplashScreen');
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _backgroundController.dispose();
    _textController.dispose();
    super.dispose();
    log('dispose: SplashScreen disposed', name: 'SplashScreen');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log('didChangeAppLifecycleState: App lifecycle changed to $state',
        name: 'SplashScreen');
  }

  Future<void> retryVersionCheck() async {
    log('retryVersionCheck: User tapped retry, resetting state and reinitializing',
        name: 'SplashScreen');
    setState(() {
      hasVersionCheckError = false;
      errorMessage = '';
      isAppUpdateRequired = false;
      forceUpdate = false;
      updateLink = null;
    });
    log('retryVersionCheck: State reset, calling _initializeApp',
        name: 'SplashScreen');
    await _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Container(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: SizedBox(width: 230,
                          child: Container(
                            child: Image.asset(
                              'assets/png/annujoom_logo.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (hasVersionCheckError)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 100.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 12),
                            TextButton(
                              onPressed: retryVersionCheck,
                              style: TextButton.styleFrom(
                                backgroundColor: kWhite.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                  color: kWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
