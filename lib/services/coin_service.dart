import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

// See docs/tippmix_app_teljes_adatmodell.md and docs/betting_ticket_data_model.md
// for details about the coin transaction model and integration points.

/// Service responsible for crediting and debiting TippCoins using
/// backend Cloud Functions.
class CoinService {
  final FirebaseFunctions _functions;

  const CoinService([FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instance;

  /// Deduct coins from a user by calling the `coin_trx` Cloud Function.
  Future<void> debitCoin({
    required String userId,
    required int amount,
    required String reason,
    required String transactionId,
  }) async {
    await _callCoinTrx(
      userId: userId,
      amount: amount,
      type: 'debit',
      reason: reason,
      transactionId: transactionId,
    );
  }

  /// Credit coins to a user by calling the `coin_trx` Cloud Function.
  Future<void> creditCoin({
    required String userId,
    required int amount,
    required String reason,
    required String transactionId,
  }) async {
    await _callCoinTrx(
      userId: userId,
      amount: amount,
      type: 'credit',
      reason: reason,
      transactionId: transactionId,
    );
  }

  Future<void> _callCoinTrx({
    required String userId,
    required int amount,
    required String type,
    required String reason,
    required String transactionId,
  }) async {
    final callable = _functions.httpsCallable('coin_trx');
    try {
      await callable.call(<String, dynamic>{
        'userId': userId,
        'amount': amount,
        'type': type,
        'reason': reason,
        'transactionId': transactionId,
      });
    } on FirebaseFunctionsException catch (e, stack) {
      debugPrint('CoinService error: ${e.code}');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }
}

