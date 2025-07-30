enum NotificationType { reward, badge, friend, message, challenge }

enum NotificationCategory { tips, social, rewards, system }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final NotificationCategory category;
  final bool archived;
  final String? previewUrl;
  final String? destination;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    this.category = NotificationCategory.system,
    this.archived = false,
    this.previewUrl,
    this.destination,
  });

  factory NotificationModel.fromJson(String id, Map<String, dynamic> json) {
    return NotificationModel(
      id: id,
      type: NotificationType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'reward'),
        orElse: () => NotificationType.reward,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['isRead'] as bool? ?? false,
      category: NotificationCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String? ?? 'system'),
        orElse: () => NotificationCategory.system,
      ),
      archived: json['archived'] as bool? ?? false,
      previewUrl: json['previewUrl'] as String?,
      destination: json['destination'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'category': category.name,
    'archived': archived,
    'previewUrl': previewUrl,
    'destination': destination,
  };
}
