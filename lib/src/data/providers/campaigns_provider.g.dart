// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaigns_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(campaignsApi)
const campaignsApiProvider = CampaignsApiProvider._();

final class CampaignsApiProvider
    extends $FunctionalProvider<CampaignsApi, CampaignsApi, CampaignsApi>
    with $Provider<CampaignsApi> {
  const CampaignsApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'campaignsApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$campaignsApiHash();

  @$internal
  @override
  $ProviderElement<CampaignsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CampaignsApi create(Ref ref) {
    return campaignsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CampaignsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CampaignsApi>(value),
    );
  }
}

String _$campaignsApiHash() => r'620d3b70287337180fc2b9f792fd5b70be173dde';

@ProviderFor(GeneralCampaignsNotifier)
const generalCampaignsProvider = GeneralCampaignsNotifierProvider._();

final class GeneralCampaignsNotifierProvider extends $AsyncNotifierProvider<
    GeneralCampaignsNotifier, CampaignPaginationState> {
  const GeneralCampaignsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'generalCampaignsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$generalCampaignsNotifierHash();

  @$internal
  @override
  GeneralCampaignsNotifier create() => GeneralCampaignsNotifier();
}

String _$generalCampaignsNotifierHash() =>
    r'b2a68c6eae04bc7357542f5bb8e9ba7cf6f470e2';

abstract class _$GeneralCampaignsNotifier
    extends $AsyncNotifier<CampaignPaginationState> {
  FutureOr<CampaignPaginationState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<CampaignPaginationState>, CampaignPaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CampaignPaginationState>,
            CampaignPaginationState>,
        AsyncValue<CampaignPaginationState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MyCampaignsNotifier)
const myCampaignsProvider = MyCampaignsNotifierProvider._();

final class MyCampaignsNotifierProvider extends $AsyncNotifierProvider<
    MyCampaignsNotifier, CampaignPaginationState> {
  const MyCampaignsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'myCampaignsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$myCampaignsNotifierHash();

  @$internal
  @override
  MyCampaignsNotifier create() => MyCampaignsNotifier();
}

String _$myCampaignsNotifierHash() =>
    r'b988a779a86332da7eec3fa63592def93b806a41';

abstract class _$MyCampaignsNotifier
    extends $AsyncNotifier<CampaignPaginationState> {
  FutureOr<CampaignPaginationState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<CampaignPaginationState>, CampaignPaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CampaignPaginationState>,
            CampaignPaginationState>,
        AsyncValue<CampaignPaginationState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
