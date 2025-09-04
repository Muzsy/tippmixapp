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
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.type,
    required this.content,
    required this.createdAt,
  });

  factory Post.fromJson(String id, Map<String, dynamic> json) {
    return Post(
      id: id,
      threadId: json['threadId'] as String,
      userId: json['userId'] as String,
      type: PostTypeX.fromJson(json['type'] as String),
      content: json['content'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'threadId': threadId,
    'userId': userId,
    'type': type.toJson(),
    'content': content,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
