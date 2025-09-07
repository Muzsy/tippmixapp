import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/odds_event.dart';
import 'package:tipsterino/widgets/event_bet_card.dart';
import 'package:tipsterino/services/api_football_service.dart';
import 'package:tipsterino/models/h2h_market.dart';

class _NullApi extends ApiFootballService {
  @override
  Future<H2HMarket?> getH2HForFixture(
    int fixtureId, {
    int? season,
    String? homeName,
    String? awayName,
  }) async => null;
}

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
    await tester.pumpWidget(
      _wrap(EventBetCard(event: e, apiService: _NullApi())),
    );
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
    await tester.pumpWidget(
      _wrap(EventBetCard(event: e, apiService: _NullApi())),
    );
    expect(find.text('RS'), findsOneWidget);
    expect(find.text('DT'), findsOneWidget);
  });
}
