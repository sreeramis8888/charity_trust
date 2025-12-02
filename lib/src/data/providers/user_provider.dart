import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:charity_trust/src/data/models/user_model.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  UserModel? build() {
    return null;
  }

  void setUser(UserModel user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  bool get isUserActive => state?.status == 'active';
  bool get isUserInactive => state?.status == 'inactive';
}
