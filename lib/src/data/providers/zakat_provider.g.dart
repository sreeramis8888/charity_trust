// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zakat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(zakatApi)
const zakatApiProvider = ZakatApiProvider._();

final class ZakatApiProvider
    extends $FunctionalProvider<ZakatApi, ZakatApi, ZakatApi>
    with $Provider<ZakatApi> {
  const ZakatApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'zakatApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$zakatApiHash();

  @$internal
  @override
  $ProviderElement<ZakatApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ZakatApi create(Ref ref) {
    return zakatApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ZakatApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ZakatApi>(value),
    );
  }
}

String _$zakatApiHash() => r'b802804f102d21396c462436d2295f688a8e74bd';

@ProviderFor(ZakatCalculatorNotifier)
const zakatCalculatorProvider = ZakatCalculatorNotifierProvider._();

final class ZakatCalculatorNotifierProvider extends $AsyncNotifierProvider<
    ZakatCalculatorNotifier, ZakatCalculatorResponse?> {
  const ZakatCalculatorNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'zakatCalculatorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$zakatCalculatorNotifierHash();

  @$internal
  @override
  ZakatCalculatorNotifier create() => ZakatCalculatorNotifier();
}

String _$zakatCalculatorNotifierHash() =>
    r'b3c0a49f752ca0d89653c680025f8802d09a0678';

abstract class _$ZakatCalculatorNotifier
    extends $AsyncNotifier<ZakatCalculatorResponse?> {
  FutureOr<ZakatCalculatorResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<ZakatCalculatorResponse?>, ZakatCalculatorResponse?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ZakatCalculatorResponse?>,
            ZakatCalculatorResponse?>,
        AsyncValue<ZakatCalculatorResponse?>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
