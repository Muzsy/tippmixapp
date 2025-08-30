import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/services/analytics_service.dart';

class EmptyTicketPlaceholder extends ConsumerWidget {
  const EmptyTicketPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onPressed: () {
                // fire and forget CTA telemetry
                // ignore: unawaited_futures
                ref.read(analyticsServiceProvider).logTicketsEmptyCtaClicked(
                      screen: 'my_tickets',
                      destination: AppRoute.bets.name,
                    );
                context.goNamed(AppRoute.bets.name);
              },
              child: Text(loc.go_to_create_ticket),
            ),
          ],
        ),
      ),
    );
  }
}
