import 'package:cloud_firestore/cloud_firestore.dart';

/// Követés egy targetre (user/thread/fixture)
class UserFollow {
  final String id; // doc id (pl. targetId)
  final String targetType; // 'user' | 'thread' | 'fixture'
  final String targetId; // uid | threadId | fixtureId
  final DateTime createdAt;

  const UserFollow({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'targetType': targetType,
    'targetId': targetId,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  static UserFollow fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return UserFollow(
      id: doc.id,
      targetType: (d['targetType'] ?? '').toString(),
      targetId: (d['targetId'] ?? '').toString(),
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
