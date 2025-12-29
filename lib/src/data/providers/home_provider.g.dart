// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeApi)
const homeApiProvider = HomeApiProvider._();

final class HomeApiProvider
    extends $FunctionalProvider<HomeApi, HomeApi, HomeApi>
    with $Provider<HomeApi> {
  const HomeApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homeApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homeApiHash();

  @$internal
  @override
  $ProviderElement<HomeApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeApi create(Ref ref) {
    return homeApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeApi>(value),
    );
  }
}

String _$homeApiHash() => r'13fff75fbf89cc55de06028fa6ff0e83043e1c1e';

@ProviderFor(homePageData)
const homePageDataProvider = HomePageDataProvider._();

final class HomePageDataProvider extends $FunctionalProvider<
        AsyncValue<HomePageData>, HomePageData, FutureOr<HomePageData>>
    with $FutureModifier<HomePageData>, $FutureProvider<HomePageData> {
  const HomePageDataProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homePageDataProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homePageDataHash();

  @$internal
  @override
  $FutureProviderElement<HomePageData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HomePageData> create(Ref ref) {
    return homePageData(ref);
  }
}

String _$homePageDataHash() => r'95e2bc59fa292de82377061780e7bbc2a34f436f';

@ProviderFor(HomePageNotifier)
const homePageProvider = HomePageNotifierProvider._();

final class HomePageNotifierProvider
    extends $AsyncNotifierProvider<HomePageNotifier, HomePageData> {
  const HomePageNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homePageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homePageNotifierHash();

  @$internal
  @override
  HomePageNotifier create() => HomePageNotifier();
}

String _$homePageNotifierHash() => r'f39b81d1f86b9b259bd9ac07e71238c621f94873';

abstract class _$HomePageNotifier extends $AsyncNotifier<HomePageData> {
  FutureOr<HomePageData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<HomePageData>, HomePageData>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<HomePageData>, HomePageData>,
        AsyncValue<HomePageData>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
