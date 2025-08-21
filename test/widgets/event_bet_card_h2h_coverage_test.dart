import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_outcome.dart';
import 'package:tippmixapp/models/h2h_market.dart';
import 'package:tippmixapp/services/api_football_service.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class _FakeApi extends ApiFootballService {
  @override
  Future<H2HMarket?> getH2HForFixture(
    int fixtureId, {
    int? season,
    String? homeName,
    String? awayName,
  }) async {
    return H2HMarket(
      outcomes: [
        OddsOutcome(name: 'Team A $fixtureId', price: 1.0),
        OddsOutcome(name: 'Draw', price: 2.0),
        OddsOutcome(name: 'Team B $fixtureId', price: 3.0),
      ],
    );
  }
}

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('Minden kártyán megjelenik a H2H gombsor', (tester) async {
    final events = List.generate(
      10,
      (i) => OddsEvent(
        id: '${i + 1}',
        sportKey: 'soccer',
        sportTitle: 'Soccer',
        homeTeam: 'Team A $i',
        awayTeam: 'Team B $i',
        commenceTime: DateTime.now(),
        bookmakers: const [],
      ),
    );
    await tester.pumpWidget(
      _wrap(
        ListView(
          children: [
            for (final e in events)
              EventBetCard(event: e, apiService: _FakeApi()),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('h2h-home')), findsWidgets);
    expect(find.byKey(const ValueKey('h2h-draw')), findsWidgets);
    expect(find.byKey(const ValueKey('h2h-away')), findsWidgets);
  });
}
