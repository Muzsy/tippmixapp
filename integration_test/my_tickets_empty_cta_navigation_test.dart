import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/ticket_model.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/screens/my_tickets_screen.dart';

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

  testWidgets('Empty tickets CTA navigates to bets route', (tester) async {
    final router = GoRouter(
      initialLocation: '/my-tickets',
      routes: [
        GoRoute(
          path: '/my-tickets',
          name: AppRoute.myTickets.name,
          builder: (context, state) => const MyTicketsScreen(showAppBar: false),
        ),
        GoRoute(
          path: '/bets',
          name: AppRoute.bets.name,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('bets_screen_marker')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            (ref) => FakeAuthNotifier(
              User(id: 'u1', email: 'e', displayName: 'Me'),
            ),
          ),
          ticketsProvider.overrideWith(
            (ref) => Stream.value(const <Ticket>[]),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure CTA is visible
    expect(find.text('Submit Ticket'), findsOneWidget);

    // Tap CTA
    await tester.tap(find.text('Submit Ticket'));
    await tester.pumpAndSettle();

    // Arrived to bets route
    expect(find.text('bets_screen_marker'), findsOneWidget);
  });
}

