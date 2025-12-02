// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authProvider)
const authProviderProvider = AuthProviderProvider._();

final class AuthProviderProvider
    extends $FunctionalProvider<AuthProvider, AuthProvider, AuthProvider>
    with $Provider<AuthProvider> {
  const AuthProviderProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authProviderProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authProviderHash();

  @$internal
  @override
  $ProviderElement<AuthProvider> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthProvider create(Ref ref) {
    return authProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthProvider>(value),
    );
  }
}

String _$authProviderHash() => r'a4502b1140c660481ae30c43f258bbcb15bd86d6';

@ProviderFor(isAuthenticated)
const isAuthenticatedProvider = IsAuthenticatedProvider._();

final class IsAuthenticatedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsAuthenticatedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isAuthenticatedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isAuthenticated(ref);
  }
}

String _$isAuthenticatedHash() => r'322b5da50fdc89eefe07ba9e2e0bdf0b8fdd50df';

@ProviderFor(bearerToken)
const bearerTokenProvider = BearerTokenProvider._();

final class BearerTokenProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const BearerTokenProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bearerTokenProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bearerTokenHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return bearerToken(ref);
  }
}

String _$bearerTokenHash() => r'075a176a35bbe1cf7601a25d7140c9b84227df8a';
