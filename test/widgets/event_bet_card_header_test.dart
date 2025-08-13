import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';

void main() {
  Widget wrap(EventBetCard card) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: card),
    );
  }

  testWidgets('falls back to sport title when no league info', (tester) async {
    final event = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'A',
      awayTeam: 'B',
      commenceTime: DateTime.now(),
      bookmakers: const [],
    );
    await tester.pumpWidget(wrap(EventBetCard(event: event, h2hMarket: null)));
    expect(find.text('Soccer'), findsOneWidget);
  });

  testWidgets('shows country and league when available', (tester) async {
    final event = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'A',
      awayTeam: 'B',
      commenceTime: DateTime.now(),
      bookmakers: const [],
      countryName: 'England',
      leagueName: 'Premier League',
    );
    await tester.pumpWidget(wrap(EventBetCard(event: event, h2hMarket: null)));
    expect(find.text('England • Premier League'), findsOneWidget);
    expect(find.text('Soccer'), findsNothing);
  });
}
