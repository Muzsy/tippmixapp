import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/telemetry_sanitizer.dart';

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

  Future<void> logEvent(String name,
      {Map<String, Object>? parameters}) async {
    try {
      await _analytics?.logEvent(name: name, parameters: parameters);
    } catch (_) {}
  }

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

  // --- Tickets (MyTickets) telemetry --------------------------------------

  Future<void> logTicketsListViewed(int count) async {
    try {
      await _analytics?.logEvent(
        name: 'tickets_list_viewed',
        parameters: {
          'count': TelemetrySanitizer.safeCount(count),
        },
      );
    } catch (_) {}
  }

  Future<void> logTicketSelected(String ticketId) async {
    try {
      await _analytics?.logEvent(
        name: 'ticket_selected',
        parameters: {
          'ticketId': TelemetrySanitizer.normalizeTicketId(ticketId),
        },
      );
    } catch (_) {}
  }

  Future<void> logTicketDetailsOpened({
    required String ticketId,
    required int tips,
    required String status,
    required num stake,
    required num totalOdd,
    required num potentialWin,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'ticket_details_opened',
        parameters: {
          'ticketId': TelemetrySanitizer.normalizeTicketId(ticketId),
          'tips': TelemetrySanitizer.safeCount(tips),
          'status': TelemetrySanitizer.normalizeStatus(status),
          'stake': TelemetrySanitizer.safeAmount(stake, min: 0, max: 1e8, precision: 0),
          'totalOdd': TelemetrySanitizer.safeAmount(totalOdd, min: 0, max: 1e4, precision: 2),
          'potentialWin': TelemetrySanitizer.safeAmount(potentialWin, min: 0, max: 1e10, precision: 0),
        },
      );
    } catch (_) {}
  }

  // --- Error telemetry -----------------------------------------------------

  Future<void> logErrorShown({
    required String screen,
    required String code,
    String? message,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'error_shown',
        parameters: {
          'screen': TelemetrySanitizer.normalizeScreenId(screen),
          'code': TelemetrySanitizer.normalizeTicketId(code), // reuse simple sanitizer
          if (message != null)
            'message': TelemetrySanitizer.normalizeErrorMessage(message),
        },
      );
    } catch (_) {}
  }

  // --- CTA telemetry -------------------------------------------------------

  Future<void> logTicketsEmptyCtaClicked({
    String screen = 'my_tickets',
    String destination = 'bets',
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'tickets_empty_cta_clicked',
        parameters: {
          'screen': TelemetrySanitizer.normalizeScreenId(screen),
          'dest': TelemetrySanitizer.normalizeScreenId(destination),
        },
      );
    } catch (_) {}
  }

  // --- Ticket details grouping telemetry ----------------------------------

  Future<void> logTicketDetailsGroupExpanded({
    required String group, // won|lost|pending
    required int count,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'ticket_details_group_expanded',
        parameters: {
          'group': TelemetrySanitizer.normalizeStatus(group),
          'count': TelemetrySanitizer.safeCount(count),
        },
      );
    } catch (_) {}
  }

  Future<void> logTicketDetailsItemViewed({
    required String eventId,
    required String outcome,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'ticket_details_item_viewed',
        parameters: {
          'eventId': TelemetrySanitizer.normalizeTicketId(eventId),
          'outcome': outcome,
        },
      );
    } catch (_) {}
  }

  Future<void> logTicketsListChipTapped(String status) async {
    try {
      await _analytics?.logEvent(
        name: 'tickets_list_chip_tapped',
        parameters: {
          'status': TelemetrySanitizer.normalizeStatus(status),
        },
      );
    } catch (_) {}
  }

  Future<void> logTicketDetailsGroupToggled({
    required String group,
    required bool expanded,
    required int count,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'ticket_details_group_toggled',
        parameters: {
          'group': TelemetrySanitizer.normalizeStatus(group),
          'expanded': expanded,
          'count': TelemetrySanitizer.safeCount(count),
        },
      );
    } catch (_) {}
  }
}

final analyticsServiceProvider = Provider((ref) => AnalyticsService());
