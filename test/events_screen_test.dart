import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_bookmaker.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_market.dart';
import 'package:tippmixapp/models/odds_outcome.dart';
import 'package:tippmixapp/providers/odds_api_provider.dart';
import 'package:tippmixapp/providers/bet_slip_provider.dart';
import 'package:tippmixapp/models/tip_model.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/services/api_football_service.dart';
import 'package:tippmixapp/services/odds_cache_wrapper.dart';
import 'package:tippmixapp/models/h2h_market.dart';
import 'package:go_router/go_router.dart';

class _StubApiFootballService extends ApiFootballService {
  @override
  Future<H2HMarket?> getH2HForFixture(int fixtureId, {int? season}) async =>
      null;
}

class TestOddsApiProvider extends OddsApiProvider {
  bool fetchCalled = false;
  TestOddsApiProvider(OddsApiProviderState initialState)
    : super(OddsCacheWrapper(_StubApiFootballService())) {
    state = initialState;
  }

  @override
  Future<void> fetchOdds({
    required String sport,
    DateTime? date,
    String? country,
    String? league,
  }) async {
    fetchCalled = true;
  }
}

class _FakeBetSlipProvider extends BetSlipProvider {
  _FakeBetSlipProvider({required List<TipModel> initialTips}) : super() {
    state = BetSlipProviderState(tips: initialTips);
  }
}

void main() {
  testWidgets('EventsScreen displays events and triggers refresh', (
    WidgetTester tester,
  ) async {
    final event = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Team A',
      awayTeam: 'Team B',
      commenceTime: DateTime.now().add(const Duration(hours: 1)),
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
            ),
          ],
        ),
      ],
    );

    final provider = TestOddsApiProvider(OddsApiData([event]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [oddsApiProvider.overrideWith((ref) => provider)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: EventsScreen(sportKey: 'soccer'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Team A'), findsOneWidget);
    expect(find.text('Team B'), findsOneWidget);

    await tester.tap(find.byKey(const Key('refresh_button')));
    await tester.pump();

    expect(provider.fetchCalled, isTrue);
  });

  testWidgets('create ticket button hidden when no tips', (tester) async {
    final provider = TestOddsApiProvider(OddsApiData([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          oddsApiProvider.overrideWith((ref) => provider),
          betSlipProvider.overrideWith(
            (ref) => _FakeBetSlipProvider(initialTips: []),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: EventsScreen(sportKey: 'soccer'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('create_ticket_button')), findsNothing);
  });

  testWidgets('tapping create ticket navigates to screen when tips exist', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const EventsScreen(sportKey: 'soccer'),
        ),
        GoRoute(
          path: '/create-ticket',
          builder: (context, state) => const Scaffold(body: Text('create')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          oddsApiProvider.overrideWith(
            (ref) => TestOddsApiProvider(OddsApiData([])),
          ),
          betSlipProvider.overrideWith(
            (ref) => _FakeBetSlipProvider(
              initialTips: [
                TipModel(
                  eventId: 'e1',
                  eventName: 'e',
                  startTime: DateTime.now(),
                  sportKey: 'soccer',
                  bookmaker: 'b',
                  marketKey: 'h2h',
                  outcome: 'o',
                  odds: 2.0,
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('create_ticket_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('create_ticket_button')));
    await tester.pumpAndSettle();

    expect(find.text('create'), findsOneWidget);
  });
}
