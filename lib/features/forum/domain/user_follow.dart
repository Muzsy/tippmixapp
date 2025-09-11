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
    // ISO8601 string a backend-agnosztikus tároláshoz
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserFollow.fromJson(String id, Map<String, dynamic> json) {
    return UserFollow(
      id: id,
      targetType: (json['targetType'] ?? '').toString(),
      targetId: (json['targetId'] ?? '').toString(),
      createdAt: _parseDate(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      return DateTime.tryParse(v);
    }
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v);
    }
    return null;
  }
}
