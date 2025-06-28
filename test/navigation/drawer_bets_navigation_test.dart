import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'dart:async';

import 'package:tippmixapp/screens/home_screen.dart'
    show
        HomeScreen,
        dailyBonusAvailableProvider,
        latestBadgeProvider,
        aiTipFutureProvider,
        activeChallengesProvider,
        latestFeedActivityProvider;
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/providers/auth_provider.dart'
    show authProvider, authServiceProvider, AuthNotifier;
import 'package:tippmixapp/providers/stats_provider.dart';
import 'package:tippmixapp/providers/odds_api_provider.dart';
import 'package:tippmixapp/services/odds_api_service.dart';
import 'package:tippmixapp/services/odds_cache_wrapper.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart';

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
  testWidgets('drawer bets item closes drawer and navigates with title', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeScreen(state: state, child: child),
          routes: [
            GoRoute(
              path: '/',
              name: AppRoute.home.name,
              builder: (context, state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: '/bets',
              name: AppRoute.bets.name,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const EventsScreen(sportKey: 'soccer'),
                transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWith((ref) => FakeAuthService()),
          authProvider.overrideWith((ref) => FakeAuthNotifier(null)),
          dailyBonusAvailableProvider.overrideWith((ref) => false),
          userStatsProvider.overrideWith((ref) async => null),
          aiTipFutureProvider.overrideWith((ref) async => null),
          latestBadgeProvider.overrideWith((ref) async => null),
          activeChallengesProvider.overrideWith((ref) => []),
          latestFeedActivityProvider.overrideWith((ref) async => null),
          oddsApiProvider.overrideWith(
            (ref) => TestOddsApiProvider(OddsApiData(const [])),
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

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Bets'));
    await tester.pumpAndSettle();

    expect(find.byType(EventsScreen), findsOneWidget);
    expect(find.text('Bets'), findsOneWidget);
    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
    expect(scaffoldState.isDrawerOpen, isFalse);
  });
}
