import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'dart:async';

import 'package:tipsterino/screens/home_screen.dart'
    show
        HomeScreen,
        dailyBonusAvailableProvider,
        latestBadgeProvider,
        aiTipFutureProvider,
        activeChallengesProvider,
        latestFeedActivityProvider;
import 'package:tipsterino/screens/events_screen.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/providers/auth_provider.dart'
    show authProvider, authServiceProvider, AuthNotifier;
import 'package:tipsterino/providers/stats_provider.dart';
import 'package:tipsterino/providers/odds_api_provider.dart';
import 'package:tipsterino/services/api_football_service.dart';
import 'package:tipsterino/services/odds_cache_wrapper.dart';
import 'package:tipsterino/services/auth_service.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';

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
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  bool get isEmailVerified => true;

  @override
  User? get currentUser => _current;
  @override
  Future<bool> validateEmailUnique(String email) async => true;
  @override
  Future<bool> validateNicknameUnique(String nickname) async => true;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;
  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}

  @override
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async => true;
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User? user) : super(FakeAuthService()) {
    state = AuthState(user: user);
  }
}

class TestOddsApiProvider extends OddsApiProvider {
  TestOddsApiProvider(OddsApiProviderState state)
    : super(OddsCacheWrapper(ApiFootballService())) {
    this.state = state;
  }

  @override
  Future<void> fetchOdds({
    required String sport,
    DateTime? date,
    String? country,
    String? league,
  }) async {}
}

void main() {
  testWidgets('drawer bets item closes drawer and navigates with title', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              HomeScreen(state: state, child: child),
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
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              path: '/profile',
              name: AppRoute.profile.name,
              builder: (context, state) => const SizedBox.shrink(),
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
    final scaffoldState = tester.state<ScaffoldState>(
      find.byType(Scaffold).first,
    );
    expect(scaffoldState.isDrawerOpen, isFalse);
  });
}
