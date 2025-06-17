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
        color = Colors.green;
        label = loc.ticket_status_won;
        break;
      case TicketStatus.lost:
        color = Colors.red;
        label = loc.ticket_status_lost;
        break;
      case TicketStatus.pending:
        color = Colors.grey;
        label = loc.ticket_status_pending;
        break;
      case TicketStatus.voided:
        color = Colors.grey;
        label = loc.ticket_status_void;
    }

    return Chip(
      backgroundColor: color,
      label: Text(label),
    );
  }
}
