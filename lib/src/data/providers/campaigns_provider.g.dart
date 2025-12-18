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

@ProviderFor(MyCampaignsFilter)
const myCampaignsFilterProvider = MyCampaignsFilterProvider._();

final class MyCampaignsFilterProvider
    extends $NotifierProvider<MyCampaignsFilter, bool> {
  const MyCampaignsFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'myCampaignsFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$myCampaignsFilterHash();

  @$internal
  @override
  MyCampaignsFilter create() => MyCampaignsFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$myCampaignsFilterHash() => r'bcc66b6ea0a7a72babe71109723a1ee62d1d1279';

abstract class _$MyCampaignsFilter extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TransactionsFilter)
const transactionsFilterProvider = TransactionsFilterProvider._();

final class TransactionsFilterProvider
    extends $NotifierProvider<TransactionsFilter, bool> {
  const TransactionsFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionsFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionsFilterHash();

  @$internal
  @override
  TransactionsFilter create() => TransactionsFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$transactionsFilterHash() =>
    r'6b89aa34cdfc801b6022d82c327665fe2342554a';

abstract class _$TransactionsFilter extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TransactionSearch)
const transactionSearchProvider = TransactionSearchProvider._();

final class TransactionSearchProvider
    extends $NotifierProvider<TransactionSearch, String> {
  const TransactionSearchProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionSearchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionSearchHash();

  @$internal
  @override
  TransactionSearch create() => TransactionSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$transactionSearchHash() => r'20c10cff0360c265e1e2b155db76bb8b6f1adbaf';

abstract class _$TransactionSearch extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TransactionDateFilter)
const transactionDateFilterProvider = TransactionDateFilterProvider._();

final class TransactionDateFilterProvider
    extends $NotifierProvider<TransactionDateFilter, Map<String, String?>> {
  const TransactionDateFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionDateFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionDateFilterHash();

  @$internal
  @override
  TransactionDateFilter create() => TransactionDateFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String?>>(value),
    );
  }
}

String _$transactionDateFilterHash() =>
    r'1d956ba640694210e30c5e203947e4b701f666ba';

abstract class _$TransactionDateFilter extends $Notifier<Map<String, String?>> {
  Map<String, String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Map<String, String?>, Map<String, String?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, String?>, Map<String, String?>>,
        Map<String, String?>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CampaignCategoryFilter)
const campaignCategoryFilterProvider = CampaignCategoryFilterProvider._();

final class CampaignCategoryFilterProvider
    extends $NotifierProvider<CampaignCategoryFilter, String> {
  const CampaignCategoryFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'campaignCategoryFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$campaignCategoryFilterHash();

  @$internal
  @override
  CampaignCategoryFilter create() => CampaignCategoryFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$campaignCategoryFilterHash() =>
    r'a8d52e00799c9b7d2885ba03025a8b46ac4676b8';

abstract class _$CampaignCategoryFilter extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

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
    r'3205725d4ea3ff698dea960983347bbc20c514bf';

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

@ProviderFor(CreatedCampaignsNotifier)
const createdCampaignsProvider = CreatedCampaignsNotifierProvider._();

final class CreatedCampaignsNotifierProvider extends $AsyncNotifierProvider<
    CreatedCampaignsNotifier, CampaignPaginationState> {
  const CreatedCampaignsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createdCampaignsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createdCampaignsNotifierHash();

  @$internal
  @override
  CreatedCampaignsNotifier create() => CreatedCampaignsNotifier();
}

String _$createdCampaignsNotifierHash() =>
    r'7bab92204964078b757dc2f268bfe9f07ce43772';

abstract class _$CreatedCampaignsNotifier
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
    r'5ce33aeeac0c05a68a7ff1aaf56bf43717c52a90';

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

@ProviderFor(MemberDonationsNotifier)
const memberDonationsProvider = MemberDonationsNotifierProvider._();

final class MemberDonationsNotifierProvider extends $AsyncNotifierProvider<
    MemberDonationsNotifier, DonationPaginationState> {
  const MemberDonationsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memberDonationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberDonationsNotifierHash();

  @$internal
  @override
  MemberDonationsNotifier create() => MemberDonationsNotifier();
}

String _$memberDonationsNotifierHash() =>
    r'c0980657366b79a9bccf129363092d69b3cf81ba';

abstract class _$MemberDonationsNotifier
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

@ProviderFor(PendingApprovalCampaignsNotifier)
const pendingApprovalCampaignsProvider =
    PendingApprovalCampaignsNotifierProvider._();

final class PendingApprovalCampaignsNotifierProvider
    extends $AsyncNotifierProvider<PendingApprovalCampaignsNotifier,
        CampaignPaginationState> {
  const PendingApprovalCampaignsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingApprovalCampaignsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingApprovalCampaignsNotifierHash();

  @$internal
  @override
  PendingApprovalCampaignsNotifier create() =>
      PendingApprovalCampaignsNotifier();
}

String _$pendingApprovalCampaignsNotifierHash() =>
    r'6d4995507bbfe4775a84831287f5b06372ff2ec6';

abstract class _$PendingApprovalCampaignsNotifier
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
