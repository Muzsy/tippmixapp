import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_stats_model.dart';

/// Tile displaying the top tipster in the current club.
class HomeTileTopTipster extends StatelessWidget {
  final UserStatsModel stats;
  final VoidCallback? onTap;

  const HomeTileTopTipster({super.key, required this.stats, this.onTap});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  stats.displayName.isNotEmpty
                      ? stats.displayName[0]
                      : '?',
                ),
              ),
              const SizedBox(height: 8),
              Text(loc.home_tile_top_tipster_title,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                loc.home_tile_top_tipster_description(stats.displayName),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onTap,
                child: Text(loc.home_tile_top_tipster_cta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
