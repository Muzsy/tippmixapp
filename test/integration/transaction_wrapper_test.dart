import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tippmixapp/utils/simple_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tippmixapp/utils/transaction_wrapper.dart';
import 'package:tippmixapp/services/coin_service.dart';

// ignore: subtype_of_sealed_class
class FakeUser extends Fake implements User {
  @override
  final String uid;
  FakeUser(this.uid);
}

// ignore: subtype_of_sealed_class
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  FakeFirebaseAuth(this._user);
  final User? _user;
  @override
  User? get currentUser => _user;
}

class MockLogger extends Mock implements Logger {}

class StubFirestore extends FakeFirebaseFirestore {
  final List<String> errors;
  int attempts = 0;
  StubFirestore([this.errors = const []]);

  @override
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) transactionHandler, {
    Duration timeout = const Duration(seconds: 5),
    int maxAttempts = 5,
  }) async {
    attempts++;
    if (errors.isNotEmpty) {
      final code = errors.removeAt(0);
      throw FirebaseException(plugin: 'firestore', code: code);
    }
    return super.runTransaction(
      transactionHandler,
      timeout: timeout,
      maxAttempts: maxAttempts,
    );
  }
}

void main() {
  group('TransactionWrapper', () {
    late MockLogger logger;
    late FakeFirebaseAuth auth;

    setUp(() {
      logger = MockLogger();
      when(() => logger.info(any())).thenReturn(null);
      auth = FakeFirebaseAuth(FakeUser('u1'));
    });

    test('TW-01 successful transaction first try', () async {
      final firestore = StubFirestore();
      await firestore.collection('users').doc('u1').set({'coins': 100});
      final wrapper = TransactionWrapper(
        firestore: firestore,
        logger: logger,
        delayBetweenRetries: const Duration(milliseconds: 10),
      );
      final service = CoinService(
        firestore: firestore,
        auth: auth,
        logger: logger,
        );

      await service.debitCoin(
        amount: 20,
        reason: 'bet',
        transactionId: 't1',
      );

      final snap = await firestore.collection('users').doc('u1').get();
      expect(snap.data()!['coins'], 80);
      verify(() => logger.info('[TransactionWrapper] attempt 1')).called(1);
    });

    test('TW-02 retry aborted then success', () async {
      final firestore = StubFirestore(['aborted']);
      await firestore.collection('users').doc('u1').set({'coins': 100});
      final wrapper = TransactionWrapper(
        firestore: firestore,
        logger: logger,
        delayBetweenRetries: const Duration(milliseconds: 10),
      );
      final service = CoinService(
        firestore: firestore,
        auth: auth,
        logger: logger,
        );

      await service.debitCoin(amount: 20, reason: 'bet', transactionId: 't2');

      final snap = await firestore.collection('users').doc('u1').get();
      expect(snap.data()!['coins'], 80);
      expect(firestore.attempts, 2);
    });

    test('TW-03 retry deadline-exceeded twice', () async {
      final firestore = StubFirestore(['deadline-exceeded', 'deadline-exceeded']);
      await firestore.collection('users').doc('u1').set({'coins': 100});
      final wrapper = TransactionWrapper(
        firestore: firestore,
        logger: logger,
        delayBetweenRetries: const Duration(milliseconds: 10),
      );
      final service = CoinService(
        firestore: firestore,
        auth: auth,
        logger: logger,
        );

      await service.debitCoin(amount: 20, reason: 'bet', transactionId: 't3');

      final snap = await firestore.collection('users').doc('u1').get();
      expect(snap.data()!['coins'], 80);
      expect(firestore.attempts, 3);
    });

    test('TW-04 max retry exceeded', () async {
      final firestore = StubFirestore(['aborted', 'aborted', 'aborted']);
      await firestore.collection('users').doc('u1').set({'coins': 100});
      final wrapper = TransactionWrapper(
        firestore: firestore,
        logger: logger,
        delayBetweenRetries: const Duration(milliseconds: 10),
      );
      final service = CoinService(
        firestore: firestore,
        auth: auth,
        logger: logger,
        );

      expect(
        () => service.debitCoin(amount: 20, reason: 'bet', transactionId: 't4'),
        throwsA(isA<TooManyAttemptsException>()),
      );
      final snap = await firestore.collection('users').doc('u1').get();
      expect(snap.data()!['coins'], 100);
    });

    test('TW-05 concurrent debits', () async {
      final firestore = StubFirestore();
      await firestore.collection('users').doc('u1').set({'coins': 200});
      final wrapper = TransactionWrapper(
        firestore: firestore,
        logger: logger,
        delayBetweenRetries: const Duration(milliseconds: 10),
      );
      final service = CoinService(
        firestore: firestore,
        auth: auth,
        logger: logger,
        );

      await Future.wait([
        service.debitCoin(amount: 50, reason: 'bet', transactionId: 't5a'),
        service.debitCoin(amount: 50, reason: 'bet', transactionId: 't5b'),
      ]);

      final snap = await firestore.collection('users').doc('u1').get();
      expect(snap.data()!['coins'], 100);
    });

    test('TW-06 concurrent debit and credit', () async {
      final firestore = StubFirestore();
      await firestore.collection('users').doc('u1').set({'coins': 100});
      final wrapper = TransactionWrapper(
        firestore: firestore,
        logger: logger,
        delayBetweenRetries: const Duration(milliseconds: 10),
      );
      final service = CoinService(
        firestore: firestore,
        auth: auth,
        logger: logger,
        );

      await Future.wait([
        service.debitCoin(amount: 40, reason: 'bet', transactionId: 't6a'),
        service.creditCoin(amount: 30, reason: 'bonus', transactionId: 't6b'),
      ]);

      final snap = await firestore.collection('users').doc('u1').get();
      expect(snap.data()!['coins'], 90);
    });
  });
}
