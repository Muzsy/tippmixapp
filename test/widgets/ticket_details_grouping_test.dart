import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/ticket_model.dart';
import 'package:tippmixapp/models/tip_model.dart';
import 'package:tippmixapp/widgets/ticket_details_dialog.dart';

Ticket _ticket() => Ticket(
      id: 't1',
      userId: 'u1',
      tips: const [],
      stake: 100,
      totalOdd: 2.0,
      potentialWin: 200,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      status: TicketStatus.won,
    );

TipModel tip(String id, TipStatus st, DateTime t) => TipModel(
      eventId: id,
      eventName: 'Match $id',
      startTime: t,
      sportKey: 'soccer',
      marketKey: 'h2h',
      outcome: 'Team $id',
      odds: 1.5,
      status: st,
    );

Future<void> _pump(WidgetTester tester, List<TipModel> tips) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => TicketDetailsDialog(ticket: _ticket(), tips: tips),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('groups won+lost with counts and order', (tester) async {
    final tips = [
      tip('a', TipStatus.won, DateTime(2025, 1, 1)),
      tip('b', TipStatus.lost, DateTime(2025, 1, 2)),
      tip('c', TipStatus.won, DateTime(2025, 1, 3)),
    ];
    await _pump(tester, tips);
    expect(find.textContaining('Won tips ('), findsOneWidget);
    expect(find.textContaining('Lost tips ('), findsOneWidget);

    // Expand won
    await tester.tap(find.textContaining('Won tips ('));
    await tester.pumpAndSettle();
    // Two won items
    expect(find.text('Match a'), findsOneWidget);
    expect(find.text('Match c'), findsOneWidget);
  });

  testWidgets('only won group shows when only won tips', (tester) async {
    final tips = [
      tip('a', TipStatus.won, DateTime(2025, 1, 1)),
    ];
    await _pump(tester, tips);
    expect(find.textContaining('Won tips ('), findsOneWidget);
    expect(find.textContaining('Lost tips ('), findsNothing);
    expect(find.textContaining('Pending tips ('), findsNothing);
  });

  testWidgets('pending group visible when pending exists', (tester) async {
    final tips = [
      tip('p', TipStatus.pending, DateTime(2025, 1, 1)),
    ];
    await _pump(tester, tips);
    expect(find.textContaining('Pending tips ('), findsOneWidget);
  });
}
