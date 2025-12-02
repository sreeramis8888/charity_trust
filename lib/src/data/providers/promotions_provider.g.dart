// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(promotionsApi)
const promotionsApiProvider = PromotionsApiProvider._();

final class PromotionsApiProvider
    extends $FunctionalProvider<PromotionsApi, PromotionsApi, PromotionsApi>
    with $Provider<PromotionsApi> {
  const PromotionsApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'promotionsApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$promotionsApiHash();

  @$internal
  @override
  $ProviderElement<PromotionsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PromotionsApi create(Ref ref) {
    return promotionsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PromotionsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PromotionsApi>(value),
    );
  }
}

String _$promotionsApiHash() => r'09125daafced658dde894ae60b66212e13ab74af';

/// Provider to fetch all promotions
/// Usage: ref.watch(promotionsProvider)

@ProviderFor(promotions)
const promotionsProvider = PromotionsProvider._();

/// Provider to fetch all promotions
/// Usage: ref.watch(promotionsProvider)

final class PromotionsProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Provider to fetch all promotions
  /// Usage: ref.watch(promotionsProvider)
  const PromotionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'promotionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$promotionsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return promotions(ref);
  }
}

String _$promotionsHash() => r'ace793d34a6dd269e2318b4f5c11007e8689196e';

/// Provider to fetch a specific promotion by ID
/// Usage: ref.watch(promotionByIdProvider('promotion-id'))

@ProviderFor(promotionById)
const promotionByIdProvider = PromotionByIdFamily._();

/// Provider to fetch a specific promotion by ID
/// Usage: ref.watch(promotionByIdProvider('promotion-id'))

final class PromotionByIdProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Provider to fetch a specific promotion by ID
  /// Usage: ref.watch(promotionByIdProvider('promotion-id'))
  const PromotionByIdProvider._(
      {required PromotionByIdFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'promotionByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$promotionByIdHash();

  @override
  String toString() {
    return r'promotionByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return promotionById(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PromotionByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$promotionByIdHash() => r'a66c34584095dedddefc41f3ed9d8fb011f35e1c';

/// Provider to fetch a specific promotion by ID
/// Usage: ref.watch(promotionByIdProvider('promotion-id'))

final class PromotionByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String> {
  const PromotionByIdFamily._()
      : super(
          retry: null,
          name: r'promotionByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to fetch a specific promotion by ID
  /// Usage: ref.watch(promotionByIdProvider('promotion-id'))

  PromotionByIdProvider call(
    String id,
  ) =>
      PromotionByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'promotionByIdProvider';
}

/// Notifier for managing promotions list state
/// Allows for manual refresh and state management

@ProviderFor(PromotionsListNotifier)
const promotionsListProvider = PromotionsListNotifierProvider._();

/// Notifier for managing promotions list state
/// Allows for manual refresh and state management
final class PromotionsListNotifierProvider extends $AsyncNotifierProvider<
    PromotionsListNotifier, Map<String, dynamic>> {
  /// Notifier for managing promotions list state
  /// Allows for manual refresh and state management
  const PromotionsListNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'promotionsListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$promotionsListNotifierHash();

  @$internal
  @override
  PromotionsListNotifier create() => PromotionsListNotifier();
}

String _$promotionsListNotifierHash() =>
    r'63ffde1468a9d447fd39c9424ad4ff4eee80e039';

/// Notifier for managing promotions list state
/// Allows for manual refresh and state management

abstract class _$PromotionsListNotifier
    extends $AsyncNotifier<Map<String, dynamic>> {
  FutureOr<Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<Map<String, dynamic>>, Map<String, dynamic>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Map<String, dynamic>>, Map<String, dynamic>>,
        AsyncValue<Map<String, dynamic>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
