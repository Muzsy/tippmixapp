import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    final client = Supabase.instance.client;
    final u = client.auth.currentUser;
    if (u == null) return null;

    double totalOdd = 1.0;
    for (final t in tips) {
      final o = (t['odds'] as num?)?.toDouble() ?? 1.0;
      totalOdd *= o;
    }
    final potentialWin = stake * totalOdd;

    final insert = await client
        .from('tickets')
        .insert({
          'user_id': u.id,
          'status': 'pending',
          'stake': stake,
          'total_odd': double.parse(totalOdd.toStringAsFixed(2)),
          'potential_win': double.parse(potentialWin.toStringAsFixed(2)),
        })
        .select('id')
        .single();
    final ticketId = insert['id'] as String;
    final items = tips.map((t) => {
          'ticket_id': ticketId,
          'fixture_id': (t['eventId'] ?? t['fixtureId']).toString(),
          'market': (t['marketKey'] ?? t['market'] ?? 'h2h').toString(),
          'odd': (t['odds'] as num?)?.toDouble() ?? 1.0,
          'selection': (t['outcome'] ?? t['selection']).toString(),
        });
    if (items.isNotEmpty) {
      await client.from('ticket_items').insert(items.toList());
    }
    return ticketId;
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
