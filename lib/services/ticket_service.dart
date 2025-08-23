import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    final uid = user.uid;
    final fs = FirebaseFirestore.instance;
    final ticketRef = fs
        .collection('users')
        .doc(uid)
        .collection('tickets')
        .doc();

    double totalOdd = 1.0;
    for (final t in tips) {
      final o = (t['odds'] as num?)?.toDouble() ?? 1.0;
      totalOdd *= o;
    }
    final potentialWin = stake * totalOdd;

    final now = FieldValue.serverTimestamp();

    final data = {
      'id': ticketRef.id,
      'userId': uid,
      'tips': tips,
      'stake': stake,
      'totalOdd': double.parse(totalOdd.toStringAsFixed(2)),
      'potentialWin': double.parse(potentialWin.toStringAsFixed(2)),
      'createdAt': now,
      'updatedAt': now,
      'status': 'pending',
    };

    await ticketRef.set(data, SetOptions(merge: false));
    return ticketRef.id;
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
