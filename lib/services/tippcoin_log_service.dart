import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tippcoin_log_model.dart';

class TippCoinLogService {
  final FirebaseFirestore _firestore;

  TippCoinLogService([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection('coin_logs');

  Future<TippCoinLogModel> logCredit({
    required String userId,
    required int amount,
    required String type,
    String? txId,
    Map<String, dynamic>? meta,
  }) async {
    final doc = _ref.doc();
    final log = TippCoinLogModel.newCredit(
      id: doc.id,
      userId: userId,
      amount: amount,
      type: type,
      txId: txId,
      meta: meta,
    );
    await doc.set(log.toJson());
    return log;
  }

  Future<TippCoinLogModel> logDebit({
    required String userId,
    required int amount,
    required String type,
    String? txId,
    Map<String, dynamic>? meta,
  }) async {
    final doc = _ref.doc();
    final log = TippCoinLogModel.newDebit(
      id: doc.id,
      userId: userId,
      amount: amount,
      type: type,
      txId: txId,
      meta: meta,
    );
    await doc.set(log.toJson());
    return log;
  }
}
