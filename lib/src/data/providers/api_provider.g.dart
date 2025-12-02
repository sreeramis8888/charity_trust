// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(apiProvider)
const apiProviderProvider = ApiProviderProvider._();

final class ApiProviderProvider
    extends $FunctionalProvider<ApiProvider, ApiProvider, ApiProvider>
    with $Provider<ApiProvider> {
  const ApiProviderProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'apiProviderProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$apiProviderHash();

  @$internal
  @override
  $ProviderElement<ApiProvider> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiProvider create(Ref ref) {
    return apiProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiProvider>(value),
    );
  }
}

String _$apiProviderHash() => r'96d16ab5ea1a3d192c11d0b29bf1f753bbea8866';
