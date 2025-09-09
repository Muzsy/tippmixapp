import 'package:cloud_firestore/cloud_firestore.dart';

/// Type of the thread.
enum ThreadType { general, match, system }

extension ThreadTypeX on ThreadType {
  String toJson() => name;
  static ThreadType fromJson(String value) =>
      ThreadType.values.firstWhere((e) => e.name == value);
}

/// Forum thread document.
class Thread {
  final String id;
  final String title;
  final ThreadType type;
  final String? fixtureId;
  final String createdBy;
  final DateTime createdAt;
  final bool locked;
  final bool pinned;
  final DateTime lastActivityAt;
  final int postsCount;
  final int votesCount;

  const Thread({
    required this.id,
    required this.title,
    required this.type,
    this.fixtureId,
    required this.createdBy,
    required this.createdAt,
    this.locked = false,
    this.pinned = false,
    required this.lastActivityAt,
    this.postsCount = 0,
    this.votesCount = 0,
  });

  factory Thread.fromJson(String id, Map<String, dynamic> json) {
    return Thread(
      id: id,
      title: json['title'] as String,
      type: ThreadTypeX.fromJson(json['type'] as String),
      fixtureId: json['fixtureId'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      locked: json['locked'] as bool? ?? false,
      pinned: json['pinned'] as bool? ?? false,
      lastActivityAt: (json['lastActivityAt'] as Timestamp).toDate(),
      postsCount: json['postsCount'] as int? ?? 0,
      votesCount: json['votesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    // Only fields allowed by Firestore rules are sent on create.
    final json = <String, dynamic>{
      'title': title,
      'type': type.toJson(),
      if (fixtureId != null) 'fixtureId': fixtureId,
      'createdBy': createdBy, // must match request.auth.uid per rules
      'createdAt': Timestamp.fromDate(createdAt),
    };
    return json;
  }

  Thread copyWith({
    bool? locked,
    bool? pinned,
  }) {
    return Thread(
      id: id,
      title: title,
      type: type,
      fixtureId: fixtureId,
      createdBy: createdBy,
      createdAt: createdAt,
      locked: locked ?? this.locked,
      pinned: pinned ?? this.pinned,
      lastActivityAt: lastActivityAt,
      postsCount: postsCount,
      votesCount: votesCount,
    );
  }
}
