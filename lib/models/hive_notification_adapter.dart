import '../models/notification_model.dart';

/// Minimal adapter placeholder avoiding Hive dependency.
class HiveNotificationAdapter {
  Map<String, dynamic> toMap(NotificationModel model) => model.toJson();

  NotificationModel fromMap(String id, Map<String, dynamic> map) =>
      NotificationModel.fromJson(id, map);
}
