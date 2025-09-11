import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart' as app_user;
import '../providers/auth_provider.dart';

/// State notifier handling the profile screen logic.
class ProfileController extends StateNotifier<AsyncValue<app_user.User?>> {
  final Ref _ref;
  ProfileController(this._ref) : super(const AsyncLoading()) {
    _ref.read(authProvider.notifier).authStateStream.listen((u) {
      state = AsyncData(u);
    });
  }

  Future<void> signOut() async => _ref.read(authProvider.notifier).logout();
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<app_user.User?>>(
      (ref) => ProfileController(ref),
    );
