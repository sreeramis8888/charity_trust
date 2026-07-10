import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/router/nav_router.dart';
import 'package:Annujoom/src/data/services/navigation_service.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/providers/campaigns_provider.dart';
import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:Annujoom/src/data/utils/date_formatter.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService(ref);
});

class DeepLinkService {
  final Ref _ref;
  final _appLinks = AppLinks();
  Uri? _pendingDeepLink;

  /// Prevents the same campaign/news link from opening multiple times
  /// (initial link + uri stream + splash/navbar all can fire for one tap).
  bool _isHandling = false;
  String? _lastHandledKey;
  DateTime? _lastHandledAt;
  static const _dedupeWindow = Duration(seconds: 5);

  DeepLinkService(this._ref);

  Uri? get pendingDeepLink => _pendingDeepLink;

  void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  /// Normalize https://host/app/campaign/id and annujoom://app/campaign/id
  /// to the same key so scheme differences don't bypass dedupe.
  String _linkKey(Uri uri) {
    var segments =
        uri.pathSegments.where((segment) => segment.isNotEmpty).toList();

    if (segments.isNotEmpty && segments.first == 'app') {
      segments = segments.sublist(1);
    }

    // Custom scheme: annujoom://app/campaign/id → host=app, path=/campaign/id
    if (uri.host == 'app' && segments.isNotEmpty) {
      return segments.join('/');
    }

    return segments.join('/');
  }

  bool _shouldSkipDuplicate(String key) {
    if (key.isEmpty) return false;
    if (_lastHandledKey != key || _lastHandledAt == null) return false;
    return DateTime.now().difference(_lastHandledAt!) < _dedupeWindow;
  }

  /// Initialize deep link handling
  /// Call this in your main app after navigation is ready
  Future<void> initialize() async {
    try {
      debugPrint('🔗 Deep link service initializing...');

      // Cold start: store only — splash/navbar will handle once navigator is ready
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        _pendingDeepLink = appLink;
        debugPrint(
            '🔗 Initial deep link stored as pending: ${appLink.toString()}');
      } else {
        debugPrint('🔗 No initial deep link found');
      }

      // Warm start / subsequent links while app is alive
      _appLinks.uriLinkStream.listen((uri) {
        debugPrint('🔗 ⚡ Deep link stream: ${uri.toString()}');

        // Same link as cold-start pending → let splash handle it once
        final pending = _pendingDeepLink;
        if (pending != null && _linkKey(pending) == _linkKey(uri)) {
          debugPrint(
              '🔗 Stream matches pending initial link — skipping immediate handle');
          return;
        }

        _pendingDeepLink = uri;
        handleDeepLink(uri);
      });

      debugPrint('🔗 Deep link service initialized successfully');
    } catch (e) {
      debugPrint('❌ Deep link initialization error: $e');
    }
  }

  /// Main deep link handler - routes to appropriate screen
  Future<void> handleDeepLink(Uri uri) async {
    final key = _linkKey(uri);

    if (_isHandling) {
      debugPrint('🔗 Already handling a deep link — ignoring $key');
      return;
    }

    if (_shouldSkipDuplicate(key)) {
      debugPrint('🔗 Duplicate deep link within dedupe window — ignoring $key');
      clearPendingDeepLink();
      return;
    }

    _isHandling = true;
    _lastHandledKey = key;
    _lastHandledAt = DateTime.now();
    // Clear early so splash + navbar cannot process the same link again
    clearPendingDeepLink();

    try {
      debugPrint('🔗 Deep link received: ${uri.toString()}');
      debugPrint('🔗 Path key: $key');

      var pathSegments =
          uri.pathSegments.where((segment) => segment.isNotEmpty).toList();

      if (pathSegments.isNotEmpty && pathSegments[0] == 'app') {
        pathSegments = pathSegments.sublist(1);
      }

      debugPrint('🔗 Filtered segments: $pathSegments');

      final secureStorage = _ref.read(secureStorageServiceProvider);
      final savedToken = await secureStorage.getBearerToken();
      final savedId = await secureStorage.getUserId();

      if (savedToken == null || savedToken.isEmpty || savedId == null) {
        debugPrint(
            'Authentication required for deep link. Redirecting to login.');

        if (NavigationService.navigatorKey.currentState == null) {
          await Future.delayed(const Duration(milliseconds: 500));
        }

        // Keep link for after login; allow it to be handled again then
        _pendingDeepLink = uri;
        _lastHandledKey = null;
        _lastHandledAt = null;
        NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          'Phone',
          (route) => false,
        );
        return;
      }

      if (NavigationService.navigatorKey.currentState == null) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (pathSegments.isEmpty) {
        debugPrint('🔗 No valid route in deep link, redirecting to home');
        await _navigateToHome();
        return;
      }

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
          await _navigateToHome();
          break;
        default:
          debugPrint(
              '🔗 Unknown deep link route: $route. Staying on current page.');
          break;
      }
    } catch (e) {
      debugPrint('❌ Deep link handling error: $e');
      _showError('Unable to process the link');
    } finally {
      _isHandling = false;
    }
  }

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

  Future<void> _navigateToCampaign(String? campaignId) async {
    try {
      final navigator = NavigationService.navigatorKey.currentState;
      if (navigator == null) return;

      // Reset to navbar once, then open a single CampaignDetail
      navigator.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _ref.read(selectedIndexProvider.notifier).updateIndex(1);

      if (campaignId == null || campaignId.isEmpty) {
        debugPrint('✅ Navigated to Campaigns');
        return;
      }

      final campaign =
          await _ref.read(singleCampaignProvider(campaignId).future);
      if (campaign == null) {
        debugPrint('⚠️ Campaign not found: $campaignId');
        _showError('Campaign not found');
        return;
      }

      final preferredLanguage = GlobalVariables.getPreferredLanguage();
      NavigationService.navigatorKey.currentState?.pushNamed(
        'CampaignDetail',
        arguments: {
          '_id': campaign.id,
          'title': campaign.getTitle(preferredLanguage),
          'description': campaign.getDescription(preferredLanguage),
          'category': campaign.category,
                'date': campaign.targetDate != null
                    ? formatDate(campaign.targetDate)
                    : '',
                'image': campaign.coverImage,
                'raised': campaign.collectedAmount?.toInt(),
                'goal': campaign.targetAmount?.toInt(),
                'isDirectCategory': false,
        },
      );
      debugPrint('✅ Navigated to Campaign Detail: $campaignId');
    } catch (e) {
      debugPrint('Error navigating to campaign: $e');
      _showError('Unable to navigate to Campaign');
    }
  }

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

  Future<void> _navigateToNotifications() async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _ref.read(selectedIndexProvider.notifier).updateIndex(0);
      NavigationService.navigatorKey.currentState?.pushNamed('Notifications');
      debugPrint('✅ Navigated to Notifications');
    } catch (e) {
      debugPrint('Error navigating to notifications: $e');
      _showError('Unable to navigate to Notifications');
    }
  }

  Future<void> _navigateToProfile() async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _ref.read(selectedIndexProvider.notifier).updateIndex(3);
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

  /// Generate deep link URLs for sharing.
  /// Uses API host `/app/...` so the backend HTML can open the app or store.
  String generateDeepLink(String route, {String? id}) {
    final apiBase = dotenv.env['BASE_URL'] ?? '';
    final webBase = apiBase.replaceAll(RegExp(r'/api/v1/?$'), '');
    final baseUrl = webBase.isNotEmpty
        ? '$webBase/app'
        : 'https://api.annujoomcharitabletrust.com/app';

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
