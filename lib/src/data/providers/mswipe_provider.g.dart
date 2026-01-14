// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mswipe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mswipeService)
const mswipeServiceProvider = MswipeServiceProvider._();

final class MswipeServiceProvider
    extends $FunctionalProvider<MswipeService, MswipeService, MswipeService>
    with $Provider<MswipeService> {
  const MswipeServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mswipeServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mswipeServiceHash();

  @$internal
  @override
  $ProviderElement<MswipeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MswipeService create(Ref ref) {
    return mswipeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MswipeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MswipeService>(value),
    );
  }
}

String _$mswipeServiceHash() => r'2d3408c556de0b5b32bd35d74f7522c73c9d3022';
