import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Minimal replica of the log_coin Cloud Function.
Future<Map<String, dynamic>> callLogCoin(
  FirebaseFirestore firestore,
  Map<String, dynamic> data, {
  String? uid,
}) async {
  if (uid == null) throw 'unauthenticated';
  final amount = data['amount'];
  final type = data['type'];
  final transactionId = data['transactionId'];
  if (amount is! int || amount == 0) throw 'invalid-argument';
  const allowed = ['bet', 'deposit', 'withdraw', 'adjust'];
  if (!allowed.contains(type)) throw 'invalid-argument';
  if (transactionId is! String || transactionId.isEmpty) throw 'invalid-argument';
  final doc = firestore.collection('coin_logs').doc(transactionId);
  await doc.set({
    'userId': uid,
    'amount': amount,
    'type': type,
    'transactionId': transactionId,
    'meta': data['meta'],
  });
  return {'success': true};
}

// Firestore fakes
// ignore: subtype_of_sealed_class
class FakeLogDoc extends Fake implements DocumentReference<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, Map<String, dynamic>> store;
  FakeLogDoc(this.id, this.store);
  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    store[id] = data;
  }
}

// ignore: subtype_of_sealed_class
class FakeLogCollection extends Fake implements CollectionReference<Map<String, dynamic>> {
  final Map<String, Map<String, dynamic>> store;
  FakeLogCollection(this.store);
  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) {
    final key = id ?? 'log_${store.length}';
    store.putIfAbsent(key, () => <String, dynamic>{});
    return FakeLogDoc(key, store);
  }
}

class FakeFirestore extends Fake implements FirebaseFirestore {
  final Map<String, Map<String, dynamic>> logs = {};
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (path == 'coin_logs') return FakeLogCollection(logs);
    throw UnimplementedError();
  }
}

void main() {
  test('successfully stores log', () async {
    final fs = FakeFirestore();
    final result = await callLogCoin(fs, {
      'amount': 10,
      'type': 'deposit',
      'transactionId': 't1',
    }, uid: 'u1');
    expect(result['success'], true);
    expect(fs.logs['t1']!['userId'], 'u1');
  });

  test('unauthenticated throws', () async {
    final fs = FakeFirestore();
    expect(() => callLogCoin(fs, {
      'amount': 5,
      'type': 'bet',
      'transactionId': 't2',
    }), throwsA('unauthenticated'));
  });
}
