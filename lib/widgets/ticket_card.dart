import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final dateFmt = DateFormat.yMd().add_Hm();

    final leftCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${loc.stakeHint}: ${ticket.stake.toStringAsFixed(0)}'),
        const SizedBox(height: 4),
        Text('${loc.total_odds_label}: ${ticket.totalOdd.toStringAsFixed(2)}'),
        const SizedBox(height: 4),
        Text('${loc.tips_label}: ${ticket.tips.length}'),
        const SizedBox(height: 6),
        Text(
          '${loc.filtersDate}: ${dateFmt.format(ticket.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );

    final rightCol = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TicketStatusChip(status: ticket.status),
        const SizedBox(height: 8),
        Text(
          '${loc.potential_win_label}:\n${ticket.potentialWin.toStringAsFixed(2)}',
          textAlign: TextAlign.right,
        ),
      ],
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftCol),
              const SizedBox(width: 12),
              rightCol,
            ],
          ),
        ),
      ),
    );
  }
}
