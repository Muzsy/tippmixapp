import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class EmptyTicketPlaceholder extends StatelessWidget {
  const EmptyTicketPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(loc.empty_ticket_message),
      ),
    );
  }
}
