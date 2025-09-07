import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tipsterino/services/notification_service.dart';
import 'package:tipsterino/models/notification_model.dart';

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

  @override
  Future<void> update(Map<Object, Object?> data) async {
    final current = store[id] ?? <String, dynamic>{};
    data.forEach((key, value) {
      if (key is String) {
        current[key] = value;
      }
    });
    store[id] = current;
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
  test('NotificationModel.fromJson parses correctly', () {
    final json = {
      'type': 'badge',
      'title': 'Earned',
      'description': 'desc',
      'timestamp': DateTime(2021).toIso8601String(),
      'isRead': true,
    };

    final model = NotificationModel.fromJson('id1', json);

    expect(model.id, 'id1');
    expect(model.type, NotificationType.badge);
    expect(model.title, 'Earned');
    expect(model.description, 'desc');
    expect(model.timestamp.year, 2021);
    expect(model.isRead, isTrue);
  });
  test('markAsRead updates notification document', () async {
    final firestore = FakeFirebaseFirestore();
    final service = NotificationService(firestore);

    final collection =
        firestore.collection('users/u1/notifications')
            as FakeCollectionReference;
    await collection.doc('n1').set({'isRead': false});

    await service.markAsRead('u1', 'n1');

    expect(collection.store['n1']?['isRead'], true);
  });

  test('filterUnread helper keeps only unread items', () {
    List<NotificationModel> filterUnread(List<NotificationModel> list) {
      return list.where((n) => !n.isRead).toList();
    }

    final list = [
      NotificationModel(
        id: 'r',
        type: NotificationType.reward,
        title: 'r',
        description: 'd',
        timestamp: DateTime.now(),
        isRead: true,
      ),
      NotificationModel(
        id: 'u',
        type: NotificationType.reward,
        title: 'u',
        description: 'd',
        timestamp: DateTime.now(),
      ),
    ];

    final result = filterUnread(list);

    expect(result.length, 1);
    expect(result.first.id, 'u');
  });
}
