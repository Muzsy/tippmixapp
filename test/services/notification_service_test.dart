import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tippmixapp/services/notification_service.dart';

// ignore: subtype_of_sealed_class
class FakeDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, Map<String, dynamic>> store;
  FakeDocumentReference(this.id, this.store);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    store[id] = data;
  }

  @override
  Future<void> update(Map<String, Object?> data) async {
    final current = store[id] ?? <String, dynamic>{};
    data.forEach((key, value) => current[key] = value);
    store[id] = current;
  }
}

// ignore: subtype_of_sealed_class
class FakeCollectionReference extends Fake implements CollectionReference<Map<String, dynamic>> {
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
  test('markAsRead updates notification document', () async {
    final firestore = FakeFirebaseFirestore();
    final service = NotificationService(firestore);

    final collection = firestore.collection('users/u1/notifications');
    await collection.doc('n1').set({'isRead': false});

    await service.markAsRead('u1', 'n1');

    expect(collection.store['n1']?['isRead'], true);
  });
}
