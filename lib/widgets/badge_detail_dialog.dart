import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/badge.dart';
import '../utils/badge_icon_utils.dart';

class BadgeDetailDialog extends StatelessWidget {
  final BadgeData badge;

  const BadgeDetailDialog({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    String title;
    String description;
    switch (badge.key) {
      case 'badge_rookie':
        title = loc.badge_rookie_title;
        description = loc.badge_rookie_description;
        break;
      case 'badge_hot_streak':
        title = loc.badge_hot_streak_title;
        description = loc.badge_hot_streak_description;
        break;
      case 'badge_parlay_pro':
        title = loc.badge_parlay_pro_title;
        description = loc.badge_parlay_pro_description;
        break;
      case 'badge_night_owl':
        title = loc.badge_night_owl_title;
        description = loc.badge_night_owl_description;
        break;
      case 'badge_comeback_kid':
        title = loc.badge_comeback_kid_title;
        description = loc.badge_comeback_kid_description;
        break;
      default:
        title = badge.key;
        description = badge.key;
    }
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'badge-${badge.key}',
            child: Icon(getIconForBadge(badge.iconName), size: 64),
          ),
          const SizedBox(height: 12),
          Text(description, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.ok),
        ),
      ],
    );
  }
}
