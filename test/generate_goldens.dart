import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:tippmixapp/theme/theme_builder.dart';
import 'package:tippmixapp/theme/available_themes.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/bet_slip_provider.dart';
import 'package:tippmixapp/providers/feed_provider.dart';
import 'package:tippmixapp/providers/stats_provider.dart';
import 'package:tippmixapp/providers/notification_provider.dart';
import 'package:tippmixapp/screens/home_screen.dart'
    show
        dailyBonusAvailableProvider,
        latestBadgeProvider,
        aiTipFutureProvider,
        activeChallengesProvider,
        latestFeedActivityProvider;
import 'package:tippmixapp/screens/my_tickets_screen.dart' show ticketsProvider;
import 'package:tippmixapp/screens/badges/badge_screen.dart' show userBadgesProvider;
import 'package:tippmixapp/providers/leaderboard_provider.dart'
    show topTipsterProvider;
import 'package:tippmixapp/services/reward_service.dart'
    show RewardService, rewardServiceProvider;
import 'package:tippmixapp/providers/odds_api_provider.dart'
    show oddsApiProvider, OddsApiProvider;
import 'package:tippmixapp/services/odds_cache_wrapper.dart';
import 'package:tippmixapp/services/odds_api_service.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/router.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'dart:io';

class _FakeAuthService implements AuthService {
  @override
  Stream<User?> authStateChanges() => const Stream.empty();
  @override
  User? get currentUser => null;
  @override
  Future<User?> signInWithEmail(String email, String password) async => null;
  @override
  Future<User?> registerWithEmail(String email, String password) async => null;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  bool get isEmailVerified => true;
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(User? user) : super(_FakeAuthService()) {
    state = AuthState(user: user);
  }
}

class _FakeBetSlipProvider extends BetSlipProvider {
  _FakeBetSlipProvider() : super();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  final user = User(id: 'u1', email: 'demo@demo.com', displayName: 'Demo');

  final routes = <String, AppRoute>{
    'home': AppRoute.home,
    'profile': AppRoute.profile,
    'bets': AppRoute.bets,
    'my_tickets': AppRoute.myTickets,
    'leaderboard': AppRoute.leaderboard,
    'settings': AppRoute.settings,
    'login': AppRoute.login,
    'create_ticket': AppRoute.createTicket,
    'badges': AppRoute.badges,
    'rewards': AppRoute.rewards,
    'feed': AppRoute.feed,
    'notifications': AppRoute.notifications,
  };

  final overrides = <Override>[
    authServiceProvider.overrideWith((ref) => _FakeAuthService()),
    authProvider.overrideWith((ref) => _FakeAuthNotifier(user)),
    feedStreamProvider.overrideWith((ref) => Stream.value(const [])),
    leaderboardStreamProvider.overrideWith((ref) => Stream.value(const [])),
    userStatsProvider.overrideWith((ref) async => null),
    dailyBonusAvailableProvider.overrideWith((ref) => false),
    latestBadgeProvider.overrideWith((ref) async => null),
    aiTipFutureProvider.overrideWith((ref) async => null),
    activeChallengesProvider.overrideWith((ref) async => []),
    latestFeedActivityProvider.overrideWith((ref) async => null),
    topTipsterProvider.overrideWith((ref) async => null),
    notificationStreamProvider.overrideWith((ref) => Stream.value(const [])),
    rewardServiceProvider.overrideWith((ref) => RewardService()),
    userBadgesProvider.overrideWith((ref) => Stream.value(const [])),
    ticketsProvider.overrideWith((ref) => Stream.value(const [])),
    betSlipProvider.overrideWith((ref) => _FakeBetSlipProvider()),
    oddsApiProvider.overrideWith(
      (ref) => OddsApiProvider(OddsCacheWrapper(OddsApiService())),
    ),
  ];

  for (final scheme in availableThemes) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      for (final entry in routes.entries) {
        final label = entry.key;
        final route = entry.value;
        final suffix = brightness == Brightness.light ? 'light' : 'dark';
        final fileName = 'goldens/${label}_skin${scheme.index}_$suffix.png';
        // final skip = !File('test/$fileName').existsSync();
        testWidgets('$label skin${scheme.index} $suffix', (tester) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: overrides,
              child: MaterialApp.router(
                routerConfig: router,
                theme: buildTheme(scheme: scheme, brightness: Brightness.light),
                darkTheme: buildTheme(
                  scheme: scheme,
                  brightness: Brightness.dark,
                ),
                themeMode: brightness == Brightness.dark
                    ? ThemeMode.dark
                    : ThemeMode.light,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: const Locale('en'),
              ),
            ),
          );
          router.goNamed(route.name);
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(fileName),
          );
        });
      }
    }
  }
}