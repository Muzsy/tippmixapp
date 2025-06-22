import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tippmixapp/services/badge_service.dart';
import 'package:tippmixapp/models/user_stats_model.dart';

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

// ignore: subtype_of_sealed_class
class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, Map<String, dynamic>> store;
  FakeDocumentReference(this.id, this.store);

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      throw UnimplementedError();

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
    final key = id ?? 'auto';
    store.putIfAbsent(key, () => <String, dynamic>{});
    return FakeDocumentReference(key, store);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final docs = store.entries
        .map((e) => FakeQueryDocumentSnapshot(e.key, e.value))
        .toList();
    return FakeQuerySnapshot(docs);
  }
}

// ignore: subtype_of_sealed_class
class FakeUserDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  final Map<String, Map<String, dynamic>> badges;
  FakeUserDocument(this.badges);

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (path == 'badges') return FakeCollectionReference(badges);
    throw UnimplementedError();
  }
}

// ignore: subtype_of_sealed_class
class FakeUsersCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, Map<String, Map<String, dynamic>>> data;
  FakeUsersCollection(this.data);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) {
    data.putIfAbsent(id!, () => <String, Map<String, dynamic>>{});
    return FakeUserDocument(data[id]!);
  }
}

class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, Map<String, Map<String, dynamic>>> _data = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (path == 'users') return FakeUsersCollection(_data);
    throw UnimplementedError();
  }
}

void main() {
  test('evaluateUserBadges returns firstWin when user has a win', () {
    final service = BadgeService(FakeFirebaseFirestore());
    final stats = UserStatsModel(
      uid: 'u1',
      displayName: 'A',
      coins: 0,
      totalBets: 1,
      totalWins: 1,
      winRate: 1.0,
    );

    final result = service.evaluateUserBadges(stats);

    expect(result.any((b) => b.key == 'badge_rookie'), isTrue);
  });

  test('assignNewBadges writes new documents', () async {
    final firestore = FakeFirebaseFirestore();
    final service = BadgeService(firestore);
    final stats = UserStatsModel(
      uid: 'u1',
      displayName: 'A',
      coins: 0,
      totalBets: 1,
      totalWins: 1,
      winRate: 1.0,
      currentWinStreak: 3,
    );

    await service.assignNewBadges('u1', stats);

    final userData = firestore._data['u1'];
    expect(userData, isNotNull);
    expect(userData!['badge_rookie'], isNotNull);
    expect(userData['badge_hot_streak'], isNotNull);
  });
}
