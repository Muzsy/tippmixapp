import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('Megjelenik az Ország • Liga fejléc', (tester) async {
    final e = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Tottenham',
      awayTeam: 'Arsenal',
      countryName: 'England',
      leagueName: 'Premier League',
      commenceTime: DateTime.now(),
      bookmakers: const [],
    );
    await tester.pumpWidget(_wrap(EventBetCard(event: e, h2hMarket: null)));
    expect(find.textContaining('England'), findsOneWidget);
    expect(find.textContaining('Premier League'), findsOneWidget);
  });

  testWidgets('TeamBadge monogram fallback működik', (tester) async {
    final e = OddsEvent(
      id: '2',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Real Soacha',
      awayTeam: 'Deportes Tolima',
      commenceTime: DateTime.now(),
      bookmakers: const [],
    );
    await tester.pumpWidget(_wrap(EventBetCard(event: e, h2hMarket: null)));
    expect(find.text('RS'), findsOneWidget);
    expect(find.text('DT'), findsOneWidget);
  });
}
