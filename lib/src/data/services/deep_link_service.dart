import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:charity_trust/src/data/router/nav_router.dart';
import 'package:charity_trust/src/data/services/navigation_service.dart';
import 'package:charity_trust/src/data/services/secure_storage_service.dart';
import 'package:charity_trust/src/data/utils/globals.dart';



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
      if (token.isEmpty) {
        final secureStorage = _ref.read(secureStorageServiceProvider);
        String? savedToken = await secureStorage.getBearerToken();
        String? savedId = await secureStorage.getUserId();
        if (savedToken != null && savedToken.isNotEmpty && savedId != null) {
          token = savedToken;
          id = savedId;
          LoggedIn = true;
        }
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
          'MainPage',
          (route) => false,
        );

        await Future.delayed(Duration(milliseconds: 500));
      }

      switch (pathSegments[0]) {
        case 'chat':
          // if (pathSegments.length > 1) {
          //   final userId = pathSegments[1];
          //   try {
          //     final chatApi = _ref.read(chatApiServiceProvider);
          //     final conversation = await chatApi.create1to1Conversation(userId);
          //     UserModel? otherMember = conversation?.members
          //         ?.firstWhere((m) => m.id != id, orElse: () => UserModel());

          //     if (conversation != null) {
          //       // NavigationService.navigatorKey.currentState?.push(
          //       //   MaterialPageRoute(
          //       //     builder: (context) => ChatScreen(
          //       //       userImage: otherMember?.image ?? '',
          //       //       conversationId: conversation.id ?? '',
          //       //       chatTitle: otherMember?.name ?? '',
          //       //       userId: userId,
          //       //     ),
          //       //   ),
          //       // );
          //     } else {
          //       _showError('Failed to start chat.');
          //     }
          //   } catch (e) {
          //     debugPrint('Error starting chat: $e');
          //     _showError('Failed to start chat.');
          //   }
          // }
          break;

        case 'my_requirements':
          try {
            if (NavigationService.navigatorKey.currentState != null) {
              NavigationService.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                'MainPage',
                (route) => false,
              );
              await Future.delayed(Duration(milliseconds: 500));
              NavigationService.navigatorKey.currentState
                  ?.pushNamed('MyRequirements');
            }
          } catch (e) {
            debugPrint('Error navigating to requirements: $e');
            _showError('Unable to navigate to requirements');
          }
          break;
        case 'analytics':
          try {
            if (NavigationService.navigatorKey.currentState != null) {
              NavigationService.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                'MainPage',
                (route) => false,
              );
              await Future.delayed(Duration(milliseconds: 500));
              NavigationService.navigatorKey.currentState
                  ?.pushNamed('Analytics');
            }
          } catch (e) {
            debugPrint('Error navigating to Activity: $e');
            _showError('Unable to navigate to Activity');
          }
          break;
        case 'my_enquiries':
          try {
            if (NavigationService.navigatorKey.currentState != null) {
              NavigationService.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                'MainPage',
                (route) => false,
              );
              await Future.delayed(Duration(milliseconds: 500));
              NavigationService.navigatorKey.currentState
                  ?.pushNamed('EnquiriesPage');
            }
          } catch (e) {
            debugPrint('Error navigating to Enquiries: $e');
            _showError('Unable to navigate to Enquiries');
          }
          break;
        case 'my_reviews':
          try {
            if (NavigationService.navigatorKey.currentState != null) {
              NavigationService.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                'MainPage',
                (route) => false,
              );
              await Future.delayed(Duration(milliseconds: 500));
              NavigationService.navigatorKey.currentState
                  ?.pushNamed('MyReviews');
            }
          } catch (e) {
            debugPrint('Error navigating to Reviews: $e');
            _showError('Unable to navigate to Reviews');
          }
          break;

        case 'requirements':
          try {
            if (NavigationService.navigatorKey.currentState != null) {
              NavigationService.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                'MainPage',
                (route) => false,
              );
              await Future.delayed(Duration(milliseconds: 500));
              _ref.read(selectedIndexProvider.notifier).updateIndex(2);
            }
          } catch (e) {
            debugPrint('Error updating tab: $e');
            _showError('Unable to navigate to requirements');
          }
          break;

        case 'news':
          try {
            // First navigate to mainpage if not already there
            if (NavigationService.navigatorKey.currentState != null) {
              NavigationService.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                'MainPage',
                (route) => false,
              );
              await Future.delayed(Duration(milliseconds: 500));
              _ref.read(selectedIndexProvider.notifier).updateIndex(3);
            }
          } catch (e) {
            debugPrint('Error updating tab: $e');
            _showError('Unable to navigate to News');
          }
          break;
        case 'products':
          try {
            // First navigate to mainpage if not already there
            if (NavigationService.navigatorKey.currentState != null) {
              NavigationService.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                'MainPage',
                (route) => false,
              );
              await Future.delayed(Duration(milliseconds: 500));
              _ref.read(selectedIndexProvider.notifier).updateIndex(5);
            }
          } catch (e) {
            debugPrint('Error updating tab: $e');
            _showError('Unable to navigate to products');
          }
          break;

        case 'mainpage':
          NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            'MainPage',
            (route) => false,
          );
          break;

        default:
          // final notificationApiService =
          //     _ref.watch(notificationApiServiceProvider);
          // List<NotificationModel> notifications =
          //     await notificationApiService.fetchNotifications();

          // NavigationService.navigatorKey.currentState
          //     ?.pushNamed('NotificationPage', arguments: notifications);

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
      case 'chat':
        return id != null
            ? 'charity_trust://app/chat/$id'
            : 'charity_trust://app/chat';
      case 'events':
        return id != null
            ? 'charity_trust://app/events/$id'
            : 'charity_trust://app/events';
      case 'my_products':
        return 'charity_trust://app/my_products';
      case 'my_requirements':
        return 'charity_trust://app/my_requirements';
      case 'analytics':
        return 'charity_trust://app/analytics';
      case 'in-app':
        return 'charity_trust://app/notification';
      // case 'products':
      //   return id != null
      //       ? 'charity_trust://app/products/$id'
      //       : 'charity_trust://app/products';
      case 'news':
        return 'charity_trust://app/news';
      case 'my_events':
        return 'charity_trust://app/my_events';
      case 'requirements':
        return 'charity_trust://app/requirements';
      case 'my_enquiries':
        return 'charity_trust://app/my_enquiries';
      case 'my_reviews':
        return 'charity_trust://app/my_reviews';
      case 'mainpage':
        return 'charity_trust://app/mainpage';
      case 'products':
        return 'charity_trust://app/products';
      default:
        return 'charity_trust://app/general';
    }
  }
}
