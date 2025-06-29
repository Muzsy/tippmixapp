import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:tippmixapp/models/ticket_model.dart';
import 'package:tippmixapp/models/tip_model.dart';
import 'coin_service.dart';

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

  /// Ment egy szelvényt a Firestore‑ba.
  ///
  /// [tips] – a kiválasztott tippek listája.
  /// [stake] – TippCoin tét (pozitív egész).
  ///
  /// Dobja: [ArgumentError] ha a bemenet nem valid, illetve
  /// [FirebaseException] ha az írás nem sikerül.
  static Future<void> submitTicket({
    required List<TipModel> tips,
    required int stake,
    CoinService? coinService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) async {
    // 1️⃣ Validáció
    if (tips.isEmpty) {
      throw ArgumentError('emptyBetSlip');
    }
    if (stake <= 0) {
      throw ArgumentError('invalidStake');
    }

    final firebaseAuth = auth ?? FirebaseAuth.instance;
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'User not logged in',
      );
    }
    final userId = currentUser.uid;

    // 2️⃣ Össz‑odds és várható nyeremény
    final totalOdd = calculateTotalOdd(tips);
    final potentialWin = calculatePotentialWin(totalOdd, stake.toDouble());

    // 3️⃣ Ticket modell összeállítása
    final ticketId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

    final ticket = Ticket(
      id: ticketId,
      userId: userId,
      tips: tips,
      stake: stake.toDouble(),
      totalOdd: totalOdd,
      potentialWin: potentialWin,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: TicketStatus.pending,
    );

    // 4️⃣ TippCoin levonás
    final cs = coinService ?? CoinService(firestore: firestore ?? FirebaseFirestore.instance);
    try {
      await cs.debitCoin(
        amount: stake,
        reason: 'bet_stake',
        transactionId: 'ticket_$ticketId',
      );
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'unauthenticated') {
        debugPrint('CoinService unauthenticated');
      }
      rethrow;
    }

    // 5️⃣ Írás Firestore‑ba (transactions nélkül – S2‑3‑ban bővítjük)
    final db = firestore ?? FirebaseFirestore.instance;
    final ticketsRef = db.collection('tickets');

    await ticketsRef.doc(ticketId).set(ticket.toJson());

    if (kDebugMode) {
      print('[BetSlipService] Ticket $ticketId saved (stake: $stake, odds: $totalOdd)');
    }
  }
}
