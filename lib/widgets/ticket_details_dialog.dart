import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../models/tip_model.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

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
    return AlertDialog(
      title: Text('${loc.ticket_id} ${ticket.id}'),
      content: Text('${loc.tips_label}: ${tips.length}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.ok),
        ),
      ],
    );
  }
}
