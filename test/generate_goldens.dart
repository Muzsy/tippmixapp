import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tippmixapp/theme/theme_builder.dart';
import 'package:tippmixapp/theme/available_themes.dart';
import 'package:tippmixapp/services/theme_service.dart';
import 'mock_theme_service.dart';
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
        HomeScreen,
        dailyBonusAvailableProvider,
        latestBadgeProvider,
        aiTipFutureProvider,
        activeChallengesProvider,
        latestFeedActivityProvider;
import 'package:tippmixapp/screens/my_tickets_screen.dart'
    show MyTicketsScreen, ticketsProvider;
import 'package:tippmixapp/screens/badges/badge_screen.dart'
    show BadgeScreen, userBadgesProvider;
import 'package:tippmixapp/screens/profile_screen.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/screens/leaderboard/leaderboard_screen.dart';
import 'package:tippmixapp/screens/settings/settings_screen.dart';
import 'package:tippmixapp/screens/rewards/rewards_screen.dart';
import 'package:tippmixapp/screens/create_ticket_screen.dart';
import 'package:tippmixapp/screens/feed_screen.dart';
import 'package:tippmixapp/screens/notifications/notification_center_screen.dart';
import 'package:tippmixapp/providers/leaderboard_provider.dart'
    show topTipsterProvider;
import 'package:tippmixapp/services/reward_service.dart'
    show RewardService, rewardServiceProvider;
import 'package:tippmixapp/providers/odds_api_provider.dart'
    show oddsApiProvider, OddsApiProvider;
import 'package:tippmixapp/services/odds_cache_wrapper.dart';
import 'package:tippmixapp/services/odds_api_service.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/routes/app_route.dart';

class _FakeAuthService implements AuthService {
  @override
  Stream<User?> authStateChanges() => const Stream.empty();
  @override
  User? get currentUser => null;
  Future<bool> validateEmailUnique(String email) async => true;
  Future<bool> validateNicknameUnique(String nickname) async => true;
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

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(User? user) : super(_FakeAuthService()) {
    state = AuthState(user: user);
  }
}

class _FakeBetSlipProvider extends BetSlipProvider {
  _FakeBetSlipProvider() : super();
}

GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            HomeScreen(state: state, child: child),
        routes: [
          GoRoute(
            path: '/create-ticket',
            name: AppRoute.createTicket.name,
            builder: (context, state) => const CreateTicketScreen(),
          ),
          GoRoute(
            path: '/',
            name: AppRoute.home.name,
            builder: (context, state) => HomeScreen(
              state: state,
              showStats: true,
              child: const SizedBox.shrink(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: AppRoute.profile.name,
            builder: (context, state) => const ProfileScreen(showAppBar: false),
          ),
          GoRoute(
            path: '/bets',
            name: AppRoute.bets.name,
            builder: (context, state) =>
                const EventsScreen(sportKey: 'soccer', showAppBar: false),
          ),
          GoRoute(
            path: '/my-tickets',
            name: AppRoute.myTickets.name,
            builder: (context, state) =>
                const MyTicketsScreen(showAppBar: false),
          ),
          GoRoute(
            name: AppRoute.feed.name,
            path: '/feed',
            builder: (context, state) => const FeedScreen(showAppBar: false),
          ),
          GoRoute(
            path: '/leaderboard',
            name: AppRoute.leaderboard.name,
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: '/badges',
            name: AppRoute.badges.name,
            builder: (context, state) => const BadgeScreen(),
          ),
          GoRoute(
            path: '/rewards',
            name: AppRoute.rewards.name,
            builder: (context, state) => const RewardsScreen(),
          ),
          GoRoute(
            path: '/notifications',
            name: AppRoute.notifications.name,
            builder: (context, state) => const NotificationCenterScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: AppRoute.settings.name,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  final router = _buildTestRouter();

  final overrides = <Override>[
    authServiceProvider.overrideWith((ref) => _FakeAuthService()),
    authProvider.overrideWith((ref) => _FakeAuthNotifier(user)),
    themeServiceProvider.overrideWith((ref) => MockThemeService()),
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
  }}
