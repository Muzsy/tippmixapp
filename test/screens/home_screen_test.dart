import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/models/user_stats_model.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/stats_provider.dart';
import 'package:tippmixapp/screens/home_screen.dart'
    show
        HomeScreen,
        dailyBonusAvailableProvider,
        latestBadgeProvider,
        aiTipFutureProvider,
        activeChallengesProvider,
        latestFeedActivityProvider;
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/widgets/home/user_stats_header.dart';

/// Simplest possible stub that fulfils every member of [AuthService]
/// without touching Firebase during widget tests.
class FakeAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _current;

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  User? get currentUser => _current;

  @override
  Future<User?> registerWithEmail(String email, String password) async => null;

  @override
  Future<User?> signInWithEmail(String email, String password) async => null;

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
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;
}

void main() {
  const tipsJson = '{"tips": [{"id":"t1","en":"tip"}]}';

  setUp(() {
    // Mock the educational_tips.json asset so AssetBundle does not throw.
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

  testWidgets('HomeScreen shows header and Daily Bonus tile', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              HomeScreen(state: state, showStats: true, child: child),
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
          // 1️⃣ Enable Daily Bonus tile
          dailyBonusAvailableProvider.overrideWith((ref) => true),

          // 2️⃣ Provide ready‑made statistics so UserStatsHeader renders immediately
          userStatsProvider.overrideWith((ref) async => UserStatsModel(
                uid: 'u1',
                displayName: 'Test',
                coins: 100,
                totalBets: 10,
                totalWins: 5,
                winRate: 0.5,
              )),

          // 3️⃣ Disable real Firebase usage
          authServiceProvider.overrideWith((ref) => FakeAuthService()),
          authProvider.overrideWith((ref) => AuthNotifier(FakeAuthService())),

          // 4️⃣ Stub out other async tiles we do not assert on
          aiTipFutureProvider.overrideWith((ref) async => null),
          latestBadgeProvider.overrideWith((ref) async => null),
          activeChallengesProvider.overrideWith((ref) => []),
          latestFeedActivityProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    // Await async providers so the UI can settle.
    await tester.pumpAndSettle();

    // ✅ Assertions
    expect(find.byType(UserStatsHeader), findsOneWidget);
    expect(find.text('Daily Bonus'), findsOneWidget);
  });
}
