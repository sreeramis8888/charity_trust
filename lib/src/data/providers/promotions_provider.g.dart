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

@ProviderFor(promotions)
const promotionsProvider = PromotionsFamily._();

final class PromotionsProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  const PromotionsProvider._(
      {required PromotionsFamily super.from, required String? super.argument})
      : super(
          retry: null,
          name: r'promotionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$promotionsHash();

  @override
  String toString() {
    return r'promotionsProvider'
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
    final argument = this.argument as String?;
    return promotions(
      ref,
      type: argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PromotionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$promotionsHash() => r'8701b84b0d17bd0405de4ed5400a26281962190c';

final class PromotionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String?> {
  const PromotionsFamily._()
      : super(
          retry: null,
          name: r'promotionsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PromotionsProvider call({
    String? type,
  }) =>
      PromotionsProvider._(argument: type, from: this);

  @override
  String toString() => r'promotionsProvider';
}

@ProviderFor(promotionById)
const promotionByIdProvider = PromotionByIdFamily._();

final class PromotionByIdProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
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

  PromotionByIdProvider call(
    String id,
  ) =>
      PromotionByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'promotionByIdProvider';
}

@ProviderFor(PromotionsListNotifier)
const promotionsListProvider = PromotionsListNotifierFamily._();

final class PromotionsListNotifierProvider extends $AsyncNotifierProvider<
    PromotionsListNotifier, Map<String, dynamic>> {
  const PromotionsListNotifierProvider._(
      {required PromotionsListNotifierFamily super.from,
      required String? super.argument})
      : super(
          retry: null,
          name: r'promotionsListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$promotionsListNotifierHash();

  @override
  String toString() {
    return r'promotionsListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PromotionsListNotifier create() => PromotionsListNotifier();

  @override
  bool operator ==(Object other) {
    return other is PromotionsListNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$promotionsListNotifierHash() =>
    r'15497bce3e2d7549500d5d841a715dc53071b8c2';

final class PromotionsListNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            PromotionsListNotifier,
            AsyncValue<Map<String, dynamic>>,
            Map<String, dynamic>,
            FutureOr<Map<String, dynamic>>,
            String?> {
  const PromotionsListNotifierFamily._()
      : super(
          retry: null,
          name: r'promotionsListProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PromotionsListNotifierProvider call({
    String? type,
  }) =>
      PromotionsListNotifierProvider._(argument: type, from: this);

  @override
  String toString() => r'promotionsListProvider';
}

abstract class _$PromotionsListNotifier
    extends $AsyncNotifier<Map<String, dynamic>> {
  late final _$args = ref.$arg as String?;
  String? get type => _$args;

  FutureOr<Map<String, dynamic>> build({
    String? type,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      type: _$args,
    );
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
