import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/services/analytics_service.dart';
import 'package:tipsterino/widgets/empty_ticket_placeholder.dart';

class FakeAnalytics extends AnalyticsService {
  bool ctaLogged = false;
  @override
  Future<void> logTicketsEmptyCtaClicked({String screen = 'my_tickets', String destination = 'bets'}) async {
    ctaLogged = true;
  }
}

void main() {
  testWidgets('empty placeholder CTA logs telemetry', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: AppRoute.home.name,
          builder: (context, state) => const Scaffold(body: EmptyTicketPlaceholder()),
        ),
        GoRoute(
          path: '/bets',
          name: AppRoute.bets.name,
          builder: (context, state) => const Scaffold(body: Text('bets_screen_marker')),
        ),
      ],
    );
    final fake = FakeAnalytics();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsServiceProvider.overrideWith((ref) => fake),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Submit Ticket'), findsOneWidget);

    await tester.tap(find.text('Submit Ticket'));
    await tester.pumpAndSettle();

    expect(fake.ctaLogged, isTrue);
    expect(find.text('bets_screen_marker'), findsOneWidget);
  });
}

