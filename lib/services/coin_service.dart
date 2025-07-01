import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/simple_logger.dart';
import '../utils/transaction_wrapper.dart';


// See docs/tippmix_app_teljes_adatmodell.md and docs/betting_ticket_data_model.md
// for details about the coin transaction model and integration points.

/// Service responsible for crediting and debiting TippCoins using
/// backend Cloud Functions.
class CoinService {
  final FirebaseFunctions? _functions;
  final FirebaseFirestore _firestore;
  final FirebaseAuth? _auth;
  final Logger _logger;
  late final TransactionWrapper _wrapper;

  CoinService({
    required FirebaseFirestore firestore,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    Logger? logger,
  })  : _functions = functions,
        _firestore = firestore,
        _auth = auth,
        _logger = logger ?? Logger('CoinService') {
    _wrapper = TransactionWrapper(
      firestore: _firestore,
      logger: _logger,
    );
  }

  FirebaseFirestore get _fs => _firestore;
  FirebaseAuth get _fa => _auth ?? FirebaseAuth.instance;

  /// Factory that injects the production Cloud Functions instance.
  factory CoinService.live({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Logger? logger,
  }) {
    return CoinService(
      functions: FirebaseFunctions.instanceFor(region: 'europe-central2'),
      firestore: firestore ?? FirebaseFirestore.instance,
      auth: auth,
      logger: logger,
    );
  }

  /// Deduct coins from the authenticated user using a Cloud Function.
  Future<void> debitCoin({
    required int amount,
    required String reason,
    required String transactionId,
  }) async {
    await _wrapper.run((txn) async {
      final uid = _fa.currentUser!.uid;
      final ref = _fs.collection('wallets').doc(uid);
      final snap = await txn.get(ref);
      final current = (snap.data()?['coins'] as int?) ?? 0;
      txn.set(ref, {'coins': current - amount}, SetOptions(merge: true));
    });
    await _callCoinTrx(
      amount: amount,
      type: 'debit',
      reason: reason,
      transactionId: transactionId,
    );
  }

  /// Credit coins to a user using a Cloud Function.
  Future<void> creditCoin({
    required int amount,
    required String reason,
    required String transactionId,
  }) async {
    await _wrapper.run((txn) async {
      final uid = _fa.currentUser!.uid;
      final ref = _fs.collection('wallets').doc(uid);
      final snap = await txn.get(ref);
      final current = (snap.data()?['coins'] as int?) ?? 0;
      txn.set(ref, {'coins': current + amount}, SetOptions(merge: true));
    });
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
    final user = auth?.currentUser ?? _fa.currentUser;
    if (user == null) return true;

    final db = firestore ?? _fs;
    final start = DateTime.now();
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await db
        .collection('wallets')
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
    _logger.info('coin_trx $type $amount');
    if (_functions == null) {
      return;
    }
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
      } on FirebaseFunctionsException catch (e) {
        // Log the error and rethrow
        rethrow;
    }
  }
}

