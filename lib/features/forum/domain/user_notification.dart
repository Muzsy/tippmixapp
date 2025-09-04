import 'package:cloud_firestore/cloud_firestore.dart';

/// Per-user értesítés (@mention, reply, followed thread activity)
class UserNotification {
  final String id; // doc id
  final String type; // 'mention' | 'reply' | 'thread_activity'
  final String threadId;
  final String? postId; // lehet null thread-activity esetén
  final String? actorUid; // ki váltotta ki
  final bool read;
  final DateTime createdAt;

  const UserNotification({
    required this.id,
    required this.type,
    required this.threadId,
    this.postId,
    this.actorUid,
    required this.read,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'threadId': threadId,
    if (postId != null) 'postId': postId,
    if (actorUid != null) 'actorUid': actorUid,
    'read': read,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  static UserNotification fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return UserNotification(
      id: doc.id,
      type: (d['type'] ?? '').toString(),
      threadId: (d['threadId'] ?? '').toString(),
      postId: d['postId']?.toString(),
      actorUid: d['actorUid']?.toString(),
      read: (d['read'] ?? false) == true,
      createdAt:
          _toDateTime(d['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static DateTime? _toDateTime(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }
}
