import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> scheduleStreakWarning() async {
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, 22);
    await _plugin.zonedSchedule(
      0,
      'Streak at risk',
      'Log in to keep your streak!',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails('streak', 'streak'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
