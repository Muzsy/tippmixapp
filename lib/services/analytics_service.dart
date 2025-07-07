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
}

final analyticsServiceProvider = Provider((ref) => AnalyticsService());
