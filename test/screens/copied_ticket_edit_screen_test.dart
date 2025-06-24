import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/tip_model.dart';
import 'package:tippmixapp/screens/copied_ticket_edit_screen.dart';

void main() {
  testWidgets('submit button enabled after modification', (tester) async {
    final tips = [
      TipModel(
        eventId: 'e1',
        eventName: 'Match',
        startTime: DateTime(2020),
        sportKey: 'soccer',
        bookmaker: 'b',
        marketKey: 'h2h',
        outcome: 'Team',
        odds: 1.5,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: CopiedTicketEditScreen(copyId: 'c1', tips: tips),
      ),
    );

    var button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Submit ticket'));
    expect(button.onPressed, isNull);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Submit ticket'));
    expect(button.onPressed, isNotNull);
  });
}
