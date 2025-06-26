import 'package:cloud_functions/cloud_functions.dart';
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
      if (data is! Map || data['success'] != true) {
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

