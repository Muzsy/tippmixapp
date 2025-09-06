import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import "../../models/earned_badge_model.dart";
import '../../utils/badge_icon_utils.dart';

/// Tile displaying the latest earned badge.
class HomeTileBadgeEarned extends ConsumerWidget {
  final EarnedBadgeModel badge;
  final VoidCallback? onTap;

  const HomeTileBadgeEarned({super.key, required this.badge, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final title = _title(loc, badge.badge.key);
    final description = _description(loc, badge.badge.key);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(getIconForBadge(badge.badge.iconName), size: 48),
              const SizedBox(height: 8),
              Text(
                loc.home_tile_badge_earned_title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(description, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onTap,
                child: Text(loc.home_tile_badge_earned_cta),
              ),
            ],
          ),
        ),
      ),
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
