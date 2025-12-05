// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(donationApi)
const donationApiProvider = DonationApiProvider._();

final class DonationApiProvider
    extends $FunctionalProvider<DonationApi, DonationApi, DonationApi>
    with $Provider<DonationApi> {
  const DonationApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'donationApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$donationApiHash();

  @$internal
  @override
  $ProviderElement<DonationApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DonationApi create(Ref ref) {
    return donationApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DonationApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DonationApi>(value),
    );
  }
}

String _$donationApiHash() => r'ce081612825dc35365aac4a374854e764d39397b';

@ProviderFor(DonationNotifier)
const donationProvider = DonationNotifierProvider._();

final class DonationNotifierProvider
    extends $AsyncNotifierProvider<DonationNotifier, Map<String, dynamic>> {
  const DonationNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'donationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$donationNotifierHash();

  @$internal
  @override
  DonationNotifier create() => DonationNotifier();
}

String _$donationNotifierHash() => r'0806a6189ee29b399594db5a933369988a53e384';

abstract class _$DonationNotifier extends $AsyncNotifier<Map<String, dynamic>> {
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
