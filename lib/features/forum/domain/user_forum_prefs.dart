import 'package:cloud_firestore/cloud_firestore.dart';

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
    final lastReadsMap = (json['lastReads'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, (value as Timestamp).toDate()),
    );
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
    'lastReads': lastReads.map((k, v) => MapEntry(k, Timestamp.fromDate(v))),
  };
}
