import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';
import 'package:Annujoom/src/data/models/news_model.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';

part 'news_provider.g.dart';

class NewsApi {
  static const String _endpoint = '/news';

  final ApiProvider _apiProvider;

  NewsApi({required ApiProvider apiProvider}) : _apiProvider = apiProvider;

  Future<ApiResponse<Map<String, dynamic>>> getNewsForUser({
    int pageNo = 1,
    int limit = 10,
    bool bookmarked = false,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = {
      'page_no': pageNo,
      'limit': limit,
      if (bookmarked) 'bookmarked': true,
      if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
    };

    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await _apiProvider.get(
      '$_endpoint/user?$queryString',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleBookmark(
      String newsId) async {
    return await _apiProvider.patch(
      '$_endpoint/add-to-bookmark/$newsId',
      null,
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getBookmarkedNews({
    int pageNo = 1,
    int limit = 10,
  }) async {
    return getNewsForUser(
      pageNo: pageNo,
      limit: limit,
      bookmarked: true,
    );
  }
}

@riverpod
NewsApi newsApi(Ref ref) {
  final apiProvider = ref.watch(apiProviderProvider);
  return NewsApi(apiProvider: apiProvider);
}

/// Date filter for the news list (`yyyy-MM-dd` values for the API).
final newsDateFilterProvider =
    StateProvider<Map<String, String?>>((ref) => {
          'start_date': null,
          'end_date': null,
        });

class PaginationState {
  final int currentPage;
  final int limit;
  final int totalCount;
  final List<NewsModel> news;
  final List<dynamic> statistics;
  final bool hasMore;

  PaginationState({
    required this.currentPage,
    required this.limit,
    required this.totalCount,
    required this.news,
    this.statistics = const [],
  }) : hasMore = (currentPage * limit) < totalCount;

  PaginationState copyWith({
    int? currentPage,
    int? limit,
    int? totalCount,
    List<NewsModel>? news,
    List<dynamic>? statistics,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalCount: totalCount ?? this.totalCount,
      news: news ?? this.news,
      statistics: statistics ?? this.statistics,
    );
  }
}

@riverpod
Future<PaginationState> news(
  Ref ref, {
  int pageNo = 1,
  int limit = 10,
}) async {
  final newsApi = ref.watch(newsApiProvider);
  final response = await newsApi.getNewsForUser(
    pageNo: pageNo,
    limit: limit,
    bookmarked: false,
  );

  if (response.success && response.data != null) {
    final newsList = (response.data!['data']?['news'] as List<dynamic>?)
            ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];
    final statistics =
        (response.data!['data']?['statistics'] as List<dynamic>?) ?? [];
    final totalCount = response.data!['total_count'] as int? ?? 0;

    return PaginationState(
      currentPage: pageNo,
      limit: limit,
      totalCount: totalCount,
      news: newsList,
      statistics: statistics,
    );
  } else {
    throw Exception(response.message ?? 'Failed to fetch news');
  }
}

@riverpod
Future<PaginationState> bookmarkedNews(
  Ref ref, {
  int pageNo = 1,
  int limit = 10,
}) async {
  final allNewsState = ref.watch(newsListProvider);

  return allNewsState.when(
    data: (paginationState) {
      final bookmarkedNewsList = paginationState.news
          .where((news) => news.bookmarked?.isNotEmpty ?? false)
          .toList();

      final startIndex = (pageNo - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedNews = bookmarkedNewsList.sublist(
        startIndex,
        endIndex > bookmarkedNewsList.length
            ? bookmarkedNewsList.length
            : endIndex,
      );

      return PaginationState(
        currentPage: pageNo,
        limit: limit,
        totalCount: bookmarkedNewsList.length,
        news: paginatedNews,
        statistics: paginationState.statistics,
      );
    },
    loading: () => throw Exception('Loading news...'),
    error: (error, stackTrace) =>
        throw Exception('Failed to fetch bookmarked news'),
  );
}

@riverpod
class NewsListNotifier extends _$NewsListNotifier {
  @override
  Future<PaginationState> build() async {
    final newsApi = ref.watch(newsApiProvider);
    final dates = ref.watch(newsDateFilterProvider);
    final response = await newsApi.getNewsForUser(
      pageNo: 1,
      limit: 10,
      bookmarked: false,
      startDate: dates['start_date'],
      endDate: dates['end_date'],
    );

    if (response.success && response.data != null) {
      final newsList = (response.data!['data']?['news'] as List<dynamic>?)
              ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final statistics =
          (response.data!['data']?['statistics'] as List<dynamic>?) ?? [];
      final totalCount = response.data!['total_count'] as int? ?? 0;

      return PaginationState(
        currentPage: 1,
        limit: 10,
        totalCount: totalCount,
        news: newsList,
        statistics: statistics,
      );
    } else {
      throw Exception(response.message ?? 'Failed to fetch news');
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;

    // Keep current list visible while fetching the next page.
    try {
      final newsApi = ref.read(newsApiProvider);
      final dates = ref.read(newsDateFilterProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await newsApi.getNewsForUser(
        pageNo: nextPage,
        limit: currentState.limit,
        bookmarked: false,
        startDate: dates['start_date'],
        endDate: dates['end_date'],
      );

      if (response.success && response.data != null) {
        final newsList = (response.data!['data']?['news'] as List<dynamic>?)
                ?.map(
                    (item) => NewsModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        final statistics =
            (response.data!['data']?['statistics'] as List<dynamic>?) ?? [];
        final totalCount = response.data!['total_count'] as int? ?? 0;

        state = AsyncValue.data(
          currentState.copyWith(
            currentPage: nextPage,
            totalCount: totalCount,
            news: [...currentState.news, ...newsList],
            statistics: statistics,
          ),
        );
      }
    } catch (_) {
      // Keep existing page data on pagination failure.
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> toggleBookmark(String newsId) async {
    if (!state.hasValue) return;

    try {
      final newsApi = ref.watch(newsApiProvider);
      final secureStorageService = ref.watch(secureStorageServiceProvider);
      final userId = await secureStorageService.getUserId();

      final response = await newsApi.toggleBookmark(newsId);

      if (response.success) {
        final currentState = state.value!;
        final updatedNews = currentState.news.map((news) {
          if (news.id == newsId && userId != null) {
            final bookmarkedList = List<String>.from(news.bookmarked ?? []);
            if (bookmarkedList.contains(userId)) {
              bookmarkedList.remove(userId);
            } else {
              bookmarkedList.add(userId);
            }
            return news.copyWith(bookmarked: bookmarkedList);
          }
          return news;
        }).toList();

        state = AsyncValue.data(
          currentState.copyWith(news: updatedNews),
        );
        ref.invalidate(bookmarkedNewsListProvider);
      } else {
        throw Exception(response.message ?? 'Failed to toggle bookmark');
      }
    } catch (e) {
      throw Exception('Error toggling bookmark: $e');
    }
  }
}

@riverpod
class BookmarkedNewsListNotifier extends _$BookmarkedNewsListNotifier {
  @override
  Future<PaginationState> build() async {
    // Fetch bookmarks independently so an active news date filter does not
    // hide bookmarked items outside that range.
    final newsApi = ref.watch(newsApiProvider);
    final response = await newsApi.getBookmarkedNews(pageNo: 1, limit: 10);

    if (response.success && response.data != null) {
      final newsList = (response.data!['data']?['news'] as List<dynamic>?)
              ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final statistics =
          (response.data!['data']?['statistics'] as List<dynamic>?) ?? [];
      final totalCount = response.data!['total_count'] as int? ?? 0;

      return PaginationState(
        currentPage: 1,
        limit: 10,
        totalCount: totalCount,
        news: newsList,
        statistics: statistics,
      );
    } else {
      throw Exception(response.message ?? 'Failed to fetch bookmarked news');
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;

    try {
      final newsApi = ref.read(newsApiProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await newsApi.getBookmarkedNews(
        pageNo: nextPage,
        limit: currentState.limit,
      );

      if (response.success && response.data != null) {
        final newsList = (response.data!['data']?['news'] as List<dynamic>?)
                ?.map(
                    (item) => NewsModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        final statistics =
            (response.data!['data']?['statistics'] as List<dynamic>?) ?? [];
        final totalCount = response.data!['total_count'] as int? ?? 0;

        state = AsyncValue.data(
          currentState.copyWith(
            currentPage: nextPage,
            totalCount: totalCount,
            news: [...currentState.news, ...newsList],
            statistics: statistics,
          ),
        );
      }
    } catch (_) {
      // Keep existing page data on pagination failure.
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> removeBookmark(String newsId) async {
    if (!state.hasValue) return;

    try {
      final newsApi = ref.read(newsApiProvider);
      final response = await newsApi.toggleBookmark(newsId);

      if (response.success) {
        final currentState = state.value!;
        final updatedNews =
            currentState.news.where((news) => news.id != newsId).toList();

        state = AsyncValue.data(
          currentState.copyWith(
            news: updatedNews,
            totalCount: currentState.totalCount - 1,
          ),
        );
        ref.invalidate(newsListProvider);
      } else {
        throw Exception(response.message ?? 'Failed to remove bookmark');
      }
    } catch (e) {
      throw Exception('Error removing bookmark: $e');
    }
  }
}
