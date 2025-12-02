// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authLoginApi)
const authLoginApiProvider = AuthLoginApiProvider._();

final class AuthLoginApiProvider
    extends $FunctionalProvider<AuthLoginApi, AuthLoginApi, AuthLoginApi>
    with $Provider<AuthLoginApi> {
  const AuthLoginApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authLoginApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authLoginApiHash();

  @$internal
  @override
  $ProviderElement<AuthLoginApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthLoginApi create(Ref ref) {
    return authLoginApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthLoginApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthLoginApi>(value),
    );
  }
}

String _$authLoginApiHash() => r'348f7f7bbd0a3b28e21a9d4e77cb2a846478ae96';

/// Notifier for managing login state

@ProviderFor(LoginNotifier)
const loginProvider = LoginNotifierProvider._();

/// Notifier for managing login state
final class LoginNotifierProvider
    extends $AsyncNotifierProvider<LoginNotifier, Map<String, dynamic>> {
  /// Notifier for managing login state
  const LoginNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loginProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loginNotifierHash();

  @$internal
  @override
  LoginNotifier create() => LoginNotifier();
}

String _$loginNotifierHash() => r'182a68ad4930831e8449ad76b61d60d9a1506faf';

/// Notifier for managing login state

abstract class _$LoginNotifier extends $AsyncNotifier<Map<String, dynamic>> {
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
