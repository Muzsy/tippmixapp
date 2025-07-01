import 'package:cloud_functions/cloud_functions.dart';

import '../models/tippcoin_log_model.dart';

class TippCoinLogService {
  final FirebaseFunctions _functions;

  TippCoinLogService([FirebaseFunctions? functions])
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'europe-central2');

  Future<TippCoinLogModel> logCredit({
    required String userId,
    required int amount,
    required String type,
    String? txId,
    Map<String, dynamic>? meta,
  }) async {
    final callable = _functions.httpsCallable('log_coin');
    await callable.call(<String, dynamic>{
      'amount': amount,
      'type': type,
      'meta': meta,
      'transactionId': txId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    });
    return TippCoinLogModel.newCredit(
      id: txId ?? '',
      userId: userId,
      amount: amount,
      type: type,
      txId: txId,
      meta: meta,
    );
  }

  Future<TippCoinLogModel> logDebit({
    required String userId,
    required int amount,
    required String type,
    String? txId,
    Map<String, dynamic>? meta,
  }) async {
    final callable = _functions.httpsCallable('log_coin');
    await callable.call(<String, dynamic>{
      'amount': amount,
      'type': type,
      'meta': meta,
      'transactionId': txId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    });
    return TippCoinLogModel.newDebit(
      id: txId ?? '',
      userId: userId,
      amount: amount,
      type: type,
      txId: txId,
      meta: meta,
    );
  }
}
