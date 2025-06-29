import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../utils/simple_logger.dart';

import '../utils/transaction_wrapper.dart';

// See docs/tippmix_app_teljes_adatmodell.md and docs/betting_ticket_data_model.md
// for details about the coin transaction model and integration points.

/// Service responsible for crediting and debiting TippCoins using
/// backend Cloud Functions.
class CoinService {
  final FirebaseFunctions? _functions;
  final Logger _logger;
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  TransactionWrapper? _wrapper;

  CoinService({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Logger? logger,
    TransactionWrapper? wrapper,
  })  : _functions = functions,
        _logger = logger ?? Logger('CoinService') {
    _firestore = firestore;
    _auth = auth;
    _wrapper = wrapper;
  }

  FirebaseFirestore get _fs => _firestore ??= FirebaseFirestore.instance;
  FirebaseAuth get _fa => _auth ??= FirebaseAuth.instance;
  TransactionWrapper get _txWrapper =>
      _wrapper ??= TransactionWrapper(firestore: _fs, logger: _logger);

  FirebaseFunctions get _fns =>
      _functions ?? FirebaseFunctions.instanceFor(region: 'europe-central2');

  /// Deduct coins from the authenticated user using a Firestore transaction.
  Future<void> debitCoin({
    required int amount,
    required String reason,
    required String transactionId,
  }) async {
    final user = _fa.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'unauthenticated');
    await _txWrapper.run<void>((tx) async {
      final doc = _fs.collection('users').doc(user.uid);
      final snap = await tx.get(doc);
      final current = (snap.data()?['coins'] as int?) ?? 0;
      tx.update(doc, {'coins': current - amount});
    });
  }

  /// Credit coins to a user using a Firestore transaction.
  Future<void> creditCoin({
    required int amount,
    required String reason,
    required String transactionId,
  }) async {
    final user = _fa.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'unauthenticated');
    await _txWrapper.run<void>((tx) async {
      final doc = _fs.collection('users').doc(user.uid);
      final snap = await tx.get(doc);
      final current = (snap.data()?['coins'] as int?) ?? 0;
      tx.update(doc, {'coins': current + amount});
    });
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
    final user = auth?.currentUser ?? _fa.currentUser;
    if (user == null) return true;

    final db = firestore ?? _fs;
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
    final callable = _fns.httpsCallable('coin_trx');
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

