// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserNotifier)
const userProvider = UserNotifierProvider._();

final class UserNotifierProvider
    extends $NotifierProvider<UserNotifier, UserModel?> {
  const UserNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userNotifierHash();

  @$internal
  @override
  UserNotifier create() => UserNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserModel?>(value),
    );
  }
}

String _$userNotifierHash() => r'd0b710040ee082133e54d162b92241d76f9a6a95';

abstract class _$UserNotifier extends $Notifier<UserModel?> {
  UserModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserModel?, UserModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UserModel?, UserModel?>, UserModel?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(fetchUserProfile)
const fetchUserProfileProvider = FetchUserProfileProvider._();

final class FetchUserProfileProvider extends $FunctionalProvider<
        AsyncValue<UserModel?>, UserModel?, FutureOr<UserModel?>>
    with $FutureModifier<UserModel?>, $FutureProvider<UserModel?> {
  const FetchUserProfileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fetchUserProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fetchUserProfileHash();

  @$internal
  @override
  $FutureProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserModel?> create(Ref ref) {
    return fetchUserProfile(ref);
  }
}

String _$fetchUserProfileHash() => r'b7deacf1d1016d99d98ea2a4de0a99d98c173a2a';

@ProviderFor(updateUserProfile)
const updateUserProfileProvider = UpdateUserProfileFamily._();

final class UpdateUserProfileProvider extends $FunctionalProvider<
        AsyncValue<UserModel?>, UserModel?, FutureOr<UserModel?>>
    with $FutureModifier<UserModel?>, $FutureProvider<UserModel?> {
  const UpdateUserProfileProvider._(
      {required UpdateUserProfileFamily super.from,
      required Map<String, dynamic> super.argument})
      : super(
          retry: null,
          name: r'updateUserProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateUserProfileHash();

  @override
  String toString() {
    return r'updateUserProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserModel?> create(Ref ref) {
    final argument = this.argument as Map<String, dynamic>;
    return updateUserProfile(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateUserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateUserProfileHash() => r'978cc9aa5146f96e49a77b2b11253a45cf91fe20';

final class UpdateUserProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserModel?>, Map<String, dynamic>> {
  const UpdateUserProfileFamily._()
      : super(
          retry: null,
          name: r'updateUserProfileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UpdateUserProfileProvider call(
    Map<String, dynamic> userData,
  ) =>
      UpdateUserProfileProvider._(argument: userData, from: this);

  @override
  String toString() => r'updateUserProfileProvider';
}

@ProviderFor(fetchUsersByRole)
const fetchUsersByRoleProvider = FetchUsersByRoleFamily._();

final class FetchUsersByRoleProvider extends $FunctionalProvider<
        AsyncValue<List<UserModel>>, List<UserModel>, FutureOr<List<UserModel>>>
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  const FetchUsersByRoleProvider._(
      {required FetchUsersByRoleFamily super.from,
      required UsersListParams super.argument})
      : super(
          retry: null,
          name: r'fetchUsersByRoleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fetchUsersByRoleHash();

  @override
  String toString() {
    return r'fetchUsersByRoleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    final argument = this.argument as UsersListParams;
    return fetchUsersByRole(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FetchUsersByRoleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchUsersByRoleHash() => r'e28b5b774bf4ac0136ea8bfc56497cc0ccc1c258';

final class FetchUsersByRoleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserModel>>, UsersListParams> {
  const FetchUsersByRoleFamily._()
      : super(
          retry: null,
          name: r'fetchUsersByRoleProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  FetchUsersByRoleProvider call(
    UsersListParams params,
  ) =>
      FetchUsersByRoleProvider._(argument: params, from: this);

  @override
  String toString() => r'fetchUsersByRoleProvider';
}

@ProviderFor(verifyOtpForCharityMember)
const verifyOtpForCharityMemberProvider = VerifyOtpForCharityMemberFamily._();

final class VerifyOtpForCharityMemberProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const VerifyOtpForCharityMemberProvider._(
      {required VerifyOtpForCharityMemberFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'verifyOtpForCharityMemberProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$verifyOtpForCharityMemberHash();

  @override
  String toString() {
    return r'verifyOtpForCharityMemberProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return verifyOtpForCharityMember(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VerifyOtpForCharityMemberProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$verifyOtpForCharityMemberHash() =>
    r'114ad52d6ddae8475db1289c29e589dc5d3abb79';

final class VerifyOtpForCharityMemberFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<bool>,
            (
              String,
              String,
            )> {
  const VerifyOtpForCharityMemberFamily._()
      : super(
          retry: null,
          name: r'verifyOtpForCharityMemberProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  VerifyOtpForCharityMemberProvider call(
    String charityMemberId,
    String otp,
  ) =>
      VerifyOtpForCharityMemberProvider._(argument: (
        charityMemberId,
        otp,
      ), from: this);

  @override
  String toString() => r'verifyOtpForCharityMemberProvider';
}

@ProviderFor(fetchCurrentUserStatus)
const fetchCurrentUserStatusProvider = FetchCurrentUserStatusProvider._();

final class FetchCurrentUserStatusProvider extends $FunctionalProvider<
        AsyncValue<UserModel?>, UserModel?, FutureOr<UserModel?>>
    with $FutureModifier<UserModel?>, $FutureProvider<UserModel?> {
  const FetchCurrentUserStatusProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fetchCurrentUserStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fetchCurrentUserStatusHash();

  @$internal
  @override
  $FutureProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserModel?> create(Ref ref) {
    return fetchCurrentUserStatus(ref);
  }
}

String _$fetchCurrentUserStatusHash() =>
    r'716a193aeb5da5ed93e572d1c9f30dccbcd2a894';

@ProviderFor(createNewUser)
const createNewUserProvider = CreateNewUserFamily._();

final class CreateNewUserProvider extends $FunctionalProvider<
        AsyncValue<UserModel?>, UserModel?, FutureOr<UserModel?>>
    with $FutureModifier<UserModel?>, $FutureProvider<UserModel?> {
  const CreateNewUserProvider._(
      {required CreateNewUserFamily super.from,
      required Map<String, dynamic> super.argument})
      : super(
          retry: null,
          name: r'createNewUserProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createNewUserHash();

  @override
  String toString() {
    return r'createNewUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserModel?> create(Ref ref) {
    final argument = this.argument as Map<String, dynamic>;
    return createNewUser(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CreateNewUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createNewUserHash() => r'dfe04814d1417d719a7632621b85b25c7409d663';

final class CreateNewUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserModel?>, Map<String, dynamic>> {
  const CreateNewUserFamily._()
      : super(
          retry: null,
          name: r'createNewUserProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CreateNewUserProvider call(
    Map<String, dynamic> userData,
  ) =>
      CreateNewUserProvider._(argument: userData, from: this);

  @override
  String toString() => r'createNewUserProvider';
}

@ProviderFor(fetchPendingApprovals)
const fetchPendingApprovalsProvider = FetchPendingApprovalsProvider._();

final class FetchPendingApprovalsProvider extends $FunctionalProvider<
        AsyncValue<List<UserModel>>, List<UserModel>, FutureOr<List<UserModel>>>
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  const FetchPendingApprovalsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fetchPendingApprovalsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fetchPendingApprovalsHash();

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    return fetchPendingApprovals(ref);
  }
}

String _$fetchPendingApprovalsHash() =>
    r'81405320b3a5c30ccc3e6c86a76c06e26aff0ca7';

@ProviderFor(fetchUserReferrals)
const fetchUserReferralsProvider = FetchUserReferralsProvider._();

final class FetchUserReferralsProvider extends $FunctionalProvider<
        AsyncValue<List<UserModel>>, List<UserModel>, FutureOr<List<UserModel>>>
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  const FetchUserReferralsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fetchUserReferralsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fetchUserReferralsHash();

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    return fetchUserReferrals(ref);
  }
}

String _$fetchUserReferralsHash() =>
    r'2a50b26cbe4daecad03d12ba0f84be17b5f74ec1';

@ProviderFor(approveUser)
const approveUserProvider = ApproveUserFamily._();

final class ApproveUserProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const ApproveUserProvider._(
      {required ApproveUserFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'approveUserProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$approveUserHash();

  @override
  String toString() {
    return r'approveUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return approveUser(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ApproveUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$approveUserHash() => r'abb18b8e6fa97a24235425e051fd925ad989dd77';

final class ApproveUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const ApproveUserFamily._()
      : super(
          retry: null,
          name: r'approveUserProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ApproveUserProvider call(
    String userId,
  ) =>
      ApproveUserProvider._(argument: userId, from: this);

  @override
  String toString() => r'approveUserProvider';
}

@ProviderFor(rejectUser)
const rejectUserProvider = RejectUserFamily._();

final class RejectUserProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const RejectUserProvider._(
      {required RejectUserFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'rejectUserProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$rejectUserHash();

  @override
  String toString() {
    return r'rejectUserProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return rejectUser(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RejectUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rejectUserHash() => r'0712e762fceaefcac7587504e694f9157485e515';

final class RejectUserFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<bool>,
            (
              String,
              String,
            )> {
  const RejectUserFamily._()
      : super(
          retry: null,
          name: r'rejectUserProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  RejectUserProvider call(
    String userId,
    String reason,
  ) =>
      RejectUserProvider._(argument: (
        userId,
        reason,
      ), from: this);

  @override
  String toString() => r'rejectUserProvider';
}

@ProviderFor(PendingApprovalsNotifier)
const pendingApprovalsProvider = PendingApprovalsNotifierProvider._();

final class PendingApprovalsNotifierProvider
    extends $AsyncNotifierProvider<PendingApprovalsNotifier, List<UserModel>> {
  const PendingApprovalsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingApprovalsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingApprovalsNotifierHash();

  @$internal
  @override
  PendingApprovalsNotifier create() => PendingApprovalsNotifier();
}

String _$pendingApprovalsNotifierHash() =>
    r'b07c72528e0aa5dbafcd5ab32ad79c1910ac2a0a';

abstract class _$PendingApprovalsNotifier
    extends $AsyncNotifier<List<UserModel>> {
  FutureOr<List<UserModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<UserModel>>, List<UserModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<UserModel>>, List<UserModel>>,
        AsyncValue<List<UserModel>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(UserReferralsNotifier)
const userReferralsProvider = UserReferralsNotifierProvider._();

final class UserReferralsNotifierProvider
    extends $AsyncNotifierProvider<UserReferralsNotifier, List<UserModel>> {
  const UserReferralsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userReferralsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userReferralsNotifierHash();

  @$internal
  @override
  UserReferralsNotifier create() => UserReferralsNotifier();
}

String _$userReferralsNotifierHash() =>
    r'279161bf70ef5a6337883c1cf21e8f3fb3bcf952';

abstract class _$UserReferralsNotifier extends $AsyncNotifier<List<UserModel>> {
  FutureOr<List<UserModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<UserModel>>, List<UserModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<UserModel>>, List<UserModel>>,
        AsyncValue<List<UserModel>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
