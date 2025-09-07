import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tipsterino/flows/copy_bet_flow.dart';
import 'package:tipsterino/models/tip_model.dart';

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
  test('copyTicket writes document with tips', () async {
    final firestore = FakeFirebaseFirestore();
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

    final copyId = await copyTicket(
      userId: 'u1',
      ticketId: 't1',
      tips: tips,
      firestore: firestore,
    );

    final store = firestore.data['copied_bets/u1']!;
    expect(store[copyId]?['ticketId'], 't1');
    expect(store[copyId]?['wasModified'], isFalse);
    final savedTips = store[copyId]?['tips'] as List<dynamic>;
    expect(savedTips.length, 1);
    expect((savedTips.first as Map)['eventId'], 'e1');
  });
}
