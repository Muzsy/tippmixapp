import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ticket_model.dart';
import '../models/tip_model.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'ticket_status_chip.dart';

class TicketDetailsDialog extends StatelessWidget {
  final Ticket ticket;
  final List<TipModel> tips;

  const TicketDetailsDialog({
    super.key,
    required this.ticket,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateFmt = DateFormat.yMd().add_Hm();
    return AlertDialog(
      title: Text(loc.ticket_details_title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${loc.ticket_id}: '),
                Flexible(child: Text(ticket.id, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${loc.stakeHint}: '),
                Text(ticket.stake.toStringAsFixed(0)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${loc.total_odds_label}: '),
                Text(ticket.totalOdd.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${loc.potential_win_label}: '),
                Text(ticket.potentialWin.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${loc.filtersDate}: '),
                Text(dateFmt.format(ticket.createdAt)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${loc.tips_label}: '),
                Text('${tips.length}'),
                const SizedBox(width: 8),
                TicketStatusChip(status: ticket.status),
              ],
            ),
            if (tips.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              ...tips.map((tip) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(tip.eventName),
                        subtitle: Text('${loc.odds_label}: ${tip.odds}'),
                      ),
                      const Divider(height: 1),
                    ],
                  )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.ok),
        ),
      ],
    );
  }
}
