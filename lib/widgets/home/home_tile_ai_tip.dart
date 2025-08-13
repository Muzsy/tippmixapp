import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tippmixapp/l10n/app_localizations.dart';
import '../../services/ai_tip_provider.dart';

/// Tile displaying the daily AI betting recommendation.
class HomeTileAiTip extends ConsumerWidget {
  final AiTip tip;
  final VoidCallback? onTap;

  const HomeTileAiTip({super.key, required this.tip, this.onTap});

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
              const Icon(Icons.auto_graph, size: 48),
              const SizedBox(height: 8),
              Text(loc.home_tile_ai_tip_title, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                loc.home_tile_ai_tip_description(tip.team, tip.percent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onTap,
                child: Text(loc.home_tile_ai_tip_cta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
