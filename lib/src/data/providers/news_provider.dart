import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:charity_trust/src/data/providers/api_provider.dart';
import 'package:charity_trust/src/data/models/news_model.dart';

part 'news_provider.g.dart';

class NewsApi {
  static const String _endpoint = '/news';

  final ApiProvider _apiProvider;

  NewsApi({required ApiProvider apiProvider}) : _apiProvider = apiProvider;

  Future<ApiResponse<Map<String, dynamic>>> getNewsForUser({
    int pageNo = 1,
    int limit = 10,
    bool bookmarked = false,
  }) async {
    final queryParams = {
      'page_no': pageNo,
      'limit': limit,
      if (bookmarked) 'bookmarked': true,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return await _apiProvider.get(
      '$_endpoint/user?$queryString',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleBookmark(String newsId) async {
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

class PaginationState {
  final int currentPage;
  final int limit;
  final int totalCount;
  final List<NewsModel> news;
  final bool hasMore;

  PaginationState({
    required this.currentPage,
    required this.limit,
    required this.totalCount,
    required this.news,
  }) : hasMore = (currentPage * limit) < totalCount;

  PaginationState copyWith({
    int? currentPage,
    int? limit,
    int? totalCount,
    List<NewsModel>? news,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalCount: totalCount ?? this.totalCount,
      news: news ?? this.news,
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
    final newsList = (response.data!['data'] as List<dynamic>?)
            ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];
    final totalCount = response.data!['total_count'] as int? ?? 0;

    return PaginationState(
      currentPage: pageNo,
      limit: limit,
      totalCount: totalCount,
      news: newsList,
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
  final newsApi = ref.watch(newsApiProvider);
  final response = await newsApi.getBookmarkedNews(
    pageNo: pageNo,
    limit: limit,
  );

  if (response.success && response.data != null) {
    final newsList = (response.data!['data'] as List<dynamic>?)
            ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];
    final totalCount = response.data!['total_count'] as int? ?? 0;

    return PaginationState(
      currentPage: pageNo,
      limit: limit,
      totalCount: totalCount,
      news: newsList,
    );
  } else {
    throw Exception(response.message ?? 'Failed to fetch bookmarked news');
  }
}

@riverpod
class NewsListNotifier extends _$NewsListNotifier {
  @override
  Future<PaginationState> build() async {
    final newsApi = ref.watch(newsApiProvider);
    final response = await newsApi.getNewsForUser(
      pageNo: 1,
      limit: 10,
      bookmarked: false,
    );

    if (response.success && response.data != null) {
      final newsList = (response.data!['data'] as List<dynamic>?)
              ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final totalCount = response.data!['total_count'] as int? ?? 0;

      return PaginationState(
        currentPage: 1,
        limit: 10,
        totalCount: totalCount,
        news: newsList,
      );
    } else {
      throw Exception(response.message ?? 'Failed to fetch news');
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newsApi = ref.watch(newsApiProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await newsApi.getNewsForUser(
        pageNo: nextPage,
        limit: currentState.limit,
        bookmarked: false,
      );

      if (response.success && response.data != null) {
        final newsList = (response.data!['data'] as List<dynamic>?)
                ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        final totalCount = response.data!['total_count'] as int? ?? 0;

        return currentState.copyWith(
          currentPage: nextPage,
          totalCount: totalCount,
          news: [...currentState.news, ...newsList],
        );
      } else {
        throw Exception(response.message ?? 'Failed to load more news');
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> toggleBookmark(String newsId) async {
    if (!state.hasValue) return;

    try {
      final newsApi = ref.watch(newsApiProvider);
      final response = await newsApi.toggleBookmark(newsId);

      if (response.success) {
        final currentState = state.value!;
        final updatedNews = currentState.news.map((news) {
          if (news.id == newsId) {
            final isBookmarked = news.bookmarked?.contains(newsId) ?? false;
            final updatedBookmarked = isBookmarked
                ? (news.bookmarked ?? [])
                    .where((id) => id != newsId)
                    .toList() as List<String>
                : [...(news.bookmarked ?? []), newsId] as List<String>;

            return news.copyWith(bookmarked: updatedBookmarked);
          }
          return news;
        }).toList();

        state = AsyncValue.data(
          currentState.copyWith(news: updatedNews),
        );
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
    final newsApi = ref.watch(newsApiProvider);
    final response = await newsApi.getBookmarkedNews(
      pageNo: 1,
      limit: 10,
    );

    if (response.success && response.data != null) {
      final newsList = (response.data!['data'] as List<dynamic>?)
              ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final totalCount = response.data!['total_count'] as int? ?? 0;

      return PaginationState(
        currentPage: 1,
        limit: 10,
        totalCount: totalCount,
        news: newsList,
      );
    } else {
      throw Exception(response.message ?? 'Failed to fetch bookmarked news');
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newsApi = ref.watch(newsApiProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await newsApi.getBookmarkedNews(
        pageNo: nextPage,
        limit: currentState.limit,
      );

      if (response.success && response.data != null) {
        final newsList = (response.data!['data'] as List<dynamic>?)
                ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        final totalCount = response.data!['total_count'] as int? ?? 0;

        return currentState.copyWith(
          currentPage: nextPage,
          totalCount: totalCount,
          news: [...currentState.news, ...newsList],
        );
      } else {
        throw Exception(response.message ?? 'Failed to load more bookmarked news');
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> removeBookmark(String newsId) async {
    if (!state.hasValue) return;

    try {
      final newsApi = ref.watch(newsApiProvider);
      final response = await newsApi.toggleBookmark(newsId);

      if (response.success) {
        final currentState = state.value!;
        final updatedNews = currentState.news
            .where((news) => news.id != newsId)
            .toList();

        state = AsyncValue.data(
          currentState.copyWith(
            news: updatedNews,
            totalCount: currentState.totalCount - 1,
          ),
        );
      } else {
        throw Exception(response.message ?? 'Failed to remove bookmark');
      }
    } catch (e) {
      throw Exception('Error removing bookmark: $e');
    }
  }
}