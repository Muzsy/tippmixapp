import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_bookmaker.dart';
import 'package:tippmixapp/models/odds_market.dart';
import 'package:tippmixapp/models/odds_outcome.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('EventBetCard renders and buttons work', (tester) async {
    final event = OddsEvent(
      id: 'ev1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Liverpool',
      awayTeam: 'Tottenham',
      commenceTime: DateTime.now().add(const Duration(minutes: 5)),
      bookmakers: [
        OddsBookmaker(
          key: 'test',
          title: 'Test',
          markets: [
            OddsMarket(
              key: 'h2h',
              outcomes: [
                OddsOutcome(name: 'Liverpool', price: 1.72),
                OddsOutcome(name: 'Draw', price: 4.00),
                OddsOutcome(name: 'Tottenham', price: 4.50),
              ],
            ),
          ],
        ),
      ],
    );

    bool tapped = false;
    await tester.pumpWidget(
      _wrap(
        EventBetCard(
          event: event,
          h2hMarket: event.bookmakers.first.markets.first,
          onTapHome: (_) => tapped = true,
          onTapDraw: (_) {},
          onTapAway: (_) {},
          onMoreBets: () {},
          onStats: () {},
          onAi: () {},
        ),
      ),
    );

    expect(find.text('Liverpool'), findsOneWidget);
    expect(find.text('Tottenham'), findsOneWidget);
    expect(find.text('1.72'), findsOneWidget);
    expect(find.text('4.00'), findsOneWidget);
    expect(find.text('4.50'), findsOneWidget);

    await tester.tap(find.text('Liverpool'));
    await tester.pump();
    // a label-tap önmagában nem elég – a gombon belül bárhova tapolunk
    await tester.tap(find.byType(ElevatedButton).first);
    expect(tapped, isTrue);
  });
}
