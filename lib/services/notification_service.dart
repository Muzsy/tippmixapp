// Firebase removed – Supabase only
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/notification_model.dart';

class NotificationService {
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return Stream.fromFuture(() async {
      try {
        final rows = await sb.Supabase.instance.client
            .from('notifications')
            .select(
                'id,user_id,type,title,description,timestamp,is_read,category,archived,preview_url,destination')
            .eq('user_id', userId)
            .order('timestamp', ascending: false);
        final list = List<Map<String, dynamic>>.from(rows as List);
        return list
            .map((r) => NotificationModel.fromJson(
                  r['id'] as String,
                  {
                    'type': r['type'],
                    'title': r['title'],
                    'description': r['description'],
                    'timestamp': r['timestamp'],
                    'isRead': r['is_read'],
                    'category': r['category'],
                    'archived': r['archived'],
                    'previewUrl': r['preview_url'],
                    'destination': r['destination'],
                  },
                ))
            .toList();
      } catch (_) {
        // If table is missing or RLS denies, return empty list gracefully
        return <NotificationModel>[];
      }
    }());
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await sb.Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> archive(String userId, String notificationId) async {
    try {
      await sb.Supabase.instance.client
          .from('notifications')
          .update({'archived': true})
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (_) {}
  }
}
