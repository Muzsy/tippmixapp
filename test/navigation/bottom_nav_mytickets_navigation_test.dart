import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/screens/home_screen.dart'
    show
        HomeScreen,
        dailyBonusAvailableProvider,
        latestBadgeProvider,
        aiTipFutureProvider,
        activeChallengesProvider,
        latestFeedActivityProvider;
import 'package:tippmixapp/screens/my_tickets_screen.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/providers/auth_provider.dart'
    show authProvider, authServiceProvider, AuthNotifier;
import 'package:tippmixapp/models/ticket_model.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/providers/stats_provider.dart';

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
  Future<bool> validateEmailUnique(String email) async => true;
  Future<bool> validateNicknameUnique(String nickname) async => true;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User? user) : super(FakeAuthService()) {
    state = AuthState(user: user);
  }
}

void main() {
  testWidgets('navigate to MyTickets via bottom nav', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
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
              path: '/my-tickets',
              name: AppRoute.myTickets.name,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const MyTicketsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
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
          ticketsProvider.overrideWith((ref) => Stream.value(const <Ticket>[])),
          authServiceProvider.overrideWith((ref) => FakeAuthService()),
          authProvider.overrideWith((ref) => FakeAuthNotifier(null)),
          dailyBonusAvailableProvider.overrideWith((ref) => false),
          userStatsProvider.overrideWith((ref) async => null),
          aiTipFutureProvider.overrideWith((ref) async => null),
          latestBadgeProvider.overrideWith((ref) async => null),
          activeChallengesProvider.overrideWith((ref) => []),
          latestFeedActivityProvider.overrideWith((ref) async => null),
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

    await tester.tap(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();

    expect(find.byType(MyTicketsScreen), findsOneWidget);
    expect(find.text('My Tickets'), findsOneWidget);
  });
}
