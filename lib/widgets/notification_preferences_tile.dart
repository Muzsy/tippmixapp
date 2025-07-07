import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class NotificationPreferencesTile extends StatelessWidget {
  final Map<String, bool> prefs;
  final void Function(String key, bool value) onChanged;

  const NotificationPreferencesTile({
    super.key,
    required this.prefs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        SwitchListTile(
          title: Text(loc.notif_tips),
          value: prefs['tips'] ?? true,
          onChanged: (v) => onChanged('tips', v),
        ),
        SwitchListTile(
          title: Text(loc.notif_friend_activity),
          value: prefs['friendActivity'] ?? true,
          onChanged: (v) => onChanged('friendActivity', v),
        ),
        SwitchListTile(
          title: Text(loc.notif_badge),
          value: prefs['badge'] ?? true,
          onChanged: (v) => onChanged('badge', v),
        ),
        SwitchListTile(
          title: Text(loc.notif_rewards),
          value: prefs['rewards'] ?? true,
          onChanged: (v) => onChanged('rewards', v),
        ),
        SwitchListTile(
          title: Text(loc.notif_system),
          value: prefs['system'] ?? true,
          onChanged: (v) => onChanged('system', v),
        ),
      ],
    );
  }
}
