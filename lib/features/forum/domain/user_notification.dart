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
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserNotification.fromJson(String id, Map<String, dynamic> json) {
    return UserNotification(
      id: id,
      type: (json['type'] ?? '').toString(),
      threadId: (json['threadId'] ?? '').toString(),
      postId: json['postId']?.toString(),
      actorUid: json['actorUid']?.toString(),
      read: (json['read'] ?? false) == true,
      createdAt: _parseDate(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }
}
