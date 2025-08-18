import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';
import 'package:tippmixapp/widgets/action_pill.dart';
import 'package:tippmixapp/services/api_football_service.dart';
import 'package:tippmixapp/models/h2h_market.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('renders three ActionPills and taps trigger callbacks', (
    tester,
  ) async {
    final event = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Home',
      awayTeam: 'Away',
      commenceTime: DateTime.now(),
      bookmakers: const [],
    );

    var moreBetsTapped = false;
    var statsTapped = false;
    var aiTapped = false;

    await tester.pumpWidget(
      _wrap(
        EventBetCard(
          event: event,
          apiService: _NullApi(),
          onMoreBets: () => moreBetsTapped = true,
          onStats: () => statsTapped = true,
          onAi: () => aiTapped = true,
        ),
      ),
    );

    final moreFinder = find.widgetWithText(ActionPill, 'More bets');
    final statsFinder = find.widgetWithText(ActionPill, 'Statistics');
    final aiFinder = find.widgetWithText(ActionPill, 'AI picks');

    expect(moreFinder, findsOneWidget);
    expect(statsFinder, findsOneWidget);
    expect(aiFinder, findsOneWidget);

    final moreSize = tester.getSize(moreFinder);
    final statsSize = tester.getSize(statsFinder);
    final aiSize = tester.getSize(aiFinder);

    expect(moreSize.width, greaterThan(statsSize.width));
    expect(statsSize.width, closeTo(aiSize.width, 0.1));

    await tester.tap(moreFinder);
    await tester.tap(statsFinder);
    await tester.tap(aiFinder);

    expect(moreBetsTapped, isTrue);
    expect(statsTapped, isTrue);
    expect(aiTapped, isTrue);
  });
}

class _NullApi extends ApiFootballService {
  @override
  Future<H2HMarket?> getH2HForFixture(
    int fixtureId, {
    int? season,
    String? homeName,
    String? awayName,
  }) async => null;
}
