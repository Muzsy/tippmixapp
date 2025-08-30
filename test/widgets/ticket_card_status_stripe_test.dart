import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/ticket_model.dart';
import 'package:tippmixapp/widgets/ticket_card.dart';

Ticket _t(TicketStatus s) => Ticket(
      id: 't1',
      userId: 'u1',
      tips: const [],
      stake: 100,
      totalOdd: 2.0,
      potentialWin: 200,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      status: s,
    );

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    );

void main() {
  setUpAll(() {
    Intl.defaultLocale = 'en';
  });

  testWidgets('TicketCard shows left status stripe with themed color', (tester) async {
    // Pending
    await tester.pumpWidget(_app(TicketCard(ticket: _t(TicketStatus.pending), onTap: () {})));
    await tester.pumpAndSettle();
    final stripe1 = tester.widget<Container>(find.byKey(const Key('ticket_status_stripe')));
    final scheme1 = Theme.of(tester.element(find.byType(Card))).colorScheme;
    expect(stripe1.color, scheme1.secondaryContainer);

    // Won
    await tester.pumpWidget(_app(TicketCard(ticket: _t(TicketStatus.won), onTap: () {})));
    await tester.pumpAndSettle();
    final stripe2 = tester.widget<Container>(find.byKey(const Key('ticket_status_stripe')));
    final scheme2 = Theme.of(tester.element(find.byType(Card))).colorScheme;
    expect(stripe2.color, scheme2.primaryContainer);

    // Lost
    await tester.pumpWidget(_app(TicketCard(ticket: _t(TicketStatus.lost), onTap: () {})));
    await tester.pumpAndSettle();
    final stripe3 = tester.widget<Container>(find.byKey(const Key('ticket_status_stripe')));
    final scheme3 = Theme.of(tester.element(find.byType(Card))).colorScheme;
    expect(stripe3.color, scheme3.errorContainer);
  });
}

