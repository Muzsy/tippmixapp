import 'package:flutter/widgets.dart';
import 'api_football_service.dart';
import 'odds_drift_checker.dart';
import '../widgets/odds_drift_dialog.dart';
import '../models/tip_model.dart';

class SlipSignals extends ChangeNotifier {
  void notifyChanged() => notifyListeners();
}

class TicketService {
  static final SlipSignals signals = SlipSignals();

  Future<String?> createTicket({
    required List<Map<String, dynamic>> tips,
    required num stake,
  }) async {
    // Integrate with backend callable
    return 'ticket-id';
  }

  Future<void> removeTip(TipModel tip) async {
    // Implement removal logic
    signals.notifyChanged();
  }

  Future<String?> confirmAndCreateTicket(
    BuildContext context, {
    required List<Map<String, dynamic>> tips,
    required num stake,
    double threshold = 0.05,
  }) async {
    final checker = OddsDriftChecker(ApiFootballService());
    final drift = await checker.check(tips);
    final hasBlocking = drift.hasBlocking(threshold);
    if (hasBlocking) {
      // ignore: use_build_context_synchronously
      final accepted = await showOddsDriftDialog(context, drift);
      if (!accepted) return null; // user canceled
      // Optional: update tips with new odds here if desired
    }
    // proceed with existing createTicket flow
    final id = await createTicket(tips: tips, stake: stake);
    if (id != null) {
      signals.notifyChanged();
    }
    return id;
  }
}
