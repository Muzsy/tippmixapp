import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tippmixapp/models/ticket_model.dart';
import 'package:tippmixapp/models/tip_model.dart';

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

  /// Ment egy szelvényt a Firestore‑ba.
  ///
  /// [userId] – kötelező, a bejelentkezett felhasználó azonosítója.  
  /// [tips] – a kiválasztott tippek listája.  
  /// [stake] – TippCoin tét (pozitív egész).
  ///
  /// Dobja: [ArgumentError] ha a bemenet nem valid, illetve
  /// [FirebaseException] ha az írás nem sikerül.
  static Future<void> submitTicket({
    required String userId,
    required List<TipModel> tips,
    required int stake,
  }) async {
    // 1️⃣ Validáció
    if (userId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }
    if (tips.isEmpty) {
      throw ArgumentError('emptyBetSlip');
    }
    if (stake <= 0) {
      throw ArgumentError('invalidStake');
    }

    // 2️⃣ Össz‑odds és várható nyeremény
    final totalOdd = tips.fold<double>(1.0, (acc, tip) => acc * tip.odds);
    final potentialWin = totalOdd * stake;

    // 3️⃣ Ticket modell összeállítása
    final ticketId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

    final ticket = TicketModel(
      ticketId: ticketId,
      userId: userId,
      tips: tips,
      stake: stake,
      totalOdd: totalOdd,
      potentialWin: potentialWin,
      createdAt: DateTime.now(),
      status: TicketStatus.pending,
      evaluatedAt: null,
    );

    // 4️⃣ Írás Firestore‑ba (transactions nélkül – S2‑3‑ban bővítjük)
    final ticketsRef = FirebaseFirestore.instance.collection('tickets');

    await ticketsRef.doc(ticketId).set(ticket.toJson());

    if (kDebugMode) {
      print('[BetSlipService] Ticket $ticketId saved (stake: $stake, odds: $totalOdd)');
    }
  }
}
