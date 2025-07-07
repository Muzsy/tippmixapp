import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        HomeScreen,
        dailyBonusAvailableProvider,
        latestBadgeProvider,
        aiTipFutureProvider,
        activeChallengesProvider,
        latestFeedActivityProvider;
import 'package:tippmixapp/screens/profile_screen.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/screens/my_tickets_screen.dart'
    show MyTicketsScreen, ticketsProvider;
import 'package:tippmixapp/screens/leaderboard/leaderboard_screen.dart';
import 'package:tippmixapp/screens/settings/settings_screen.dart';
import 'package:tippmixapp/screens/login_register_screen.dart';
import 'package:tippmixapp/screens/create_ticket_screen.dart';
import 'package:tippmixapp/screens/badges/badge_screen.dart'
    show BadgeScreen, userBadgesProvider;
import 'package:tippmixapp/screens/rewards/rewards_screen.dart';
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

  final user = User(id: 'u1', email: 'demo@demo.com', displayName: 'Demo');

  final screens = <String, Widget>{
    'home': const HomeScreen(showStats: true),
    'profile': const ProfileScreen(showAppBar: false),
    'bets': const EventsScreen(sportKey: 'soccer', showAppBar: false),
    'my_tickets': const MyTicketsScreen(showAppBar: false),
    'leaderboard': const LeaderboardScreen(),
    'settings': const SettingsScreen(),
    'login': const LoginRegisterScreen(),
    'create_ticket': const CreateTicketScreen(),
    'badges': const BadgeScreen(),
    'rewards': const RewardsScreen(),
    'feed': const FeedScreen(showAppBar: false),
    'notifications': const NotificationCenterScreen(),
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
      for (final entry in screens.entries) {
        final label = entry.key;
        final widget = entry.value;
        final suffix = brightness == Brightness.light ? 'light' : 'dark';
        final fileName = 'goldens/${label}_skin${scheme.index}_$suffix.png';
        // final skip = !File('test/$fileName').existsSync();
        testWidgets('$label skin${scheme.index} $suffix', (tester) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: overrides,
              child: MaterialApp(
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
                home: widget,
              ),
            ),
          );
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