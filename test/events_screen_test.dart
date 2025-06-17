import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_bookmaker.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_market.dart';
import 'package:tippmixapp/models/odds_outcome.dart';
import 'package:tippmixapp/providers/odds_api_provider.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/services/odds_api_service.dart';

class TestOddsApiProvider extends OddsApiProvider {
  bool fetchCalled = false;
  TestOddsApiProvider(OddsApiProviderState initialState)
      : super(OddsApiService()) {
    state = initialState;
  }

  @override
  Future<void> fetchOdds({required String sport}) async {
    fetchCalled = true;
  }
}

void main() {
  testWidgets('EventsScreen displays events and triggers refresh',
      (WidgetTester tester) async {
    final event = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Team A',
      awayTeam: 'Team B',
      commenceTime: DateTime.parse('2024-01-01T12:00:00Z'),
      bookmakers: [
        OddsBookmaker(
          key: 'b',
          title: 'Bookie',
          markets: [
            OddsMarket(
              key: 'h2h',
              outcomes: [
                OddsOutcome(name: 'Team A', price: 1.5),
                OddsOutcome(name: 'Team B', price: 2.5),
              ],
            )
          ],
        ),
      ],
    );

    final provider = TestOddsApiProvider(OddsApiData([event]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          oddsApiProvider.overrideWith((ref) => provider),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const EventsScreen(sportKey: 'soccer'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Team A – Team B'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(provider.fetchCalled, isTrue);
  });
}
