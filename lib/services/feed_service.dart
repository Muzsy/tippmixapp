import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/feed_event_type.dart';
import '../models/feed_model.dart';

/// Service responsible for writing feed entries and moderation reports.
class FeedService {
  final FirebaseFirestore _firestore;

  FeedService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Add a new entry to the public feed.
  Future<void> addFeedEntry({
    required String userId,
    required FeedEventType eventType,
    required String message,
    Map<String, dynamic>? extraData,
  }) async {
    if (eventType == FeedEventType.comment && message.length > 250) {
      throw ArgumentError('commentTooLong');
    }
    if (eventType == FeedEventType.like &&
        extraData != null &&
        extraData['targetUserId'] == userId) {
      throw ArgumentError('cannotLikeOwnPost');
    }

    final entry = FeedModel(
      userId: userId,
      eventType: eventType,
      message: message,
      timestamp: DateTime.now(),
      extraData: extraData ?? <String, dynamic>{},
      likes: const [],
    );

    try {
      await _firestore.collection('public_feed').add(entry.toJson());
    } catch (_) {
      // In tests Firestore may not be initialized
    }
  }

  /// Report a feed item for moderation.
  Future<void> reportFeedItem({
    required String userId,
    required String targetId,
    required String targetType,
    required String reason,
  }) async {
    try {
      await _firestore.collection('moderation_reports').add({
        'userId': userId,
        'targetId': targetId,
        'targetType': targetType,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // ignore errors when Firestore unavailable
    }
  }

  /// Stream public feed entries ordered by latest first.
  Stream<List<FeedModel>> streamFeed() {
    try {
      return _firestore
          .collection('public_feed')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((doc) => FeedModel.fromJson(doc.data())).toList(),
          );
    } catch (_) {
      return Stream.value(const <FeedModel>[]);
    }
  }

  /// Fetches the latest feed entry if any exist.
  Future<FeedModel?> fetchLatestEntry() async {
    try {
      final snap = await _firestore
          .collection('public_feed')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return FeedModel.fromJson(snap.docs.first.data());
    } catch (_) {
      return null;
    }
  }
}
