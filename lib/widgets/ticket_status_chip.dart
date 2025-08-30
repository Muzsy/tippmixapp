import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/ticket_model.dart';

class TicketStatusChip extends StatelessWidget {
  final TicketStatus status;

  const TicketStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case TicketStatus.won:
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
        label = loc.ticket_status_won;
        break;
      case TicketStatus.lost:
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
        label = loc.ticket_status_lost;
        break;
      case TicketStatus.pending:
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
        label = loc.ticket_status_pending;
        break;
      case TicketStatus.voided:
        bg = scheme.surfaceContainerHighest;
        fg = scheme.onSurface;
        label = loc.ticket_status_void;
        break;
    }

    return Semantics(
      label: label,
      button: true,
      child: Container
        (
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(color: fg),
        ),
      ),
    );
  }
}
