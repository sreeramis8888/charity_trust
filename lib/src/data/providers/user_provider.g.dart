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

String _$fetchUserProfileHash() => r'0285c239a1a144d06fcf3af3130b6cc0b2c76275';

@ProviderFor(updateUserProfile)
const updateUserProfileProvider = UpdateUserProfileFamily._();

final class UpdateUserProfileProvider extends $FunctionalProvider<
        AsyncValue<
            ({
              String? error,
              UserModel? user,
            })>,
        ({
          String? error,
          UserModel? user,
        }),
        FutureOr<
            ({
              String? error,
              UserModel? user,
            })>>
    with
        $FutureModifier<
            ({
              String? error,
              UserModel? user,
            })>,
        $FutureProvider<
            ({
              String? error,
              UserModel? user,
            })> {
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
  $FutureProviderElement<
      ({
        String? error,
        UserModel? user,
      })> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      ({
        String? error,
        UserModel? user,
      })> create(Ref ref) {
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

String _$updateUserProfileHash() => r'839720ab2d65d4b99629cde45b4a3d67af07f4c9';

final class UpdateUserProfileFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<
                ({
                  String? error,
                  UserModel? user,
                })>,
            Map<String, dynamic>> {
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

@ProviderFor(handleSuccessfulRegistration)
const handleSuccessfulRegistrationProvider =
    HandleSuccessfulRegistrationFamily._();

final class HandleSuccessfulRegistrationProvider extends $FunctionalProvider<
        AsyncValue<
            ({
              String? error,
              UserModel? user,
            })>,
        ({
          String? error,
          UserModel? user,
        }),
        FutureOr<
            ({
              String? error,
              UserModel? user,
            })>>
    with
        $FutureModifier<
            ({
              String? error,
              UserModel? user,
            })>,
        $FutureProvider<
            ({
              String? error,
              UserModel? user,
            })> {
  const HandleSuccessfulRegistrationProvider._(
      {required HandleSuccessfulRegistrationFamily super.from,
      required UserModel super.argument})
      : super(
          retry: null,
          name: r'handleSuccessfulRegistrationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$handleSuccessfulRegistrationHash();

  @override
  String toString() {
    return r'handleSuccessfulRegistrationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<
      ({
        String? error,
        UserModel? user,
      })> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      ({
        String? error,
        UserModel? user,
      })> create(Ref ref) {
    final argument = this.argument as UserModel;
    return handleSuccessfulRegistration(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HandleSuccessfulRegistrationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$handleSuccessfulRegistrationHash() =>
    r'2ecabf73d0a8cda5bf4c34bac426768685c4275c';

final class HandleSuccessfulRegistrationFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<
                ({
                  String? error,
                  UserModel? user,
                })>,
            UserModel> {
  const HandleSuccessfulRegistrationFamily._()
      : super(
          retry: null,
          name: r'handleSuccessfulRegistrationProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  HandleSuccessfulRegistrationProvider call(
    UserModel user,
  ) =>
      HandleSuccessfulRegistrationProvider._(argument: user, from: this);

  @override
  String toString() => r'handleSuccessfulRegistrationProvider';
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

String _$fetchUsersByRoleHash() => r'3427d0697b704f8a1ea7d470f2e7be91c32d216b';

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
    r'6c026b1ad48b46baf70a81999ca93c0a5668485c';

@ProviderFor(createNewUser)
const createNewUserProvider = CreateNewUserFamily._();

final class CreateNewUserProvider extends $FunctionalProvider<
        AsyncValue<
            ({
              String? error,
              UserModel? user,
            })>,
        ({
          String? error,
          UserModel? user,
        }),
        FutureOr<
            ({
              String? error,
              UserModel? user,
            })>>
    with
        $FutureModifier<
            ({
              String? error,
              UserModel? user,
            })>,
        $FutureProvider<
            ({
              String? error,
              UserModel? user,
            })> {
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
  $FutureProviderElement<
      ({
        String? error,
        UserModel? user,
      })> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      ({
        String? error,
        UserModel? user,
      })> create(Ref ref) {
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

String _$createNewUserHash() => r'de066e622c32944a86db20e1ce300c681f984a5a';

final class CreateNewUserFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<
                ({
                  String? error,
                  UserModel? user,
                })>,
            Map<String, dynamic>> {
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

@ProviderFor(ReferralTypeFilter)
const referralTypeFilterProvider = ReferralTypeFilterProvider._();

final class ReferralTypeFilterProvider
    extends $NotifierProvider<ReferralTypeFilter, bool> {
  const ReferralTypeFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'referralTypeFilterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$referralTypeFilterHash();

  @$internal
  @override
  ReferralTypeFilter create() => ReferralTypeFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$referralTypeFilterHash() =>
    r'ed06f917952c66f1a3c035f305150c2be3c2ceb2';

abstract class _$ReferralTypeFilter extends $Notifier<bool> {
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

@ProviderFor(ReferralSearch)
const referralSearchProvider = ReferralSearchProvider._();

final class ReferralSearchProvider
    extends $NotifierProvider<ReferralSearch, String> {
  const ReferralSearchProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'referralSearchProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$referralSearchHash();

  @$internal
  @override
  ReferralSearch create() => ReferralSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$referralSearchHash() => r'391343f17e1a8904e8b14dad36edea47803c5a59';

abstract class _$ReferralSearch extends $Notifier<String> {
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

@ProviderFor(ReferralStatusFilter)
const referralStatusFilterProvider = ReferralStatusFilterProvider._();

final class ReferralStatusFilterProvider
    extends $NotifierProvider<ReferralStatusFilter, String> {
  const ReferralStatusFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'referralStatusFilterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$referralStatusFilterHash();

  @$internal
  @override
  ReferralStatusFilter create() => ReferralStatusFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$referralStatusFilterHash() =>
    r'caea49f9cebff10f2d7a89f62500776b6494baa8';

abstract class _$ReferralStatusFilter extends $Notifier<String> {
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

@ProviderFor(ReferralDateFilter)
const referralDateFilterProvider = ReferralDateFilterProvider._();

final class ReferralDateFilterProvider
    extends $NotifierProvider<ReferralDateFilter, Map<String, String?>> {
  const ReferralDateFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'referralDateFilterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$referralDateFilterHash();

  @$internal
  @override
  ReferralDateFilter create() => ReferralDateFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String?>>(value),
    );
  }
}

String _$referralDateFilterHash() =>
    r'c9b1500a5bb5391e191ed3c4abcc6c7c06317545';

abstract class _$ReferralDateFilter extends $Notifier<Map<String, String?>> {
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

@ProviderFor(AllReferralsNotifier)
const allReferralsProvider = AllReferralsNotifierProvider._();

final class AllReferralsNotifierProvider extends $AsyncNotifierProvider<
    AllReferralsNotifier, ReferralPaginationState> {
  const AllReferralsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allReferralsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allReferralsNotifierHash();

  @$internal
  @override
  AllReferralsNotifier create() => AllReferralsNotifier();
}

String _$allReferralsNotifierHash() =>
    r'f780f38f68977b57d8dabea117ac820a99f1b97d';

abstract class _$AllReferralsNotifier
    extends $AsyncNotifier<ReferralPaginationState> {
  FutureOr<ReferralPaginationState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<ReferralPaginationState>, ReferralPaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ReferralPaginationState>,
            ReferralPaginationState>,
        AsyncValue<ReferralPaginationState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(IndirectReferralsNotifier)
const indirectReferralsProvider = IndirectReferralsNotifierProvider._();

final class IndirectReferralsNotifierProvider extends $AsyncNotifierProvider<
    IndirectReferralsNotifier, ReferralPaginationState> {
  const IndirectReferralsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'indirectReferralsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$indirectReferralsNotifierHash();

  @$internal
  @override
  IndirectReferralsNotifier create() => IndirectReferralsNotifier();
}

String _$indirectReferralsNotifierHash() =>
    r'f101c0814d7f41d090bde84777b1a5702403a23b';

abstract class _$IndirectReferralsNotifier
    extends $AsyncNotifier<ReferralPaginationState> {
  FutureOr<ReferralPaginationState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<ReferralPaginationState>, ReferralPaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ReferralPaginationState>,
            ReferralPaginationState>,
        AsyncValue<ReferralPaginationState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
