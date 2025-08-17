import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_market.dart';
import 'package:tippmixapp/models/odds_outcome.dart';
import 'package:tippmixapp/models/h2h_market.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/services/api_football_service.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';

class _FakeApi extends ApiFootballService {
  @override
  Future<OddsMarket?> getH2HForFixture(int fixtureId, {int? season}) async {
    return H2HMarket(outcomes: [
      OddsOutcome(name: 'Home', price: 6.00),
      OddsOutcome(name: 'Draw', price: 4.33),
      OddsOutcome(name: 'Away', price: 1.47),
    ]);
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
    expect(find.text('1 6.00'), findsOneWidget);
    expect(find.text('X 4.33'), findsOneWidget);
    expect(find.text('2 1.47'), findsOneWidget);
  });
}
