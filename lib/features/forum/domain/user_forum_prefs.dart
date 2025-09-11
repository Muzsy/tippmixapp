/// Per-user forum preferences.
class UserForumPrefs {
  final String userId;
  final List<String> followedThreadIds;
  final Map<String, DateTime> lastReads;

  const UserForumPrefs({
    required this.userId,
    this.followedThreadIds = const [],
    this.lastReads = const {},
  });

  factory UserForumPrefs.fromJson(String id, Map<String, dynamic> json) {
    final raw = (json['lastReads'] as Map?)?.cast<String, dynamic>() ?? {};
    final lastReadsMap = <String, DateTime>{};
    raw.forEach((key, value) {
      final dt = _parseDate(value);
      if (dt != null) lastReadsMap[key] = dt;
    });
    return UserForumPrefs(
      userId: json['userId'] as String? ?? id,
      followedThreadIds:
          (json['followedThreadIds'] as List?)?.cast<String>() ?? const [],
      lastReads: lastReadsMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'followedThreadIds': followedThreadIds,
    // ISO formátumban tároljuk a dátumokat
    'lastReads': lastReads.map((k, v) => MapEntry(k, v.toIso8601String())),
  };

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }
}
