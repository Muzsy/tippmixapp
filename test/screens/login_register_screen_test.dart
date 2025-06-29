import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/screens/login_register_screen.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/providers/auth_provider.dart';

// ------------------------------------------------------------
// LoginRegisterScreen – végleges widget-teszt (Sprint5 / T03)
// ------------------------------------------------------------
// Megoldja a „No GoRouter found in context” hibát úgy, hogy
// MaterialApp.router-t és egy minimális GoRouter-t ad a widget
// alá. A FakeAuthNotifier segítségével ellenőrizzük, hogy a
// login() és register() hívások megtörténnek.
// ------------------------------------------------------------

// -------------------------
// 1. Fake implementációk
// -------------------------
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
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier() : super(_FakeAuthService());

  bool loginCalled = false;
  bool registerCalled = false;

  @override
  Future<String?> login(String email, String password) async {
    loginCalled = true;
    state = AuthState(user: User(id: 'u', email: email, displayName: 'Demo'));
    return null;
  }

  @override
  Future<String?> register(String email, String password) async {
    registerCalled = true;
    state = AuthState(user: User(id: 'u', email: email, displayName: 'Demo'));
    return null;
  }
}

// -------------------------
// 2. Segédfüggvény a pump-hoz
// -------------------------
Widget _buildTestApp({required _FakeAuthNotifier fakeAuth}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
        GoRoute(
          path: '/',
          name: 'login',
          builder: (context, state) => const LoginRegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const SizedBox.shrink(),
        ),
    ],
  );

  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) => fakeAuth),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('hu')],
    ),
  );
}

// -------------------------
// 3. Tesztesetek
// -------------------------
void main() {
  group('LoginRegisterScreen', () {
    late _FakeAuthNotifier fakeAuth;

    setUp(() {
      fakeAuth = _FakeAuthNotifier();
    });

    testWidgets('Alapértelmezett nézet – Login mód', (tester) async {
      await tester.pumpWidget(_buildTestApp(fakeAuth: fakeAuth));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ChoiceChip, 'Login'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Register'), findsOneWidget);
      expect(find.text('Confirm Password'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('Átváltás Register módba megjeleníti a Confirm Password mezőt', (tester) async {
      await tester.pumpWidget(_buildTestApp(fakeAuth: fakeAuth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    });

    testWidgets('Login gomb meghívja fakeAuth.login-t', (tester) async {
      await tester.pumpWidget(_buildTestApp(fakeAuth: fakeAuth));
      await tester.pumpAndSettle();

      // Mezők kitöltése
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'user@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'secret');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(fakeAuth.loginCalled, isTrue);
      expect(fakeAuth.registerCalled, isFalse);
    });
  });
}