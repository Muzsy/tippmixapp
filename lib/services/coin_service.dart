import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// See docs/tippmix_app_teljes_adatmodell.md and docs/betting_ticket_data_model.md
// for details about the coin transaction model and integration points.

/// Service responsible for crediting and debiting TippCoins using
/// backend Cloud Functions.
class CoinService {
  final FirebaseFunctions _functions;

  CoinService([FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'europe-central2');

  /// Deduct coins from the authenticated user by calling the `coin_trx` Cloud
  /// Function.
  Future<void> debitCoin({
    required int amount,
    required String reason,
    required String transactionId,
  }) async {
    await _callCoinTrx(
      amount: amount,
      type: 'debit',
      reason: reason,
      transactionId: transactionId,
    );
  }

  /// Credit coins to a user by calling the `coin_trx` Cloud Function.
  Future<void> creditCoin({
    required int amount,
    required String reason,
    required String transactionId,
  }) async {
    await _callCoinTrx(
      amount: amount,
      type: 'credit',
      reason: reason,
      transactionId: transactionId,
    );
  }

  /// Convenience helper for the daily bonus job.
  Future<void> creditDailyBonus() async {
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
    await creditCoin(
      amount: 50,
      reason: 'daily_bonus',
      transactionId: transactionId,
    );
  }

  /// Check if the current user has already claimed today's bonus.
  Future<bool> hasClaimedToday({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) async {
    final user = auth?.currentUser ?? FirebaseAuth.instance.currentUser;
    if (user == null) return true;

    final db = firestore ?? FirebaseFirestore.instance;
    final start = DateTime.now();
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await db
        .collection('users')
        .doc(user.uid)
        .collection('coin_logs')
        .where('reason', isEqualTo: 'daily_bonus')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  /// Claim today's daily bonus for the authenticated user.
  Future<void> claimDailyBonus() => creditDailyBonus();

  Future<void> _callCoinTrx({
    required int amount,
    required String type,
    required String reason,
    required String transactionId,
  }) async {
    final callable = _functions.httpsCallable('coin_trx');
    try {
      final result = await callable.call<Map<String, dynamic>>(<String, dynamic>{
        'amount': amount,
        'type': type,
        'reason': reason,
        'transactionId': transactionId,
      });
      final data = result.data;
      if (data['success'] != true) {
        throw FirebaseFunctionsException(
          code: 'unknown',
          message: 'coin_trx failed',
          details: data,
        );
      }
    } on FirebaseFunctionsException catch (e, stack) {
      debugPrint('CoinService error: ${e.code}');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }
}

