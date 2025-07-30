import 'feed_event_type.dart';

/// Firestore model for a single feed entry.
/// Comments are stored in a subcollection `comments` under each feed document.
class FeedModel {
  final String userId;
  final FeedEventType eventType;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> extraData;
  final List<String> likes;

  FeedModel({
    required this.userId,
    required this.eventType,
    required this.message,
    required this.timestamp,
    this.extraData = const {},
    this.likes = const [],
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) => FeedModel(
    userId: json['userId'] as String? ?? '',
    eventType: FeedEventType.values.firstWhere(
      (e) => e.name == (json['eventType'] as String? ?? 'comment'),
      orElse: () => FeedEventType.comment,
    ),
    message: json['message'] as String? ?? '',
    timestamp: DateTime.parse(json['timestamp'] as String),
    extraData: Map<String, dynamic>.from(json['extraData'] ?? {}),
    likes: (json['likes'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'eventType': eventType.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'extraData': extraData,
    'likes': likes,
  };
}
