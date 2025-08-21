// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/tippcoin_log_model.dart';

void main() {
  group('TippCoinLogModel', () {
    test('fromJson / toJson roundtrip', () {
      final json = {
        'userId': 'u1',
        'amount': 100,
        'type': 'deposit',
        'timestamp': DateTime(2024).toIso8601String(),
        'txId': 'tx1',
        'meta': {'k': 'v'},
      };

      final model = TippCoinLogModel.fromJson('id1', json);

      expect(model.toJson(), json);
    });

    test('Positive / negative amount preserved', () {
      final credit = TippCoinLogModel.newCredit(
        id: 'c1',
        userId: 'u1',
        amount: 100,
        type: 'deposit',
      );
      final debit = TippCoinLogModel.newDebit(
        id: 'd1',
        userId: 'u1',
        amount: 50,
        type: 'bet',
      );

      expect(credit.amount, 100);
      expect(debit.amount, -50);
    });

    test('Enum validation', () {
      expect(
        () => TippCoinLogModel.fromJson('x', {
          'userId': 'u1',
          'amount': 10,
          'type': 'invalid',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        throwsFormatException,
      );
    });
  });
}
