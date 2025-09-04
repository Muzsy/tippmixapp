import 'package:cloud_firestore/cloud_firestore.dart';

/// Report document for moderation.
class Report {
  final String postId;
  final String userId;
  final String reason;
  final DateTime createdAt;

  const Report({
    required this.postId,
    required this.userId,
    required this.reason,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      reason: json['reason'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'userId': userId,
    'reason': reason,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
