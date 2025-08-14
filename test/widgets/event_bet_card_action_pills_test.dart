import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';
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

    expect(find.text('More bets'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('AI picks'), findsOneWidget);

    await tester.tap(find.text('More bets'));
    await tester.tap(find.text('Statistics'));
    await tester.tap(find.text('AI picks'));

    expect(moreBetsTapped, isTrue);
    expect(statsTapped, isTrue);
    expect(aiTapped, isTrue);
  });
}

class _NullApi extends ApiFootballService {
  @override
  Future<H2HMarket?> getH2HForFixture(int fixtureId) async => null;
}
