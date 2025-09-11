import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../services/analytics_service.dart';
import '../providers/auth_provider.dart';

class OnboardingNotifier extends StateNotifier<int> {
  OnboardingNotifier(this._userService, this._analytics, this._getUid)
      : super(0);

  final UserService _userService;
  final AnalyticsService _analytics;
  final String? Function() _getUid;

  void setPage(int index) => state = index;

  Future<void> complete(Duration duration) async {
    final uid = _getUid();
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
  final getUid = () => ref.read(authProvider).user?.id;
  return OnboardingNotifier(userService, analytics, getUid);
});

final userServiceProvider = Provider<UserService>((ref) => UserService());
// FirebaseAuth provider removed
