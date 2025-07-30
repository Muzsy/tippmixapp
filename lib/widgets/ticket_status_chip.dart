import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/ticket_model.dart';

class TicketStatusChip extends StatelessWidget {
  final TicketStatus status;

  const TicketStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    late final Color color;
    late final String label;

    switch (status) {
      case TicketStatus.won:
        color = Theme.of(context).colorScheme.secondary;
        label = loc.ticket_status_won;
        break;
      case TicketStatus.lost:
        color = Theme.of(context).colorScheme.error;
        label = loc.ticket_status_lost;
        break;
      case TicketStatus.pending:
        color = Theme.of(context).colorScheme.outlineVariant;
        label = loc.ticket_status_pending;
        break;
      case TicketStatus.voided:
        color = Theme.of(context).colorScheme.outlineVariant;
        label = loc.ticket_status_void;
    }

    return Chip(backgroundColor: color, label: Text(label));
  }
}
