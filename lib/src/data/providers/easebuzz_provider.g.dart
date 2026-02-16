// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'easebuzz_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(easebuzzService)
const easebuzzServiceProvider = EasebuzzServiceProvider._();

final class EasebuzzServiceProvider extends $FunctionalProvider<EasebuzzService,
    EasebuzzService, EasebuzzService> with $Provider<EasebuzzService> {
  const EasebuzzServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'easebuzzServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$easebuzzServiceHash();

  @$internal
  @override
  $ProviderElement<EasebuzzService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EasebuzzService create(Ref ref) {
    return easebuzzService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EasebuzzService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EasebuzzService>(value),
    );
  }
}

String _$easebuzzServiceHash() => r'9b3f7f4b5329c7d48e8668f5e3ec207083d6a168';
