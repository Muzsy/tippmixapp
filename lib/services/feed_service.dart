// Firebase removed – Supabase only
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/feed_event_type.dart';
import '../models/feed_model.dart';

/// Service responsible for writing feed entries and moderation reports.
class FeedService {
  FeedService();

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

    // Build entry (kept for possible local use)

    try {
      await sb.Supabase.instance.client.from('public_feed').insert({
        'user_id': userId,
        'event_type': eventType.name,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'extra_data': (extraData ?? <String, dynamic>{}),
        'likes': <String>[],
      });
    } catch (_) {}
  }

  /// Report a feed item for moderation.
  Future<void> reportFeedItem({
    required String userId,
    required String targetId,
    required String targetType,
    required String reason,
  }) async {
    try {
      await sb.Supabase.instance.client.from('moderation_reports').insert({
        'user_id': userId,
        'target_id': targetId,
        'target_type': targetType,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  /// Stream public feed entries ordered by latest first.
  Stream<List<FeedModel>> streamFeed() {
    return Stream.fromFuture(() async {
      try {
        final rows = await sb.Supabase.instance.client
            .from('public_feed')
            .select('user_id,event_type,message,timestamp,extra_data,likes')
            .order('timestamp', ascending: false);
        final list = List<Map<String, dynamic>>.from(rows as List);
        return list
            .map((r) => FeedModel.fromJson({
                  'userId': r['user_id'],
                  'eventType': r['event_type'],
                  'message': r['message'],
                  'timestamp': r['timestamp'],
                  'extraData': r['extra_data'],
                  'likes': r['likes'] ?? <String>[],
                }))
            .toList();
      } catch (_) {
        return <FeedModel>[];
      }
    }());
  }

  /// Fetches the latest feed entry if any exist.
  Future<FeedModel?> fetchLatestEntry() async {
    try {
      final rows = await sb.Supabase.instance.client
          .from('public_feed')
          .select('user_id,event_type,message,timestamp,extra_data,likes')
          .order('timestamp', ascending: false)
          .limit(1);
      final list = List<Map<String, dynamic>>.from(rows as List);
      if (list.isEmpty) return null;
      final r = list.first;
      return FeedModel.fromJson({
        'userId': r['user_id'],
        'eventType': r['event_type'],
        'message': r['message'],
        'timestamp': r['timestamp'],
        'extraData': r['extra_data'],
        'likes': r['likes'] ?? <String>[],
      });
    } catch (_) {
      return null;
    }
  }
}
