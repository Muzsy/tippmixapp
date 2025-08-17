import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_outcome.dart';
import 'package:tippmixapp/models/h2h_market.dart';
import 'package:tippmixapp/services/api_football_service.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';

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
        OddsOutcome(name: 'Liverpool', price: 1.72),
        OddsOutcome(name: 'Draw', price: 4.00),
        OddsOutcome(name: 'Tottenham', price: 4.50),
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
  testWidgets('EventBetCard renders and buttons work', (tester) async {
    final event = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Liverpool',
      awayTeam: 'Tottenham',
      commenceTime: DateTime.now().add(const Duration(minutes: 5)),
      bookmakers: const [],
    );

    bool tapped = false;
    await tester.pumpWidget(
      _wrap(
        EventBetCard(
          event: event,
          apiService: _FakeApi(),
          onTapHome: (_) => tapped = true,
          onTapDraw: (_) {},
          onTapAway: (_) {},
          onMoreBets: () {},
          onStats: () {},
          onAi: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Liverpool'), findsOneWidget);
    expect(find.text('Tottenham'), findsOneWidget);
    await tester.tap(find.text('1'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
