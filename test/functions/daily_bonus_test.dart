import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Fakes for Firestore collections used in the job.

// ignore: subtype_of_sealed_class
class FakeQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  @override
  final String id;
  FakeQueryDocumentSnapshot(this.id);
  @override
  Map<String, dynamic> data() => <String, dynamic>{};
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
class FakeCoinLogDoc extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, Map<String, dynamic>> store;
  FakeCoinLogDoc(this.id, this.store);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    store[id] = data;
  }
}

// ignore: subtype_of_sealed_class
class FakeCoinLogCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, Map<String, dynamic>> store;
  FakeCoinLogCollection(this.store);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) {
    final key = id ?? 'log_${store.length}';
    store.putIfAbsent(key, () => <String, dynamic>{});
    return FakeCoinLogDoc(key, store);
  }
}

// ignore: subtype_of_sealed_class
class FakeUserDoc extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  final String uid;
  final Map<String, Map<String, dynamic>> logs;
  FakeUserDoc(this.uid, this.logs);

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (path == 'coin_logs') return FakeCoinLogCollection(logs);
    throw UnimplementedError();
  }
}

// ignore: subtype_of_sealed_class
class FakeUsersCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, Map<String, Map<String, dynamic>>> users;
  FakeUsersCollection(this.users);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) {
    users.putIfAbsent(id!, () => <String, Map<String, dynamic>>{});
    return FakeUserDoc(id, users[id]!);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final docs = users.keys.map(FakeQueryDocumentSnapshot.new).toList();
    return FakeQuerySnapshot(docs);
  }
}

class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, Map<String, Map<String, dynamic>>> logs = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (path == 'users') return FakeUsersCollection(logs);
    throw UnimplementedError();
  }
}

Future<void> runDailyBonusJob(FirebaseFirestore firestore) async {
  final users = await firestore.collection('users').get();
  for (final doc in users.docs) {
    final logs = firestore
        .collection('users')
        .doc(doc.id)
        .collection('coin_logs');
    await logs.doc().set({
      'userId': doc.id,
      'amount': 50,
      'type': 'credit',
      'reason': 'daily_bonus',
    });
  }
}

void main() {
  test('runDailyBonusJob writes coin log for every user', () async {
    final firestore = FakeFirebaseFirestore();
    // create two users
    firestore.collection('users').doc('u1');
    firestore.collection('users').doc('u2');

    await runDailyBonusJob(firestore);

    expect(firestore.logs['u1']!.length, 1);
    expect(firestore.logs['u2']!.length, 1);
  });
}
