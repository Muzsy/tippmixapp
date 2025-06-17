import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../models/tip_model.dart';

class TicketDetailsDialog extends StatelessWidget {
  final Ticket ticket;
  final List<TipModel> tips;

  const TicketDetailsDialog({super.key, required this.ticket, required this.tips});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ticket ${ticket.id}'),
      content: Text('Tips: ${tips.length}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
