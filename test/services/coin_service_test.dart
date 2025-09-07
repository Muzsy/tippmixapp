import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tipsterino/services/coin_service.dart';

class FakeHttpsCallableResult<T> implements HttpsCallableResult<T> {
  @override
  final T data;

  FakeHttpsCallableResult(this.data);
}

class FakeHttpsCallable extends Fake implements HttpsCallable {
  Map<String, dynamic>? lastData;
  final Map<String, dynamic> response;

  FakeHttpsCallable([this.response = const {'success': true}]);

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    lastData = Map<String, dynamic>.from(parameters as Map);
    return FakeHttpsCallableResult<T>(response as T);
  }
}

class FakeFirebaseFunctions extends Fake implements FirebaseFunctions {
  final FakeHttpsCallable callable;

  FakeFirebaseFunctions([FakeHttpsCallable? callable])
    : callable = callable ?? FakeHttpsCallable();

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callable;
  }
}

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

// Firestore fakes for hasClaimedToday
// ignore: subtype_of_sealed_class
class FakeQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  FakeQueryDocumentSnapshot(this._data);
  @override
  String get id => 'id';
  @override
  Map<String, dynamic> data() => _data;
}

// ignore: subtype_of_sealed_class
class FakeQuerySnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  final List<FakeQueryDocumentSnapshot> _docs;
  FakeQuerySnapshot(this._docs);
  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;
}

// ignore: subtype_of_sealed_class
class FakeQuery extends Fake implements Query<Map<String, dynamic>> {
  final List<Map<String, dynamic>> store;
  FakeQuery(this.store);

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    bool? isNull,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
  }) {
    return this;
  }

  @override
  Query<Map<String, dynamic>> limit(int _) => this;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final docs = store.map((e) => FakeQueryDocumentSnapshot(e)).toList();
    return FakeQuerySnapshot(docs);
  }
}

// ignore: subtype_of_sealed_class
class FakeLedgerCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final List<Map<String, dynamic>> store;
  FakeLedgerCollection(this.store);

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    bool? isNull,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
  }) {
    return FakeQuery(store);
  }

  @override
  Query<Map<String, dynamic>> limit(int count) => FakeQuery(store);

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return FakeQuery(store).get();
  }
}

// ignore: subtype_of_sealed_class
class FakeUserDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  final List<Map<String, dynamic>> logs;
  FakeUserDocument(this.logs);

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (path == 'ledger') return FakeLedgerCollection(logs);
    throw UnimplementedError();
  }
}

// ignore: subtype_of_sealed_class
class FakeUsersCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, List<Map<String, dynamic>>> data;
  FakeUsersCollection(this.data);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) {
    data.putIfAbsent(id!, () => <Map<String, dynamic>>[]);
    return FakeUserDocument(data[id]!);
  }
}

// ignore: subtype_of_sealed_class
class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, List<Map<String, dynamic>>> users = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (path == 'users') return FakeUsersCollection(users);
    throw UnimplementedError();
  }
}

void main() {
  test('debitCoin calls cloud function with correct parameters', () async {
    final functions = FakeFirebaseFunctions();
    final service = CoinService(
      firestore: FakeFirebaseFirestore(),
      functions: functions,
      auth: FakeFirebaseAuth(FakeUser('u1')),
    );

    await service.debitCoin(amount: 10, reason: 'bet', transactionId: 't1');

    expect(functions.callable.lastData, isNotNull);
    expect(functions.callable.lastData!['type'], 'debit');
    expect(functions.callable.lastData!['amount'], 10);
  });

  test('creditCoin uses credit type', () async {
    final functions = FakeFirebaseFunctions();
    final service = CoinService(
      firestore: FakeFirebaseFirestore(),
      functions: functions,
      auth: FakeFirebaseAuth(FakeUser('u1')),
    );

    await service.creditCoin(amount: 20, reason: 'bonus', transactionId: 't2');

    expect(functions.callable.lastData!['type'], 'credit');
    expect(functions.callable.lastData!['amount'], 20);
  });

  test('creditDailyBonus sends predefined amount and reason', () async {
    final functions = FakeFirebaseFunctions();
    final service = CoinService(
      firestore: FakeFirebaseFirestore(),
      functions: functions,
      auth: FakeFirebaseAuth(FakeUser('u1')),
    );

    await service.creditDailyBonus();

    expect(functions.callable.lastData!['type'], 'credit');
    expect(functions.callable.lastData!['amount'], 50);
    expect(functions.callable.lastData!['reason'], 'daily_bonus');
  });

  test('creditCoin throws when backend reports failure', () async {
    final callable = FakeHttpsCallable({'success': false});
    final functions = FakeFirebaseFunctions(callable);
    final service = CoinService(
      firestore: FakeFirebaseFirestore(),
      functions: functions,
      auth: FakeFirebaseAuth(FakeUser('u1')),
    );

    expect(
      () =>
          service.creditCoin(amount: 10, reason: 'bonus', transactionId: 't3'),
      throwsA(isA<FirebaseFunctionsException>()),
    );
  });

  test('hasClaimedToday returns true when log exists', () async {
    final firestore = FakeFirebaseFirestore();
    firestore.users['u1'] = [
      {
        'source': 'daily_bonus',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      },
    ];
    final auth = FakeFirebaseAuth(FakeUser('u1'));
    final service = CoinService(firestore: firestore);

    final result = await service.hasClaimedToday(
      auth: auth,
      firestore: firestore,
    );

    expect(result, isTrue);
  });

  test('hasClaimedToday returns false when no log', () async {
    final firestore = FakeFirebaseFirestore();
    firestore.users['u1'] = [];
    final auth = FakeFirebaseAuth(FakeUser('u1'));
    final service = CoinService(firestore: firestore);

    final result = await service.hasClaimedToday(
      auth: auth,
      firestore: firestore,
    );

    expect(result, isFalse);
  });
}
