import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_drift.dart';
import 'package:tippmixapp/widgets/odds_drift_dialog.dart';

void main() {
  final result = OddsDriftResult([
    DriftItem(
      fixtureId: '1',
      market: '1X2',
      selection: 'HOME',
      oldOdds: 1.90,
      newOdds: 2.00,
    ),
  ]);

  Future<Future<bool>> openDialog(
    WidgetTester tester,
    String buttonLabel,
  ) async {
    final completer = Completer<bool>();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('hu'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                final res = await showOddsDriftDialog(context, result);
                completer.complete(res);
              },
              child: Text(buttonLabel),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text(buttonLabel));
    await tester.pumpAndSettle();
    return completer.future;
  }

  testWidgets('returns false when cancelled', (tester) async {
    final future = await openDialog(tester, 'open');
    expect(find.text('Odds megváltozott'), findsOneWidget);
    await tester.tap(find.text('Mégse'));
    await tester.pumpAndSettle();
    expect(await future, isFalse);
  });

  testWidgets('returns true when accepted', (tester) async {
    final future = await openDialog(tester, 'open2');
    expect(find.text('Odds megváltozott'), findsOneWidget);
    await tester.tap(find.text('Elfogad'));
    await tester.pumpAndSettle();
    expect(await future, isTrue);
  });
}
