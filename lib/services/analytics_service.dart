import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin wrapper over [FirebaseAnalytics] to record login A/B events.
class AnalyticsService {
  AnalyticsService();
  bool _exposedLogged = false;

  Future<void> logEvent(String name,
      {Map<String, Object>? parameters}) async {
    // no-op: Firebase Analytics removed
  }

  Future<void> logLoginVariantExposed(String variant) async {
    if (_exposedLogged) return;
    _exposedLogged = true;
    // no-op
  }

  Future<void> logLoginSuccess(String variant) async {
    // no-op
  }

  Future<void> logOnboardingCompleted(Duration duration) async {
    // no-op
  }

  Future<void> logOnboardingSkipped(Duration duration) async {
    // no-op
  }

  Future<void> logNotificationOpened(String category) async {
    // no-op
  }

  Future<void> logRewardClaimed(String rewardId, String type) async {
    // no-op
  }

  Future<void> logRegPasswordPwned() async {
    // no-op
  }

  // --- Tickets (MyTickets) telemetry --------------------------------------

  Future<void> logTicketsListViewed(int count) async {
    // no-op
  }

  Future<void> logTicketSelected(String ticketId) async {
    // no-op
  }

  Future<void> logTicketDetailsOpened({
    required String ticketId,
    required int tips,
    required String status,
    required num stake,
    required num totalOdd,
    required num potentialWin,
  }) async {
    // no-op
  }

  // --- Error telemetry -----------------------------------------------------

  Future<void> logErrorShown({
    required String screen,
    required String code,
    String? message,
  }) async {
    // no-op
  }

  // --- CTA telemetry -------------------------------------------------------

  Future<void> logTicketsEmptyCtaClicked({
    String screen = 'my_tickets',
    String destination = 'bets',
  }) async {
    // no-op
  }

  // --- Ticket details grouping telemetry ----------------------------------

  Future<void> logTicketDetailsGroupExpanded({
    required String group, // won|lost|pending
    required int count,
  }) async {
    // no-op
  }

  Future<void> logTicketDetailsItemViewed({
    required String eventId,
    required String outcome,
  }) async {
    // no-op
  }

  Future<void> logTicketsListChipTapped(String status) async {
    // no-op
  }

  Future<void> logTicketDetailsGroupToggled({
    required String group,
    required bool expanded,
    required int count,
  }) async {
    // no-op
  }
}

final analyticsServiceProvider = Provider((ref) => AnalyticsService());
