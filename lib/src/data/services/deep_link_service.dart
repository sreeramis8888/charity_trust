import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/router/nav_router.dart';
import 'package:Annujoom/src/data/services/navigation_service.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService(ref);
});

class DeepLinkService {
  final Ref _ref;
  final _appLinks = AppLinks();
  Uri? _pendingDeepLink;

  DeepLinkService(this._ref);

  Uri? get pendingDeepLink => _pendingDeepLink;

  void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  /// Initialize deep link handling
  /// Call this in your main app after navigation is ready
  Future<void> initialize() async {
    try {
      // Handle deep link when app is launched from terminated state
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        _pendingDeepLink = appLink;
        await Future.delayed(const Duration(milliseconds: 500));
        await handleDeepLink(appLink);
      }

      // Handle deep links when app is in background/foreground
      _appLinks.uriLinkStream.listen((uri) {
        _pendingDeepLink = uri;
        handleDeepLink(uri);
      });
    } catch (e) {
      debugPrint('Deep link initialization error: $e');
    }
  }

  /// Main deep link handler - routes to appropriate screen
  Future<void> handleDeepLink(Uri uri) async {
    try {
      debugPrint('🔗 Deep link received: ${uri.toString()}');
      debugPrint('🔗 Path segments: ${uri.pathSegments}');
      debugPrint('🔗 Query parameters: ${uri.queryParameters}');

      // Verify user is authenticated
      final secureStorage = _ref.read(secureStorageServiceProvider);
      final savedToken = await secureStorage.getBearerToken();
      final savedId = await secureStorage.getUserId();

      if (savedToken == null || savedToken.isEmpty || savedId == null) {
        _showError('Please login to access this content');
        return;
      }

      // Ensure navigator is ready
      if (NavigationService.navigatorKey.currentState == null) {
        debugPrint('Navigator not ready, retrying...');
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) {
        _navigateToHome();
        return;
      }

      // Route based on path
      final route = pathSegments[0].toLowerCase();
      final id = pathSegments.length > 1 ? pathSegments[1] : null;

      switch (route) {
        case 'campaign':
          await _navigateToCampaign(id);
          break;
        case 'news':
          await _navigateToNews(id);
          break;
        case 'notifications':
          await _navigateToNotifications();
          break;
        case 'profile':
          await _navigateToProfile();
          break;
        case 'general':
        default:
          await _navigateToHome();
      }
    } catch (e) {
      debugPrint('❌ Deep link handling error: $e');
      _showError('Unable to process the link');
    }
  }

  /// Navigate to home/navbar
  Future<void> _navigateToHome() async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      _ref.read(selectedIndexProvider.notifier).updateIndex(0);
      debugPrint('✅ Navigated to Home');
    } catch (e) {
      debugPrint('Error navigating to home: $e');
    }
  }

  /// Navigate to campaigns
  Future<void> _navigateToCampaign(String? campaignId) async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _ref.read(selectedIndexProvider.notifier).updateIndex(1);

      // If campaign ID provided, navigate to campaign details
      if (campaignId != null && campaignId.isNotEmpty) {
        NavigationService.navigatorKey.currentState?.pushNamed(
          'CampaignDetails',
          arguments: {'id': campaignId},
        );
        debugPrint('✅ Navigated to Campaign Details: $campaignId');
      } else {
        debugPrint('✅ Navigated to Campaigns');
      }
    } catch (e) {
      debugPrint('Error navigating to campaign: $e');
      _showError('Unable to navigate to Campaign');
    }
  }

  /// Navigate to news
  Future<void> _navigateToNews(String? newsId) async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _ref.read(selectedIndexProvider.notifier).updateIndex(2);

      if (newsId != null && newsId.isNotEmpty) {
        NavigationService.navigatorKey.currentState?.pushNamed(
          'NewsDetails',
          arguments: {'id': newsId},
        );
        debugPrint('✅ Navigated to News Details: $newsId');
      } else {
        debugPrint('✅ Navigated to News');
      }
    } catch (e) {
      debugPrint('Error navigating to news: $e');
      _showError('Unable to navigate to News');
    }
  }

  /// Navigate to notifications
  Future<void> _navigateToNotifications() async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _ref.read(selectedIndexProvider.notifier).updateIndex(3);
      NavigationService.navigatorKey.currentState?.pushNamed('Notifications');
      debugPrint('✅ Navigated to Notifications');
    } catch (e) {
      debugPrint('Error navigating to notifications: $e');
      _showError('Unable to navigate to Notifications');
    }
  }

  /// Navigate to profile
  Future<void> _navigateToProfile() async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _ref.read(selectedIndexProvider.notifier).updateIndex(4);
      debugPrint('✅ Navigated to Profile');
    } catch (e) {
      debugPrint('Error navigating to profile: $e');
      _showError('Unable to navigate to Profile');
    }
  }

  void _showError(String message) {
    if (NavigationService.navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Generate deep link URLs for sharing
  /// Use HTTPS links for WhatsApp/social media compatibility
  String generateDeepLink(String route, {String? id}) {
    // Use HTTPS for clickable links in WhatsApp, Gmail, etc.
    const baseUrl = 'https://app.annujoomcharitabletrust.com/app';
    
    switch (route) {
      case 'campaign':
        return id != null ? '$baseUrl/campaign/$id' : '$baseUrl/campaign';
      case 'news':
        return id != null ? '$baseUrl/news/$id' : '$baseUrl/news';
      case 'notifications':
        return '$baseUrl/notifications';
      case 'profile':
        return '$baseUrl/profile';
      default:
        return '$baseUrl/general';
    }
  }
}
