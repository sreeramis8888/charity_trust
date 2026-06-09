// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subscriptionApi)
const subscriptionApiProvider = SubscriptionApiProvider._();

final class SubscriptionApiProvider extends $FunctionalProvider<SubscriptionApi,
    SubscriptionApi, SubscriptionApi> with $Provider<SubscriptionApi> {
  const SubscriptionApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'subscriptionApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$subscriptionApiHash();

  @$internal
  @override
  $ProviderElement<SubscriptionApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SubscriptionApi create(Ref ref) {
    return subscriptionApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionApi>(value),
    );
  }
}

String _$subscriptionApiHash() => r'a77018d43a739033aa1067da4a06fab2d5fb2dad';

@ProviderFor(subscriptionPlans)
const subscriptionPlansProvider = SubscriptionPlansProvider._();

final class SubscriptionPlansProvider extends $FunctionalProvider<
    List<SubscriptionPlan>,
    List<SubscriptionPlan>,
    List<SubscriptionPlan>> with $Provider<List<SubscriptionPlan>> {
  const SubscriptionPlansProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'subscriptionPlansProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$subscriptionPlansHash();

  @$internal
  @override
  $ProviderElement<List<SubscriptionPlan>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<SubscriptionPlan> create(Ref ref) {
    return subscriptionPlans(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SubscriptionPlan> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SubscriptionPlan>>(value),
    );
  }
}

String _$subscriptionPlansHash() => r'38b92d1d5e1f43c719378eb037f29d280f98a4b7';

@ProviderFor(staticCampaignsForSubscription)
const staticCampaignsForSubscriptionProvider =
    StaticCampaignsForSubscriptionProvider._();

final class StaticCampaignsForSubscriptionProvider extends $FunctionalProvider<
        AsyncValue<List<CampaignModel>>,
        List<CampaignModel>,
        FutureOr<List<CampaignModel>>>
    with
        $FutureModifier<List<CampaignModel>>,
        $FutureProvider<List<CampaignModel>> {
  const StaticCampaignsForSubscriptionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'staticCampaignsForSubscriptionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$staticCampaignsForSubscriptionHash();

  @$internal
  @override
  $FutureProviderElement<List<CampaignModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CampaignModel>> create(Ref ref) {
    return staticCampaignsForSubscription(ref);
  }
}

String _$staticCampaignsForSubscriptionHash() =>
    r'2b08498ab176a251f730db7eb7e2af6b4790f22c';
