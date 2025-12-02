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

String _$newsHash() => r'1a5264b287d7335a40681a1f55f3afec201e9b96';

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

String _$bookmarkedNewsHash() => r'0f4f3c037acaff69308bba276ef807ea77d81a5a';

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

String _$newsListNotifierHash() => r'eeedbbccd0e7c307eb808948c64c86c95cdb0bce';

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
    r'290e88d6a77319e2004236f96027366ac182dc22';

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
