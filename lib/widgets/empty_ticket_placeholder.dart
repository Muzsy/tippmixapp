import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/routes/app_route.dart';

class EmptyTicketPlaceholder extends StatelessWidget {
  const EmptyTicketPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.empty_ticket_message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoute.bets.name),
              child: Text(loc.go_to_create_ticket),
            ),
          ],
        ),
      ),
    );
  }
}
