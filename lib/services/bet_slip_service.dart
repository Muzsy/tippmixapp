import 'package:flutter/foundation.dart';

// Ticket model no longer needed here
import 'package:tipsterino/models/tip_model.dart';
import 'ticket_service_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A szelvény-összeállító réteg végleges mentésért felelős statikus szolgáltatás.
///
/// * Ellenőrzi az üzleti szabályokat (tét > 0, legalább 1 tipp, stb.).
/// * Kiszámítja az össz‐oddsot és a potenciális nyereményt.
/// * Létrehoz egy `tickets/{ticketId}` dokumentumot Firestore‑ban.
///
/// Egyetlen be‐járati pont: [submitTicket].
/// Minden UI (CreateTicketScreen, BetSlipProvider) ezen keresztül ment.
class BetSlipService {
  BetSlipService._(); // ne lehessen példányosítani

  static double calculateTotalOdd(List<TipModel> tips) {
    return tips.fold<double>(1.0, (acc, tip) => acc * tip.odds);
  }

  static double calculatePotentialWin(double totalOdd, double stake) {
    return totalOdd * stake;
  }

  /// Ment egy szelvényt (Supabase‑re).
  ///
  /// [tips] – a kiválasztott tippek listája.
  /// [stake] – TippCoin tét (pozitív egész).
  ///
  /// Dobja: [ArgumentError] ha a bemenet nem valid, illetve
  /// [FirebaseException] ha az írás nem sikerül.
  static Future<void> submitTicket({
    required List<TipModel> tips,
    required int stake,
  }) async {
    // 1️⃣ Validáció
    if (tips.isEmpty) {
      throw ArgumentError('emptyBetSlip');
    }
    if (stake <= 0) {
      throw ArgumentError('invalidStake');
    }

    final u = Supabase.instance.client.auth.currentUser;
    if (u == null) {
      throw StateError('User not logged in');
    }

    // 2️⃣ Össz‑odds és várható nyeremény
    final totalOdd = calculateTotalOdd(tips);
    // Calculate but not needed to send to server explicitly here

    final supa = SupabaseTicketService();
    final id = await supa.createTicket(
      tips: tips.map((t) => t.toJson()).toList(),
      stake: stake,
    );
    // Optional: call edge function to book ledger transaction (idempotent by ticket id)
    try {
      await Supabase.instance.client.functions.invoke(
        'coin_trx',
        body: {
          'type': 'bet_stake',
          'delta': -stake,
          'ref_id': id,
        },
      );
    } catch (_) {}

    if (kDebugMode) {
      debugPrint('[BetSlipService] Ticket saved (stake: $stake, odds: $totalOdd)');
    }
  }
}
