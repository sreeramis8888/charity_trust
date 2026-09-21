import 'dart:convert';

import 'package:Annujoom/src/data/providers/campaigns_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Categories shown in the home carousel that load cover images from the API.
const homeNetworkCategories = <String>[
  'General Funding',
  'Zakat',
  'Orphan',
  'Widow',
  'Ghusl Mayyit',
  'Patient Relief',
  'Food Kit',
  'Sadaqah Jariyah',
];

const _coverCacheKey = 'home_category_cover_images_v1';
const _coverCacheAtKey = 'home_category_cover_images_cached_at_v1';
const _coverCacheTtl = Duration(days: 1);
const _fetchTimeout = Duration(seconds: 10);

Future<Map<String, String>> _readCachedCovers() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_coverCacheKey);
  if (raw == null || raw.isEmpty) return {};

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    )..removeWhere((_, value) => value.isEmpty);
  } catch (_) {
    return {};
  }
}

Future<void> _writeCachedCovers(Map<String, String> covers) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_coverCacheKey, jsonEncode(covers));
  await prefs.setInt(
    _coverCacheAtKey,
    DateTime.now().millisecondsSinceEpoch,
  );
}

Future<bool> _isCacheFresh() async {
  final prefs = await SharedPreferences.getInstance();
  final cachedAtMs = prefs.getInt(_coverCacheAtKey);
  if (cachedAtMs == null) return false;

  final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMs);
  return DateTime.now().difference(cachedAt) < _coverCacheTtl;
}

/// Lightweight parse — only category + cover_image, no full CampaignModel.
Future<Map<String, String>> _fetchCoverImagesFromApi(
  CampaignsApi campaignsApi,
) async {
  final response = await campaignsApi
      .getAllCampaigns(
        pageNo: 1,
        limit: 50,
        myCampaigns: false,
      )
      .timeout(_fetchTimeout);

  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Failed to load category covers');
  }

  final rawList = response.data!['data'];
  if (rawList is! List) return {};

  final needed = homeNetworkCategories.toSet();
  final covers = <String, String>{};

  for (final item in rawList) {
    if (covers.length >= needed.length) break;
    if (item is! Map) continue;

    final category = item['category']?.toString() ?? '';
    final coverImage = item['cover_image']?.toString() ?? '';
    if (category.isEmpty || coverImage.isEmpty) continue;
    if (!needed.contains(category) || covers.containsKey(category)) continue;

    covers[category] = coverImage;
  }

  return covers;
}

class CategoryCoverImagesNotifier
    extends StateNotifier<AsyncValue<Map<String, String>>> {
  CategoryCoverImagesNotifier(this._ref)
      : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref _ref;
  bool _disposed = false;

  Future<void> _init() async {
    // 1) Show local cache immediately so Home never waits on network.
    final cached = await _readCachedCovers();
    if (_disposed) return;

    if (cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    }

    final shouldFetch = cached.isEmpty || !await _isCacheFresh();
    if (!shouldFetch || _disposed) return;

    // 2) Refresh in background with a hard timeout — never hang the app.
    try {
      final api = _ref.read(campaignsApiProvider);
      final fresh = await _fetchCoverImagesFromApi(api);
      if (_disposed) return;

      if (fresh.isNotEmpty) {
        await _writeCachedCovers(fresh);
        if (_disposed) return;
        state = AsyncValue.data(fresh);
      } else if (cached.isEmpty) {
        state = const AsyncValue.data({});
      }
    } catch (_) {
      if (_disposed) return;
      // Keep cache if we have it; otherwise empty map (placeholders), not error.
      if (cached.isEmpty) {
        state = const AsyncValue.data({});
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Non-blocking category → cover URL map for the home carousel.
///
/// - Returns SharedPreferences cache first (instant).
/// - Refreshes from one campaigns API call with a timeout.
/// - Image bytes are cached on disk by CachedNetworkImage.
final categoryCoverImagesProvider = StateNotifierProvider<
    CategoryCoverImagesNotifier, AsyncValue<Map<String, String>>>((ref) {
  return CategoryCoverImagesNotifier(ref);
});
