import 'package:flutter/material.dart';
import '../../../services/user_service.dart';
import '../../../models/notification_preferences.dart';
import '../../../widgets/notification_preferences_tile.dart';

class NotificationPrefsSection extends StatefulWidget {
  final String uid;
  final UserService service;
  const NotificationPrefsSection({
    super.key,
    required this.uid,
    required this.service,
  });

  @override
  State<NotificationPrefsSection> createState() => _NotificationPrefsSectionState();
}

class _NotificationPrefsSectionState extends State<NotificationPrefsSection> {
  late Map<String, bool> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = const NotificationPreferences().toMap();
  }

  Future<void> _update(String key, bool value) async {
    setState(() => _prefs[key] = value);
    await widget.service.updateNotificationPrefs(widget.uid, _prefs);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationPreferencesTile(
      prefs: _prefs,
      onChanged: _update,
    );
  }
}
