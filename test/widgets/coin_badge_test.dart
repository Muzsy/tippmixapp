import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/coin_badge.dart';

void main() {
  testWidgets('CoinBadge displays placeholder for null balance', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CoinBadge()),
      ),
    );
    expect(find.textContaining('—'), findsOneWidget);
  });

  testWidgets('CoinBadge formats large numbers', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(body: CoinBadge(balance: 12000)),
      ),
    );
    expect(find.textContaining('12K'), findsOneWidget);
  });
}
