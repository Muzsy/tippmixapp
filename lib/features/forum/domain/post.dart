import 'package:cloud_firestore/cloud_firestore.dart';

/// Type of the post within a thread.
enum PostType { tip, comment, system }

extension PostTypeX on PostType {
  String toJson() => name;
  static PostType fromJson(String value) =>
      PostType.values.firstWhere((e) => e.name == value);
}

/// Forum post document.
class Post {
  final String id;
  final String threadId;
  final String userId;
  final PostType type;
  final String content;
  final String? quotedPostId;
  final DateTime createdAt;
  final DateTime? editedAt;
  /// Aggregated on server – client treats as read-only.
  final int votesCount;
  final bool isHidden;

  const Post({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.type,
    required this.content,
    this.quotedPostId,
    required this.createdAt,
    this.editedAt,
    this.votesCount = 0,
    this.isHidden = false,
  });

  factory Post.fromJson(String id, Map<String, dynamic> json) {
    return Post(
      id: id,
      threadId: json['threadId'] as String,
      userId: json['userId'] as String,
      type: PostTypeX.fromJson(json['type'] as String),
      content: json['content'] as String,
      quotedPostId: json['quotedPostId'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      editedAt: (json['editedAt'] as Timestamp?)?.toDate(),
      votesCount: json['votesCount'] as int? ?? 0,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'threadId': threadId,
      'userId': userId, // must equal auth.uid per rules
      'type': type.toJson(),
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      if (quotedPostId != null) 'quotedPostId': quotedPostId,
    };
    return json;
  }
}
