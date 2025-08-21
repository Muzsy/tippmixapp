import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin wrapper over [FirebaseAnalytics] to record login A/B events.
class AnalyticsService {
  AnalyticsService([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? _tryInstance();

  static FirebaseAnalytics? _tryInstance() {
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  final FirebaseAnalytics? _analytics;
  bool _exposedLogged = false;

  Future<void> logLoginVariantExposed(String variant) async {
    if (_exposedLogged) return;
    _exposedLogged = true;
    try {
      await _analytics?.logEvent(
        name: 'login_variant_exposed',
        parameters: {'variant': variant},
      );
    } catch (_) {}
  }

  Future<void> logLoginSuccess(String variant) async {
    try {
      await _analytics?.logEvent(
        name: 'login_success',
        parameters: {'variant': variant},
      );
    } catch (_) {}
  }

  Future<void> logOnboardingCompleted(Duration duration) async {
    try {
      await _analytics?.logEvent(
        name: 'onboarding_completed',
        parameters: {'duration_sec': duration.inSeconds},
      );
    } catch (_) {}
  }

  Future<void> logOnboardingSkipped(Duration duration) async {
    try {
      await _analytics?.logEvent(
        name: 'onboarding_skipped',
        parameters: {'duration_sec': duration.inSeconds},
      );
    } catch (_) {}
  }

  Future<void> logNotificationOpened(String category) async {
    try {
      await _analytics?.logEvent(
        name: 'notif_opened',
        parameters: {'category': category},
      );
    } catch (_) {}
  }

  Future<void> logRewardClaimed(String rewardId, String type) async {
    try {
      await _analytics?.logEvent(
        name: 'reward_claimed',
        parameters: {'rewardId': rewardId, 'type': type},
      );
    } catch (_) {}
  }

  Future<void> logRegPasswordPwned() async {
    try {
      await _analytics?.logEvent(name: 'reg_password_pwned');
    } catch (_) {}
  }
}

final analyticsServiceProvider = Provider((ref) => AnalyticsService());
