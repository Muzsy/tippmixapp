import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tipsterino/services/feed_service.dart';
import 'package:tipsterino/models/feed_event_type.dart';

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
  Future<DocumentReference<Map<String, dynamic>>> add(
    Map<String, dynamic> data,
  ) async {
    final id = 'doc${store.length}';
    store[id] = data;
    return FakeDocumentReference(id, store);
  }

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
  test('addFeedEntry writes to public_feed', () async {
    final firestore = FakeFirebaseFirestore();
    final service = FeedService(firestore);

    await service.addFeedEntry(
      userId: 'u1',
      eventType: FeedEventType.betPlaced,
      message: 'msg',
      extraData: {'ticketId': 't1'},
    );

    final feed = firestore.data['public_feed']!;
    expect(feed.length, 1);
    final entry = feed.values.first;
    expect(entry['userId'], 'u1');
    expect(entry['eventType'], 'betPlaced');
    expect((entry['extraData'] as Map<String, dynamic>)['ticketId'], 't1');
  });

  test('reportFeedItem writes to moderation_reports', () async {
    final firestore = FakeFirebaseFirestore();
    final service = FeedService(firestore);

    await service.reportFeedItem(
      userId: 'u2',
      targetId: 'p1',
      targetType: 'post',
      reason: 'spam',
    );

    final reports = firestore.data['moderation_reports']!;
    expect(reports.length, 1);
    expect(reports.values.first['reason'], 'spam');
  });

  test('like own post forbidden and comment length checked', () async {
    final firestore = FakeFirebaseFirestore();
    final service = FeedService(firestore);

    expect(
      () => service.addFeedEntry(
        userId: 'u1',
        eventType: FeedEventType.like,
        message: '',
        extraData: {'targetUserId': 'u1'},
      ),
      throwsArgumentError,
    );

    final longText = 'a' * 251;
    expect(
      () => service.addFeedEntry(
        userId: 'u1',
        eventType: FeedEventType.comment,
        message: longText,
      ),
      throwsArgumentError,
    );
  });
}
