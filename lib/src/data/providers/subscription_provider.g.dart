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

@ProviderFor(mySubscriptions)
const mySubscriptionsProvider = MySubscriptionsProvider._();

final class MySubscriptionsProvider extends $FunctionalProvider<
        AsyncValue<List<SubscriptionModel>>,
        List<SubscriptionModel>,
        FutureOr<List<SubscriptionModel>>>
    with
        $FutureModifier<List<SubscriptionModel>>,
        $FutureProvider<List<SubscriptionModel>> {
  const MySubscriptionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mySubscriptionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mySubscriptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<SubscriptionModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<SubscriptionModel>> create(Ref ref) {
    return mySubscriptions(ref);
  }
}

String _$mySubscriptionsHash() => r'942b160b0c4e8077729934760c46ecff01f9ec65';

@ProviderFor(subscriptionDetail)
const subscriptionDetailProvider = SubscriptionDetailFamily._();

final class SubscriptionDetailProvider extends $FunctionalProvider<
        AsyncValue<SubscriptionModel>,
        SubscriptionModel,
        FutureOr<SubscriptionModel>>
    with
        $FutureModifier<SubscriptionModel>,
        $FutureProvider<SubscriptionModel> {
  const SubscriptionDetailProvider._(
      {required SubscriptionDetailFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'subscriptionDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$subscriptionDetailHash();

  @override
  String toString() {
    return r'subscriptionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SubscriptionModel> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SubscriptionModel> create(Ref ref) {
    final argument = this.argument as String;
    return subscriptionDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SubscriptionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subscriptionDetailHash() =>
    r'b0dc3498d5880716469bc30c24de9e4e62d0b2f1';

final class SubscriptionDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SubscriptionModel>, String> {
  const SubscriptionDetailFamily._()
      : super(
          retry: null,
          name: r'subscriptionDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  SubscriptionDetailProvider call(
    String subscriptionId,
  ) =>
      SubscriptionDetailProvider._(argument: subscriptionId, from: this);

  @override
  String toString() => r'subscriptionDetailProvider';
}

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
