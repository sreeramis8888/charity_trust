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
    r'db9ddb7d506952a5ffbf0d02dfdccd40142b4baa';

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

@ProviderFor(ParticipatedCampaignsNotifier)
const participatedCampaignsProvider = ParticipatedCampaignsNotifierProvider._();

final class ParticipatedCampaignsNotifierProvider
    extends $AsyncNotifierProvider<ParticipatedCampaignsNotifier,
        DonationPaginationState> {
  const ParticipatedCampaignsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'participatedCampaignsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$participatedCampaignsNotifierHash();

  @$internal
  @override
  ParticipatedCampaignsNotifier create() => ParticipatedCampaignsNotifier();
}

String _$participatedCampaignsNotifierHash() =>
    r'b1590637a6a4770da72d77556a8026ab5482eca4';

abstract class _$ParticipatedCampaignsNotifier
    extends $AsyncNotifier<DonationPaginationState> {
  FutureOr<DonationPaginationState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<DonationPaginationState>, DonationPaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<DonationPaginationState>,
            DonationPaginationState>,
        AsyncValue<DonationPaginationState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(createNewCampaign)
const createNewCampaignProvider = CreateNewCampaignFamily._();

final class CreateNewCampaignProvider extends $FunctionalProvider<
        AsyncValue<CampaignModel?>, CampaignModel?, FutureOr<CampaignModel?>>
    with $FutureModifier<CampaignModel?>, $FutureProvider<CampaignModel?> {
  const CreateNewCampaignProvider._(
      {required CreateNewCampaignFamily super.from,
      required Map<String, dynamic> super.argument})
      : super(
          retry: null,
          name: r'createNewCampaignProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createNewCampaignHash();

  @override
  String toString() {
    return r'createNewCampaignProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CampaignModel?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CampaignModel?> create(Ref ref) {
    final argument = this.argument as Map<String, dynamic>;
    return createNewCampaign(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CreateNewCampaignProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createNewCampaignHash() => r'466df620eddedc8835ffbe0d2b64baf6e3ab7043';

final class CreateNewCampaignFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<CampaignModel?>,
            Map<String, dynamic>> {
  const CreateNewCampaignFamily._()
      : super(
          retry: null,
          name: r'createNewCampaignProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CreateNewCampaignProvider call(
    Map<String, dynamic> campaignData,
  ) =>
      CreateNewCampaignProvider._(argument: campaignData, from: this);

  @override
  String toString() => r'createNewCampaignProvider';
}

@ProviderFor(categoryCampaigns)
const categoryCampaignsProvider = CategoryCampaignsFamily._();

final class CategoryCampaignsProvider extends $FunctionalProvider<
        AsyncValue<CampaignPaginationState>,
        CampaignPaginationState,
        FutureOr<CampaignPaginationState>>
    with
        $FutureModifier<CampaignPaginationState>,
        $FutureProvider<CampaignPaginationState> {
  const CategoryCampaignsProvider._(
      {required CategoryCampaignsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'categoryCampaignsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryCampaignsHash();

  @override
  String toString() {
    return r'categoryCampaignsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CampaignPaginationState> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CampaignPaginationState> create(Ref ref) {
    final argument = this.argument as String;
    return categoryCampaigns(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryCampaignsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryCampaignsHash() => r'6b510b04356b813eb548e174ba2d09f32902e887';

final class CategoryCampaignsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CampaignPaginationState>, String> {
  const CategoryCampaignsFamily._()
      : super(
          retry: null,
          name: r'categoryCampaignsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CategoryCampaignsProvider call(
    String category,
  ) =>
      CategoryCampaignsProvider._(argument: category, from: this);

  @override
  String toString() => r'categoryCampaignsProvider';
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
    r'24e41d04479e8fb4b83b6afa3a02cbeab1f0c9b8';

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
