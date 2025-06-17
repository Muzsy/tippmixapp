import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/ticket_model.dart';
import 'ticket_status_chip.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        title: Row(
          children: [
            Text('x${ticket.totalOdd.toStringAsFixed(2)}'),
            const SizedBox(width: 8),
            TicketStatusChip(status: ticket.status),
          ],
        ),
        subtitle: Text('${loc.stakeHint}: ${ticket.stake.toStringAsFixed(0)}'),
        trailing: Text(ticket.potentialWin.toStringAsFixed(2)),
      ),
    );
  }
}
