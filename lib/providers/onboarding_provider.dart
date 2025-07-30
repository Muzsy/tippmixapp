import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/user_service.dart';
import '../services/analytics_service.dart';

class OnboardingNotifier extends StateNotifier<int> {
  OnboardingNotifier(this._userService, this._analytics, [FirebaseAuth? auth])
    : _auth = auth ?? FirebaseAuth.instance,
      super(0);

  final UserService _userService;
  final AnalyticsService _analytics;
  final FirebaseAuth _auth;

  void setPage(int index) => state = index;

  Future<void> complete(Duration duration) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _userService.markOnboardingCompleted(uid);
      await _analytics.logOnboardingCompleted(duration);
    } else {
      await _analytics.logOnboardingSkipped(duration);
    }
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, int>((
  ref,
) {
  final userService = ref.watch(userServiceProvider);
  final analytics = ref.watch(analyticsServiceProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return OnboardingNotifier(userService, analytics, auth);
});

final userServiceProvider = Provider<UserService>((ref) => UserService());
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
