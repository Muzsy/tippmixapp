import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../models/badge.dart';
import '../utils/badge_icon_utils.dart';

/// Grid displaying earned profile badges.
class ProfileBadgeGrid extends StatelessWidget {
  final List<BadgeData> badges;
  final int crossAxisCount;

  const ProfileBadgeGrid({
    super.key,
    required this.badges,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (badges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(loc.profile_badges_empty),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final title = _title(loc, badge.key);
        final description = _description(loc, badge.key);
        return Tooltip(
          message: description,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(getIconForBadge(badge.iconName), size: 32),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  String _title(AppLocalizations loc, String key) {
    switch (key) {
      case 'badge_rookie':
        return loc.badge_rookie_title;
      case 'badge_hot_streak':
        return loc.badge_hot_streak_title;
      case 'badge_parlay_pro':
        return loc.badge_parlay_pro_title;
      case 'badge_night_owl':
        return loc.badge_night_owl_title;
      case 'badge_comeback_kid':
        return loc.badge_comeback_kid_title;
      default:
        return key;
    }
  }

  String _description(AppLocalizations loc, String key) {
    switch (key) {
      case 'badge_rookie':
        return loc.badge_rookie_description;
      case 'badge_hot_streak':
        return loc.badge_hot_streak_description;
      case 'badge_parlay_pro':
        return loc.badge_parlay_pro_description;
      case 'badge_night_owl':
        return loc.badge_night_owl_description;
      case 'badge_comeback_kid':
        return loc.badge_comeback_kid_description;
      default:
        return key;
    }
  }
}
