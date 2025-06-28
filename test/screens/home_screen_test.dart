import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/models/user_stats_model.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/providers/stats_provider.dart';
import 'package:tippmixapp/screens/home_screen.dart'
    show
        HomeScreen,
        dailyBonusAvailableProvider,
        latestBadgeProvider,
        aiTipFutureProvider,
        activeChallengesProvider,
        latestFeedActivityProvider;
import 'package:tippmixapp/providers/leaderboard_provider.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/widgets/home/user_stats_header.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/routes/app_route.dart';

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

void main() {
  const tipsJson = '{"tips": [{"id":"t1","en":"tip"}]}';

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (key == 'lib/assets/educational_tips.json') {
        return ByteData.view(Uint8List.fromList(utf8.encode(tipsJson)).buffer);
      }
      return null;
    });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('HomeScreen shows tiles based on providers', (tester) async {
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
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyBonusAvailableProvider.overrideWith(
            (ref) => true,
          ),
          latestBadgeProvider.overrideWith((ref) => Future.value(null)),
          leaderboardStreamProvider.overrideWith(
            (ref) => Stream.value([
              UserStatsModel(
                uid: 'u1',
                displayName: 'Me',
                coins: 100,
                totalBets: 2,
                totalWins: 1,
                winRate: 0.5,
              ),
            ]),
          ),
          aiTipFutureProvider.overrideWith((ref) => Future.value(null)),
          topTipsterProvider.overrideWith((ref) => Future.value(null)),
          activeChallengesProvider.overrideWith((ref) => Future.value([])),
          latestFeedActivityProvider.overrideWith((ref) => Future.value(null)),
          authProvider.overrideWith(
            (ref) => FakeAuthNotifier(User(id: 'u1', email: '', displayName: 'Me')),
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

    expect(find.byType(UserStatsHeader), findsOneWidget);
    expect(find.text('Daily Bonus'), findsOneWidget);
    expect(find.text('Badge Earned'), findsNothing);
  });
}
