import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/ticket_model.dart';
import 'package:tippmixapp/models/tip_model.dart';
import 'package:tippmixapp/widgets/ticket_details_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Ticket _sampleTicket() => Ticket(
        id: 't1',
        userId: 'u1',
        tips: const [],
        stake: 100,
        totalOdd: 3.5,
        potentialWin: 350,
        createdAt: DateTime(2025, 6, 15, 12, 30),
        updatedAt: DateTime(2025, 6, 15, 12, 30),
        status: TicketStatus.pending,
      );

  List<TipModel> _sampleTips() => [
        TipModel(
          eventId: 'e1',
          eventName: 'Team A – Team B',
          startTime: DateTime(2025, 6, 20),
          sportKey: 'soccer',
          marketKey: 'h2h',
          outcome: 'Team A',
          odds: 1.7,
        ),
        TipModel(
          eventId: 'e2',
          eventName: 'Team C – Team D',
          startTime: DateTime(2025, 6, 21),
          sportKey: 'soccer',
          marketKey: 'h2h',
          outcome: 'Team C',
          odds: 2.05,
        ),
      ];

  Future<void> _pumpDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => TicketDetailsDialog(
                        ticket: _sampleTicket(),
                        tips: _sampleTips(),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('dialog shows core fields and labels', (tester) async {
    await _pumpDialog(tester);

    final ctx = tester.element(find.byType(AlertDialog));
    final loc = AppLocalizations.of(ctx)!;

    // Title localized
    expect(find.text(loc.ticket_details_title), findsOneWidget);

    // Meta labels localized
    expect(find.textContaining(loc.ticket_stake), findsWidgets);
    expect(find.textContaining(loc.ticket_total_odd), findsWidgets);
    expect(find.textContaining(loc.ticket_potential_win), findsWidgets);
    expect(find.textContaining(loc.ticket_meta_created), findsWidgets);

    // Tips count label
    expect(find.textContaining(loc.tips_label), findsWidgets);

    // Close the dialog
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text(loc.ticket_details_title), findsNothing);
  });

  testWidgets('dialog lists tips with event name and odds', (tester) async {
    await _pumpDialog(tester);
    // Expand Pending group (sample tips default to pending)
    await tester.tap(find.textContaining('Pending tips ('));
    await tester.pumpAndSettle();

    // Event names rendered
    expect(find.text('Team A – Team B'), findsOneWidget);
    expect(find.text('Team C – Team D'), findsOneWidget);

    // Odds rendered with trailing multiplier format: x1.70, x2.05
    expect(find.textContaining('x1.70'), findsOneWidget);
    expect(find.textContaining('x2.05'), findsOneWidget);

    // Close the dialog
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });
}
