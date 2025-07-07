import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin wrapper over [FirebaseAnalytics] to record login A/B events.
class AnalyticsService {
  AnalyticsService([FirebaseAnalytics? analytics])
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;
  bool _exposedLogged = false;

  Future<void> logLoginVariantExposed(String variant) async {
    if (_exposedLogged) return;
    _exposedLogged = true;
    try {
      await _analytics.logEvent(
        name: 'login_variant_exposed',
        parameters: {'variant': variant},
      );
    } catch (_) {}
  }

  Future<void> logLoginSuccess(String variant) async {
    try {
      await _analytics.logEvent(
        name: 'login_success',
        parameters: {'variant': variant},
      );
    } catch (_) {}
  }

  Future<void> logOnboardingCompleted(Duration duration) async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_completed',
        parameters: {'duration_sec': duration.inSeconds},
      );
    } catch (_) {}
  }

  Future<void> logOnboardingSkipped(Duration duration) async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_skipped',
        parameters: {'duration_sec': duration.inSeconds},
      );
    } catch (_) {}
  }

  Future<void> logNotificationOpened(String category) async {
    try {
      await _analytics.logEvent(
        name: 'notif_opened',
        parameters: {'category': category},
      );
    } catch (_) {}
  }
}

final analyticsServiceProvider = Provider((ref) => AnalyticsService());
