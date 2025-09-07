import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/odds_drift.dart';
import 'package:tipsterino/widgets/odds_drift_dialog.dart';

Widget _wrap(Widget child, Locale locale) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Builder(builder: (ctx) => Center(child: child)),
  ),
);

void main() {
  testWidgets('HU labels and semantics present', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox.shrink(), const Locale('hu')));
    unawaited(
      showOddsDriftDialog(
        tester.element(find.byType(SizedBox)),
        // üres változáslista is elég a cím és gombok teszteléséhez
        OddsDriftResult(const []),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Odds megváltozott'), findsOneWidget);
    expect(find.text('Mégse'), findsOneWidget);
    expect(find.text('Elfogad'), findsOneWidget);
  });
  testWidgets('EN labels present', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox.shrink(), const Locale('en')));
    unawaited(
      showOddsDriftDialog(
        tester.element(find.byType(SizedBox)),
        OddsDriftResult(const []),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Odds changed'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
  });
}
