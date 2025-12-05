// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'razorpay_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(razorpayService)
const razorpayServiceProvider = RazorpayServiceProvider._();

final class RazorpayServiceProvider extends $FunctionalProvider<RazorpayService,
    RazorpayService, RazorpayService> with $Provider<RazorpayService> {
  const RazorpayServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'razorpayServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$razorpayServiceHash();

  @$internal
  @override
  $ProviderElement<RazorpayService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RazorpayService create(Ref ref) {
    return razorpayService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RazorpayService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RazorpayService>(value),
    );
  }
}

String _$razorpayServiceHash() => r'1041667448907e9f8528acac00a7c59d1a2c311c';
