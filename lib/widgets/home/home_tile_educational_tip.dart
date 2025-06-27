import 'dart:math';

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Tile showing a random educational betting tip.
class HomeTileEducationalTip extends StatefulWidget {
  final Random? random;
  final VoidCallback? onTap;

  const HomeTileEducationalTip({super.key, this.random, this.onTap});

  @override
  State<HomeTileEducationalTip> createState() => _HomeTileEducationalTipState();
}

class _HomeTileEducationalTipState extends State<HomeTileEducationalTip> {
  String? _tip;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tip == null) {
      final loc = AppLocalizations.of(context)!;
      final tips = [
        loc.home_tile_educational_tip_1,
        loc.home_tile_educational_tip_2,
        loc.home_tile_educational_tip_3,
      ];
      final rnd = widget.random ?? Random();
      _tip = tips[rnd.nextInt(tips.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school, size: 48),
              const SizedBox(height: 8),
              Text(loc.home_tile_educational_tip_title,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              if (_tip != null)
                Text(_tip!, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              if (widget.onTap != null)
                ElevatedButton(
                  onPressed: widget.onTap,
                  child: Text(loc.home_tile_educational_tip_cta),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
