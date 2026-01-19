import 'dart:async';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:Annujoom/src/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/constants/global_variables.dart';
import '../../data/services/navigation_service.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/services/version_check_service.dart';
import '../../data/services/secure_storage_service.dart';
import '../../data/services/notification_service/get_fcm.dart';
import '../../data/services/deep_link_service.dart';

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
      log('_initializeApp: Starting notification permissions',
          name: 'SplashScreen');
      // Request notification permissions first
      await handleNotificationPermissions(context, ref);

      log('_initializeApp: Starting version check', name: 'SplashScreen');
      // Check version first
      // await _checkAppVersion();

      // If update is required (forced or optional) or server error, stop initialization and stay on splash
      if (isAppUpdateRequired || hasVersionCheckError) {
        log('_initializeApp: Update required or server error, stopping initialization and staying on splash',
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

  // Future<void> _checkAppVersion() async {
  //   try {
  //     log('_checkAppVersion: Starting version check', name: 'SplashScreen');
  //     final versionCheckService = ref.read(versionCheckServiceProvider);
  //     final versionResponse = await versionCheckService.checkVersion();

  //     if (versionResponse != null) {
  //       // Get current app version
  //       final packageInfo = await PackageInfo.fromPlatform();
  //       final currentVersion = int.tryParse(packageInfo.buildNumber) ?? 0;
  //       final newVersion = versionResponse.version;

  //       log('_checkAppVersion: Version comparison - Current: $currentVersion, New: $newVersion, Force: ${versionResponse.force}',
  //           name: 'SplashScreen');

  //       // Only show update if new version is greater than current version
  //       if (newVersion > currentVersion) {
  //         setState(() {
  //           isAppUpdateRequired = true;
  //           forceUpdate = versionResponse.force;
  //           errorMessage = versionResponse.updateMessage;
  //           updateLink = versionResponse.applink;
  //           hasVersionCheckError = false;
  //         });
  //         log('_checkAppVersion: State updated - isAppUpdateRequired: $isAppUpdateRequired, forceUpdate: $forceUpdate',
  //             name: 'SplashScreen');
  //       } else {
  //         log('_checkAppVersion: App is up to date. Current: $currentVersion, New: $newVersion',
  //             name: 'SplashScreen');
  //       }
  //     } else {
  //       log('_checkAppVersion: No version response received',
  //           name: 'SplashScreen');
  //       // Treat null response as server error
  //       setState(() {
  //         hasVersionCheckError = true;
  //         errorMessage = 'serverDownMessage'.tr();
  //         isAppUpdateRequired = true;
  //       });
  //       log('_checkAppVersion: Server error - no response received, staying on splash',
  //           name: 'SplashScreen');
  //     }
  //   } catch (e) {
  //     log('Error checking version: $e', name: 'SplashScreen');
  //     setState(() {
  //       hasVersionCheckError = true;
  //       errorMessage = 'serverDownMessage'.tr();
  //       isAppUpdateRequired = true;
  //     });
  //     log('_checkAppVersion: Exception caught - staying on splash screen',
  //         name: 'SplashScreen');
  //   }
  // }



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
        // Fetch complete user profile from API
        log('_checkAuthenticationAndLoadUser: Fetching complete user profile from API',
            name: 'SplashScreen');
        var user = await ref.read(fetchUserProfileProvider.future);

        if (!mounted) {
          log('_checkAuthenticationAndLoadUser: Widget not mounted after API call, skipping navigation',
              name: 'SplashScreen');
          return;
        }

        if (user != null) {
          log('_checkAuthenticationAndLoadUser: User profile fetched from API - id: ${user.id}, status: ${user.status}',
              name: 'SplashScreen');
          // Save user data to secure storage
          final secureStorage = ref.read(secureStorageServiceProvider);
          await secureStorage.saveUserData(user);
          log('_checkAuthenticationAndLoadUser: User data saved to secure storage',
              name: 'SplashScreen');
          
          // Set language preference in global variables
          if (user.preferredLanguage != null) {
            GlobalVariables.setPreferredLanguage(user.preferredLanguage!);
            log('_checkAuthenticationAndLoadUser: Language set in global variables - ${user.preferredLanguage}',
                name: 'SplashScreen');
          }

          // Set user role in global variables
          if (user.role != null) {
            GlobalVariables.setUserRole(user.role!);
            log('_checkAuthenticationAndLoadUser: User role set in global variables - ${user.role}',
                name: 'SplashScreen');
          }

          if (mounted) {
            log('_checkAuthenticationAndLoadUser: Widget mounted, navigating based on API status: ${user.status}',
                name: 'SplashScreen');
            _navigateBasedOnUserStatus(user.status);
            
            // Handle pending deep link after navigation
            await Future.delayed(const Duration(milliseconds: 500));
            _handlePendingDeepLink();
          }
        } else {
          log('_checkAuthenticationAndLoadUser: Failed to fetch user profile from API, trying local storage',
              name: 'SplashScreen');
          // Fallback to local storage if API fails
          final secureStorage = ref.read(secureStorageServiceProvider);
          user = await secureStorage.getUserData();
          if (user != null) {
            log('_checkAuthenticationAndLoadUser: User loaded from secure storage - id: ${user.id}, status: ${user.status}',
                name: 'SplashScreen');
            log('WARNING: Using cached user data from secure storage instead of fresh API data',
                name: 'SplashScreen');
            
            // Set language preference in global variables
            if (user.preferredLanguage != null) {
              GlobalVariables.setPreferredLanguage(user.preferredLanguage!);
              log('_checkAuthenticationAndLoadUser: Language set in global variables from cached data - ${user.preferredLanguage}',
                  name: 'SplashScreen');
            }

            // Set user role in global variables
            if (user.role != null) {
              GlobalVariables.setUserRole(user.role!);
              log('_checkAuthenticationAndLoadUser: User role set in global variables from cached data - ${user.role}',
                  name: 'SplashScreen');
            }

            if (mounted) {
              log('_checkAuthenticationAndLoadUser: Widget mounted, navigating based on local storage status: ${user.status}',
                  name: 'SplashScreen');
              _navigateBasedOnUserStatus(user.status);
              
              // Handle pending deep link after navigation
              await Future.delayed(const Duration(milliseconds: 500));
              _handlePendingDeepLink();
            }
          } else {
            log('_checkAuthenticationAndLoadUser: No user data in secure storage either, navigating to Phone',
                name: 'SplashScreen');
            if (mounted) {
              NavigationService().pushNamedAndRemoveUntil('languageSelection');
            }
          }
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
        log('_navigateBasedOnUserStatus: Unknown status, navigating to languageSelection',
            name: 'SplashScreen');
        NavigationService().pushNamedAndRemoveUntil('languageSelection');
    }
  }

  void _startNavigationTimer() {
    log('_startNavigationTimer: Starting 2.5 second timer before navigating to Phone',
        name: 'SplashScreen');
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      if (mounted) {
        log('_startNavigationTimer: Timer completed, navigating to languageSelection',
            name: 'SplashScreen');
        NavigationService().pushNamedAndRemoveUntil('languageSelection');
      } else {
        log('_startNavigationTimer: Widget not mounted when timer completed',
            name: 'SplashScreen');
      }
    });
  }

  void _handlePendingDeepLink() {
    try {
      final deepLinkService = ref.read(deepLinkServiceProvider);
      final pendingLink = deepLinkService.pendingDeepLink;
      
      if (pendingLink != null) {
        log('_handlePendingDeepLink: Processing pending deep link: ${pendingLink.toString()}',
            name: 'SplashScreen');
        deepLinkService.handleDeepLink(pendingLink);
        deepLinkService.clearPendingDeepLink();
      } else {
        log('_handlePendingDeepLink: No pending deep link to process',
            name: 'SplashScreen');
      }
    } catch (e) {
      log('Error handling pending deep link: $e', name: 'SplashScreen');
    }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: SvgPicture.asset(
                            'assets/svg/annujoom_logo.svg',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (hasVersionCheckError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.2),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_off_outlined,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'serverDownMessage'.tr(),
                            style: kHeadTitleB.copyWith(
                              color: kTextColor,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Please check your internet connection and try again.',
                            style: kBodyTitleR.copyWith(
                              color: kSecondaryTextColor,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: retryVersionCheck,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'retry'.tr(),
                                style: kBodyTitleM.copyWith(color: kWhite),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
