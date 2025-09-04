import 'package:cloud_firestore/cloud_firestore.dart';

/// Vote document linking a user to a post.
class Vote {
  final String postId;
  final String userId;
  final int value;
  final DateTime createdAt;

  const Vote({
    required this.postId,
    required this.userId,
    required this.value,
    required this.createdAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      value: json['value'] as int,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'userId': userId,
    'value': value,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
