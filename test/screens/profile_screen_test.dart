import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/screens/badges/badge_screen.dart';
import 'package:tippmixapp/screens/profile_screen.dart';
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
  Future<bool> pollEmailVerification({Duration timeout = const Duration(minutes: 3), Duration interval = const Duration(seconds: 5),}) async => true;
  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User? user) : super(FakeAuthService()) {
    state = AuthState(user: user);
  }
}

Widget _buildApp({required Override auth}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.profile.name,
        builder: (context, state) => const ProfileScreen(showAppBar: false),
      ),
      GoRoute(
        path: '/badges',
        name: AppRoute.badges.name,
        builder: (context, state) => const BadgeScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [auth],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('en'), Locale('hu'), Locale('de')],
      locale: const Locale('en'),
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('shows not logged in text when user is null', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        auth: authProvider.overrideWith((ref) => FakeAuthNotifier(null)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Not logged in'), findsOneWidget);
  });

  testWidgets('shows user info and navigates to badges', (tester) async {
    final user = User(
      id: 'u1',
      email: 'user@example.com',
      displayName: 'Tester',
    );
    await tester.pumpWidget(
      _buildApp(
        auth: authProvider.overrideWith((ref) => FakeAuthNotifier(user)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining(user.email), findsOneWidget);
    expect(find.textContaining(user.displayName), findsOneWidget);

    await tester.tap(find.text('Badges'));
    await tester.pumpAndSettle();

    expect(find.byType(BadgeScreen), findsOneWidget);
  });

  testWidgets('shows global privacy toggle', (tester) async {
    final user = User(id: 'u1', email: 'e@x.com', displayName: 'Tester');
    await tester.pumpWidget(
      _buildApp(
        auth: authProvider.overrideWith((ref) => FakeAuthNotifier(user)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Global privacy switch'), findsOneWidget);

    expect(find.byType(SwitchListTile), findsNWidgets(6));
  });

  testWidgets('field privacy toggle updates state', (tester) async {
    final user = User(id: 'u1', email: 'e@x.com', displayName: 'Tester');
    await tester.pumpWidget(
      _buildApp(
        auth: authProvider.overrideWith((ref) => FakeAuthNotifier(user)),
      ),
    );
    await tester.pumpAndSettle();

    final tile = find.widgetWithText(SwitchListTile, 'City');
    expect(tile, findsOneWidget);
    final SwitchListTile before = tester.widget(tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    final SwitchListTile after = tester.widget(tile);
    expect(before.value, isTrue);
    expect(after.value, isFalse);
  });
}
