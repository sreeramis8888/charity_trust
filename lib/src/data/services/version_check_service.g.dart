// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_check_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(versionCheckService)
const versionCheckServiceProvider = VersionCheckServiceProvider._();

final class VersionCheckServiceProvider extends $FunctionalProvider<
    VersionCheckService,
    VersionCheckService,
    VersionCheckService> with $Provider<VersionCheckService> {
  const VersionCheckServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'versionCheckServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$versionCheckServiceHash();

  @$internal
  @override
  $ProviderElement<VersionCheckService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VersionCheckService create(Ref ref) {
    return versionCheckService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VersionCheckService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VersionCheckService>(value),
    );
  }
}

String _$versionCheckServiceHash() =>
    r'0613fa66fc94bc90d826f6e9b539e0a211e98fa1';

@ProviderFor(checkAppVersion)
const checkAppVersionProvider = CheckAppVersionProvider._();

final class CheckAppVersionProvider extends $FunctionalProvider<
        AsyncValue<AppVersionResponse?>,
        AppVersionResponse?,
        FutureOr<AppVersionResponse?>>
    with
        $FutureModifier<AppVersionResponse?>,
        $FutureProvider<AppVersionResponse?> {
  const CheckAppVersionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'checkAppVersionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$checkAppVersionHash();

  @$internal
  @override
  $FutureProviderElement<AppVersionResponse?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppVersionResponse?> create(Ref ref) {
    return checkAppVersion(ref);
  }
}

String _$checkAppVersionHash() => r'd12f327567efa3c141479892083d49297766adeb';
