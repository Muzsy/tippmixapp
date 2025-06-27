import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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

  Future<void> _loadTip() async {
    final lang = Localizations.localeOf(context).languageCode;
    final jsonStr =
        await rootBundle.loadString('lib/assets/educational_tips.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final tips = (data['tips'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final localized =
        tips.map((t) => t[lang] as String? ?? '').where((e) => e.isNotEmpty).toList();
    if (localized.isNotEmpty) {
      final rnd = widget.random ?? Random();
      setState(() {
        _tip = localized[rnd.nextInt(localized.length)];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tip == null) {
      _loadTip();
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
