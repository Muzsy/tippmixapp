import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tippmixapp/models/tip_model.dart';
import 'package:tippmixapp/services/bet_slip_service.dart';
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

// ignore: subtype_of_sealed_class
class FakeCoinService extends Fake implements CoinService {
  Map<String, dynamic>? last;
  @override
  Future<void> debitCoin({
    required int amount,
    required String reason,
    required String transactionId,
  }) async {
    last = {'amount': amount, 'reason': reason, 'transactionId': transactionId};
  }
}

// ignore: subtype_of_sealed_class
class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, Map<String, dynamic>> store;
  FakeDocumentReference(this.id, this.store);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    store[id] = data;
  }
}

// ignore: subtype_of_sealed_class
class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, Map<String, dynamic>> store;
  FakeCollectionReference(this.store);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) {
    final key = id ?? 'doc${store.length}';
    store.putIfAbsent(key, () => <String, dynamic>{});
    return FakeDocumentReference(key, store);
  }
}

// ignore: subtype_of_sealed_class
class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, Map<String, Map<String, dynamic>>> data = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    data.putIfAbsent(path, () => <String, Map<String, dynamic>>{});
    return FakeCollectionReference(data[path]!);
  }
}

void main() {
  test('submitTicket writes ticket and calls CoinService', () async {
    final firestore = FakeFirebaseFirestore();
    final coinService = FakeCoinService();
    final auth = FakeFirebaseAuth(FakeUser('u1'));

    final tips = [
      TipModel(
        eventId: 'e1',
        eventName: 'Match',
        startTime: DateTime(2020),
        sportKey: 'soccer',
        bookmaker: 'b',
        marketKey: 'h2h',
        outcome: 'Team',
        odds: 1.5,
      ),
    ];

    await BetSlipService.submitTicket(
      tips: tips,
      stake: 10,
      coinService: coinService,
      firestore: firestore,
      auth: auth,
    );

    expect(coinService.last, isNotNull);
    expect(coinService.last!['amount'], 10);
    expect(firestore.data['tickets']!.length, 1);
  });

  test('throws when user not authenticated', () async {
    final firestore = FakeFirebaseFirestore();
    final coinService = FakeCoinService();
    final auth = FakeFirebaseAuth(null);

    final tips = [
      TipModel(
        eventId: 'e1',
        eventName: 'Match',
        startTime: DateTime(2020),
        sportKey: 'soccer',
        bookmaker: 'b',
        marketKey: 'h2h',
        outcome: 'Team',
        odds: 1.5,
      ),
    ];

    expect(
      () => BetSlipService.submitTicket(
        tips: tips,
        stake: 10,
        coinService: coinService,
        firestore: firestore,
        auth: auth,
      ),
      throwsA(isA<FirebaseAuthException>()),
    );
  });
}
