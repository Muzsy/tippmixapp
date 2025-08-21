import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/odds_bookmaker.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_market.dart';
import 'package:tippmixapp/models/odds_outcome.dart';
import 'package:tippmixapp/models/h2h_market.dart';
import 'package:tippmixapp/services/api_football_service.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';

class _CountingApi extends ApiFootballService {
  int calls = 0;
  @override
  Future<OddsMarket?> getH2HForFixture(
    int fixtureId, {
    int? season,
    String? homeName,
    String? awayName,
  }) async {
    calls++;
    return H2HMarket(
      outcomes: [
        OddsOutcome(name: 'Home', price: 1.2),
        OddsOutcome(name: 'Draw', price: 3.4),
        OddsOutcome(name: 'Away', price: 5.6),
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
  testWidgets('nem hív hálózatot, ha H2H adott', (tester) async {
    final api = _CountingApi();
    final event = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Team A',
      awayTeam: 'Team B',
      commenceTime: DateTime.now(),
      bookmakers: [
        OddsBookmaker(
          key: 'demo',
          title: 'Demo',
          markets: [
            OddsMarket(
              key: 'h2h',
              outcomes: [
                OddsOutcome(name: 'Home', price: 1.0),
                OddsOutcome(name: 'Draw', price: 2.0),
                OddsOutcome(name: 'Away', price: 3.0),
              ],
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(_wrap(EventBetCard(event: event, apiService: api)));
    await tester.pump();
    expect(api.calls, 0);
    expect(find.byKey(const ValueKey('h2h-home')), findsOneWidget);
    expect(find.byKey(const ValueKey('h2h-draw')), findsOneWidget);
    expect(find.byKey(const ValueKey('h2h-away')), findsOneWidget);
  });

  testWidgets('hiányzó H2H esetén hálózatról tölt', (tester) async {
    final api = _CountingApi();
    final event = OddsEvent(
      id: '2',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Team C',
      awayTeam: 'Team D',
      commenceTime: DateTime.now(),
      bookmakers: const [],
    );
    await tester.pumpWidget(_wrap(EventBetCard(event: event, apiService: api)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(api.calls, 1);
    expect(find.byKey(const ValueKey('h2h-home')), findsOneWidget);
    expect(find.byKey(const ValueKey('h2h-draw')), findsOneWidget);
    expect(find.byKey(const ValueKey('h2h-away')), findsOneWidget);
  });
}
