import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tippmixapp/services/challenge_service.dart';

// ignore: subtype_of_sealed_class
class FakeQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, dynamic> _data;
  FakeQueryDocumentSnapshot(this.id, this._data);
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

class FakeQuery extends Fake implements Query<Map<String, dynamic>> {
  final List<Map<String, dynamic>> docs;
  FakeQuery(this.docs);

  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final snapshots = <FakeQueryDocumentSnapshot>[];
    for (var i = 0; i < docs.length; i++) {
      snapshots.add(FakeQueryDocumentSnapshot('doc$i', docs[i]));
    }
    return FakeQuerySnapshot(snapshots);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final List<Map<String, dynamic>> store;
  FakeCollectionReference(this.store);
  @override
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
    List<Map<String, dynamic>> filtered = store;
    if (field == 'endTime' && isGreaterThan is Timestamp) {
      filtered = store
          .where((d) => (d['endTime'] as Timestamp).compareTo(isGreaterThan) > 0)
          .toList();
    }
    // Add more filter logic here if needed for other parameters
    return FakeQuery(filtered);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return FakeQuery(store).get();
  }
}

class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, List<Map<String, dynamic>>> collections = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    collections.putIfAbsent(path, () => <Map<String, dynamic>>[]);
    return FakeCollectionReference(collections[path]!);
  }
}

void main() {
  test('fetchActiveChallenges filters by endTime', () async {
    final firestore = FakeFirebaseFirestore();
    final path = 'users/u1/challenges';
    firestore.collections[path] = [
      {
        'type': 'daily',
        'endTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1)))
      },
      {
        'type': 'friend',
        'username': 'Bob',
        'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 1)))
      },
    ];

    final service = ChallengeService(firestore);
    final result = await service.fetchActiveChallenges('u1');

    expect(result.length, 1);
    expect(result.first.type, ChallengeType.friend);
    expect(result.first.username, 'Bob');
  });
}
