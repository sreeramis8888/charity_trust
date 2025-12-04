// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(newsApi)
const newsApiProvider = NewsApiProvider._();

final class NewsApiProvider
    extends $FunctionalProvider<NewsApi, NewsApi, NewsApi>
    with $Provider<NewsApi> {
  const NewsApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'newsApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$newsApiHash();

  @$internal
  @override
  $ProviderElement<NewsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NewsApi create(Ref ref) {
    return newsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NewsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NewsApi>(value),
    );
  }
}

String _$newsApiHash() => r'f07272c2d7c6811c10fdd6dd15d1757adc6359df';

@ProviderFor(news)
const newsProvider = NewsFamily._();

final class NewsProvider extends $FunctionalProvider<
        AsyncValue<PaginationState>, PaginationState, FutureOr<PaginationState>>
    with $FutureModifier<PaginationState>, $FutureProvider<PaginationState> {
  const NewsProvider._(
      {required NewsFamily super.from,
      required ({
        int pageNo,
        int limit,
      })
          super.argument})
      : super(
          retry: null,
          name: r'newsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$newsHash();

  @override
  String toString() {
    return r'newsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaginationState> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PaginationState> create(Ref ref) {
    final argument = this.argument as ({
      int pageNo,
      int limit,
    });
    return news(
      ref,
      pageNo: argument.pageNo,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$newsHash() => r'c536197adfd931ae31788c4d7eaf31785c49b0fb';

final class NewsFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<PaginationState>,
            ({
              int pageNo,
              int limit,
            })> {
  const NewsFamily._()
      : super(
          retry: null,
          name: r'newsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  NewsProvider call({
    int pageNo = 1,
    int limit = 10,
  }) =>
      NewsProvider._(argument: (
        pageNo: pageNo,
        limit: limit,
      ), from: this);

  @override
  String toString() => r'newsProvider';
}

@ProviderFor(bookmarkedNews)
const bookmarkedNewsProvider = BookmarkedNewsFamily._();

final class BookmarkedNewsProvider extends $FunctionalProvider<
        AsyncValue<PaginationState>, PaginationState, FutureOr<PaginationState>>
    with $FutureModifier<PaginationState>, $FutureProvider<PaginationState> {
  const BookmarkedNewsProvider._(
      {required BookmarkedNewsFamily super.from,
      required ({
        int pageNo,
        int limit,
      })
          super.argument})
      : super(
          retry: null,
          name: r'bookmarkedNewsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bookmarkedNewsHash();

  @override
  String toString() {
    return r'bookmarkedNewsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaginationState> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PaginationState> create(Ref ref) {
    final argument = this.argument as ({
      int pageNo,
      int limit,
    });
    return bookmarkedNews(
      ref,
      pageNo: argument.pageNo,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarkedNewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkedNewsHash() => r'ce472156803fe674edeaf8468db8e9c4957b968a';

final class BookmarkedNewsFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<PaginationState>,
            ({
              int pageNo,
              int limit,
            })> {
  const BookmarkedNewsFamily._()
      : super(
          retry: null,
          name: r'bookmarkedNewsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  BookmarkedNewsProvider call({
    int pageNo = 1,
    int limit = 10,
  }) =>
      BookmarkedNewsProvider._(argument: (
        pageNo: pageNo,
        limit: limit,
      ), from: this);

  @override
  String toString() => r'bookmarkedNewsProvider';
}

@ProviderFor(NewsListNotifier)
const newsListProvider = NewsListNotifierProvider._();

final class NewsListNotifierProvider
    extends $AsyncNotifierProvider<NewsListNotifier, PaginationState> {
  const NewsListNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'newsListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$newsListNotifierHash();

  @$internal
  @override
  NewsListNotifier create() => NewsListNotifier();
}

String _$newsListNotifierHash() => r'c1a75afb0795d867bc7f2aa8eced341aa921aba4';

abstract class _$NewsListNotifier extends $AsyncNotifier<PaginationState> {
  FutureOr<PaginationState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<PaginationState>, PaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<PaginationState>, PaginationState>,
        AsyncValue<PaginationState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(BookmarkedNewsListNotifier)
const bookmarkedNewsListProvider = BookmarkedNewsListNotifierProvider._();

final class BookmarkedNewsListNotifierProvider extends $AsyncNotifierProvider<
    BookmarkedNewsListNotifier, PaginationState> {
  const BookmarkedNewsListNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bookmarkedNewsListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bookmarkedNewsListNotifierHash();

  @$internal
  @override
  BookmarkedNewsListNotifier create() => BookmarkedNewsListNotifier();
}

String _$bookmarkedNewsListNotifierHash() =>
    r'ca0102bf1e6ff24efa7954e75f03a8a9d61c61cf';

abstract class _$BookmarkedNewsListNotifier
    extends $AsyncNotifier<PaginationState> {
  FutureOr<PaginationState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<PaginationState>, PaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<PaginationState>, PaginationState>,
        AsyncValue<PaginationState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
