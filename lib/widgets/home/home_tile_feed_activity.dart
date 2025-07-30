import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/feed_model.dart';

/// Tile displaying the latest feed activity if available.
class HomeTileFeedActivity extends ConsumerWidget {
  final FeedModel entry;
  final VoidCallback? onTap;

  const HomeTileFeedActivity({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                child: Text(entry.userId.isNotEmpty ? entry.userId[0] : '?'),
              ),
              const SizedBox(height: 8),
              Text(
                loc.home_tile_feed_activity_title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.home_tile_feed_activity_text_template(entry.userId),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onTap,
                child: Text(loc.home_tile_feed_activity_cta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
