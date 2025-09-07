import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/odds_market.dart';
import 'package:tipsterino/models/odds_outcome.dart';
import 'package:tipsterino/models/h2h_market.dart';
import 'package:tipsterino/models/odds_event.dart';
import 'package:tipsterino/services/api_football_service.dart';
import 'package:tipsterino/widgets/event_bet_card.dart';

class _FakeApi extends ApiFootballService {
  @override
  Future<OddsMarket?> getH2HForFixture(
    int fixtureId, {
    int? season,
    String? homeName,
    String? awayName,
  }) async {
    return H2HMarket(
      outcomes: [
        OddsOutcome(name: 'Home', price: 6.00),
        OddsOutcome(name: 'Draw', price: 4.33),
        OddsOutcome(name: 'Away', price: 1.47),
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
  testWidgets('H2H címkék oddsokkal', (tester) async {
    final event = OddsEvent(
      id: '123',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Team A',
      awayTeam: 'Team B',
      commenceTime: DateTime.now(),
      bookmakers: const [],
    );
    await tester.pumpWidget(
      _wrap(EventBetCard(event: event, apiService: _FakeApi())),
    );
    await tester.pump(const Duration(milliseconds: 50));
    final loc = AppLocalizations.of(tester.element(find.byType(EventBetCard)))!;

    final home = find.byKey(const ValueKey('h2h-home'));
    final draw = find.byKey(const ValueKey('h2h-draw'));
    final away = find.byKey(const ValueKey('h2h-away'));

    expect(
      find.descendant(of: home, matching: find.text(loc.home_short)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: home, matching: find.text('6.00')),
      findsOneWidget,
    );

    expect(
      find.descendant(of: draw, matching: find.text(loc.draw_short)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: draw, matching: find.text('4.33')),
      findsOneWidget,
    );

    expect(
      find.descendant(of: away, matching: find.text(loc.away_short)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: away, matching: find.text('1.47')),
      findsOneWidget,
    );
  });
}
