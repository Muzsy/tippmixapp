import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/ticket_model.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/screens/my_tickets_screen.dart';
import 'package:tipsterino/screens/home_screen.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/services/auth_service.dart';

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
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async => true;
  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User? user) : super(FakeAuthService()) {
    state = AuthState(user: user);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Drawer: navigate to MyTickets for logged-in user', (tester) async {
    final testRouter = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeScreen(state: state, child: child),
          routes: [
            GoRoute(
              path: '/',
              name: AppRoute.home.name,
              pageBuilder: (context, state) => const NoTransitionPage(child: SizedBox.shrink()),
            ),
            GoRoute(
              path: '/my-tickets',
              name: AppRoute.myTickets.name,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MyTicketsScreen(showAppBar: false),
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            (ref) => FakeAuthNotifier(User(id: 'u1', email: 'e', displayName: 'Me')),
          ),
          ticketsProvider.overrideWith((ref) => Stream.value(const <Ticket>[])),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: testRouter,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open the drawer via the AppBar menu button (tooltip is localized)
    // Tap the AppBar menu icon to open the drawer
    final menuButton = find.descendant(
      of: find.byType(AppBar),
      matching: find.byIcon(Icons.menu),
    );
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Tap on "My Tickets" in drawer (EN locale default)
    expect(find.text('My Tickets'), findsOneWidget);
    await tester.tap(find.text('My Tickets'));
    await tester.pumpAndSettle();

    expect(find.byType(MyTicketsScreen), findsOneWidget);
  });
}
