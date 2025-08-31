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

    String localeName = Localizations.localeOf(context).toLanguageTag();
    final n2 = NumberFormat.decimalPattern(localeName)
      ..minimumFractionDigits = 2
      ..maximumFractionDigits = 2;
    final n0 = NumberFormat.decimalPattern(localeName)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 0;

    Color statusStripe(TicketStatus s) {
      final scheme = Theme.of(context).colorScheme;
      switch (s) {
        case TicketStatus.won:
          return scheme.primaryContainer;
        case TicketStatus.lost:
          return scheme.errorContainer;
        case TicketStatus.pending:
          return scheme.secondaryContainer;
        case TicketStatus.voided:
          return scheme.surfaceContainerHighest;
      }
    }

    final leftCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${loc.stakeHint}: ${n0.format(ticket.stake)}'),
        const SizedBox(height: 4),
        Text('${loc.total_odds_label}: ${n2.format(ticket.totalOdd)}'),
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
        Text('${loc.potential_win_label}:', textAlign: TextAlign.right),
        Text(n2.format(ticket.potentialWin), textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleMedium),
      ],
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  key: const Key('ticket_status_stripe'),
                  width: 4,
                  color: statusStripe(ticket.status),
                ),
                const SizedBox(width: 12),
                Expanded(child: leftCol),
                const SizedBox(width: 12),
                rightCol,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
