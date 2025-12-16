// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationsApi)
const notificationsApiProvider = NotificationsApiProvider._();

final class NotificationsApiProvider extends $FunctionalProvider<
    NotificationsApi,
    NotificationsApi,
    NotificationsApi> with $Provider<NotificationsApi> {
  const NotificationsApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationsApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationsApiHash();

  @$internal
  @override
  $ProviderElement<NotificationsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationsApi create(Ref ref) {
    return notificationsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsApi>(value),
    );
  }
}

String _$notificationsApiHash() => r'7263c789cf18e43e539d9cf1c9a27fd6b1fea4c8';

@ProviderFor(NotificationsNotifier)
const notificationsProvider = NotificationsNotifierProvider._();

final class NotificationsNotifierProvider extends $AsyncNotifierProvider<
    NotificationsNotifier, NotificationPaginationState> {
  const NotificationsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationsNotifierHash();

  @$internal
  @override
  NotificationsNotifier create() => NotificationsNotifier();
}

String _$notificationsNotifierHash() =>
    r'5d3b75767c0c2177c6d705d325d4dc48241a5ccb';

abstract class _$NotificationsNotifier
    extends $AsyncNotifier<NotificationPaginationState> {
  FutureOr<NotificationPaginationState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<NotificationPaginationState>,
        NotificationPaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<NotificationPaginationState>,
            NotificationPaginationState>,
        AsyncValue<NotificationPaginationState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(unreadNotificationCount)
const unreadNotificationCountProvider = UnreadNotificationCountProvider._();

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const UnreadNotificationCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'unreadNotificationCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadNotificationCount(ref);
  }
}

String _$unreadNotificationCountHash() =>
    r'5dfbe85d0bfc1710ed23c47e3449e05295036dec';
