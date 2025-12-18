import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/router/nav_router.dart';
import 'package:Annujoom/src/data/services/navigation_service.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/utils/globals.dart';

// Create a provider for DeepLinkService
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService(ref);
});

class DeepLinkService {
  final Ref _ref;
  final _appLinks = AppLinks();
  Uri? _pendingDeepLink;

  // Constructor that takes a Ref
  DeepLinkService(this._ref);

  Uri? get pendingDeepLink => _pendingDeepLink;
  void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  // Initialize and handle deep links
  Future<void> initialize(BuildContext context) async {
    try {
      // Handle deep link when app is started from terminated state
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        _pendingDeepLink = appLink;
      }

      // Handle deep link when app is in background or foreground
      _appLinks.uriLinkStream.listen((uri) {
        _pendingDeepLink = uri;
        handleDeepLink(uri);
      });
    } catch (e) {
      debugPrint('Deep link initialization error: $e');
    }
  }

  Future<void> handleDeepLink(Uri uri) async {
    try {
      // First ensure token is loaded
      final secureStorage = _ref.read(secureStorageServiceProvider);
      String? savedToken = await secureStorage.getBearerToken();
      String? savedId = await secureStorage.getUserId();
      if (savedToken == null || savedToken.isEmpty || savedId == null) {
        _showError('User not authenticated');
        return;
      }

      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return;

      debugPrint('Handling deep link: ${uri.toString()}');
      debugPrint('Path segments: $pathSegments');

      // Check if app is in the foreground
      bool isAppForeground =
          NavigationService.navigatorKey.currentState?.overlay != null;

      if (!isAppForeground) {
        debugPrint('App is not in foreground, navigating to mainpage first');
        NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          'navbar',
          (route) => false,
        );

        await Future.delayed(Duration(milliseconds: 500));
      }

      switch (pathSegments[0]) {
        case 'campaign':
          try {
            if (NavigationService.navigatorKey.currentState != null) {
              NavigationService.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                'navbar',
                (route) => false,
              );
              await Future.delayed(Duration(milliseconds: 500));
              _ref.read(selectedIndexProvider.notifier).updateIndex(1);
            }
          } catch (e) {
            debugPrint('Error navigating to campaign: $e');
            _showError('Unable to navigate to Campaign');
          }
          break;

        case 'general':
        default:
          try {
            if (NavigationService.navigatorKey.currentState != null) {
              NavigationService.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                'navbar',
                (route) => false,
              );
              await Future.delayed(Duration(milliseconds: 500));
              _ref.read(selectedIndexProvider.notifier).updateIndex(3);

              // Navigate to notifications page
              NavigationService.navigatorKey.currentState
                  ?.pushNamed('Notifications');
            }
          } catch (e) {
            debugPrint('Error navigating to notifications: $e');
            _showError('Unable to navigate to Notifications');
          }
          break;
      }
    } catch (e) {
      debugPrint('Deep link handling error: $e');
      _showError('Unable to process the notification');
    }
  }

  void _showError(String message) {
    if (NavigationService.navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
          .showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  String? getDeepLinkPath(String screen, {String? id}) {
    switch (screen) {
      case 'campaign':
        return 'annujoom://app/campaign${id != null ? '/$id' : ''}';
      case 'general':
        return 'annujoom://app/general';
      case 'news':
        return 'annujoom://app/news';
      default:
        return 'annujoom://app/general';
    }
  }
}
