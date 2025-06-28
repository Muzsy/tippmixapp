import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_bookmaker.dart';
import 'package:tippmixapp/models/odds_market.dart';
import 'package:tippmixapp/models/odds_outcome.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/feed_provider.dart';
import 'package:tippmixapp/providers/odds_api_provider.dart';
import 'package:tippmixapp/services/odds_api_service.dart';
import 'package:tippmixapp/services/odds_cache_wrapper.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/screens/home_screen.dart';
import 'package:tippmixapp/services/auth_service.dart';

class FakeAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _current;

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<User?> signInWithEmail(String email, String password) async => null;

  @override
  Future<User?> registerWithEmail(String email, String password) async => null;

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  User? get currentUser => _current;
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User? user) : super(FakeAuthService()) {
    state = AuthState(user: user);
  }
}

class TestOddsApiProvider extends OddsApiProvider {
  TestOddsApiProvider(OddsApiProviderState state)
      : super(OddsCacheWrapper(OddsApiService())) {
    this.state = state;
  }

  @override
  Future<void> fetchOdds({required String sport}) async {}
}

void main() {
  testWidgets('navigate to Feed via bottom nav and drawer', (tester) async {
    final router = GoRouter(
      initialLocation: '/feed',
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeScreen(child: child, state: state),
          routes: [
            GoRoute(
              path: '/',
              name: AppRoute.home.name,
              builder: (context, state) => const EventsScreen(sportKey: 'soccer'),
            ),
            GoRoute(
              path: '/feed',
              name: AppRoute.feed.name,
              builder: (context, state) => const EventsScreen(sportKey: 'soccer'),
            ),
          ],
        ),
      ],
    );

    final event = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'A',
      awayTeam: 'B',
      commenceTime: DateTime.now(),
      bookmakers: [
        OddsBookmaker(
          key: 'b',
          title: 'Bookie',
          markets: [
            OddsMarket(
              key: 'h2h',
              outcomes: [
                OddsOutcome(name: 'A', price: 1.5),
                OddsOutcome(name: 'B', price: 2.5),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedStreamProvider.overrideWith((ref) => Stream.value(const [])),
          authProvider.overrideWith((ref) => FakeAuthNotifier(null)),
          oddsApiProvider.overrideWith(
            (ref) => TestOddsApiProvider(OddsApiData([event])),
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
    expect(find.byType(EventsScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dynamic_feed));
    await tester.pumpAndSettle();
    expect(find.byType(EventsScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.byType(EventsScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Feed'));
    await tester.pumpAndSettle();
    expect(find.byType(EventsScreen), findsOneWidget);
  });
}
