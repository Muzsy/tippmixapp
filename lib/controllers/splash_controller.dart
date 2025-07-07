import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../router.dart';
import '../routes/app_route.dart';

class SplashController extends StateNotifier<AsyncValue<void>> {
  SplashController() : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = const AsyncData(null);
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? <String, dynamic>{};
    final user = UserModel.fromJson(data);
    if (user.onboardingCompleted) {
      router.goNamed(AppRoute.home.name);
    } else {
      router.goNamed(AppRoute.onboarding.name);
    }
    state = const AsyncData(null);
  }
}

final splashControllerProvider =
    StateNotifierProvider<SplashController, AsyncValue<void>>(
        (ref) => SplashController());
