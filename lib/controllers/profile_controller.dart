import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State notifier handling the profile screen logic.
class ProfileController extends StateNotifier<AsyncValue<User?>> {
  ProfileController() : super(const AsyncLoading()) {
    _load();
  }

  Future<void> _load() async {
    state = AsyncData(FirebaseAuth.instance.currentUser);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = const AsyncData(null);
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<User?>>(
        (ref) => ProfileController());
