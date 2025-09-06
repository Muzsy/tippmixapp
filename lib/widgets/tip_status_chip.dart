import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/tip_model.dart';

class TipStatusChip extends StatelessWidget {
  final TipStatus status;
  const TipStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    late Color bg;
    late Color fg;
    late String label;
    switch (status) {
      case TipStatus.won:
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
        label = loc.ticket_status_won;
        break;
      case TipStatus.lost:
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
        label = loc.ticket_status_lost;
        break;
      case TipStatus.pending:
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
        label = loc.ticket_status_pending;
        break;
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: fg, fontSize: 12)),
    );
  }
}

