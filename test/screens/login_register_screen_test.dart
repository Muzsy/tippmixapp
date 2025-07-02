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
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  bool get isEmailVerified => true;
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier() : super(_FakeAuthService());

  bool loginCalled = false;
  bool registerCalled = false;
  bool resetCalled = false;
  bool verifyCalled = false;
  String? loginErrorCode;
  String? registerErrorCode;

  @override
  Future<String?> login(String email, String password) async {
    loginCalled = true;
    if (loginErrorCode != null) {
      return loginErrorCode;
    }
    state = AuthState(user: User(id: 'u', email: email, displayName: 'Demo'));
    return null;
  }

  @override
  Future<String?> register(String email, String password) async {
    registerCalled = true;
    if (registerErrorCode != null) {
      return registerErrorCode;
    }
    state = AuthState(user: User(id: 'u', email: email, displayName: 'Demo'));
    return null;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetCalled = true;
  }

  @override
  Future<void> sendEmailVerification() async {
    verifyCalled = true;
  }
}

// -------------------------
// 2. Segédfüggvény a pump-hoz
// -------------------------
Widget _buildTestApp({required _FakeAuthNotifier fakeAuth, Locale? locale}) {
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
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
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'user@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(fakeAuth.loginCalled, isTrue);
      expect(fakeAuth.registerCalled, isFalse);
    });

    testWidgets('Register flow verification emailt küld', (tester) async {
      await tester.pumpWidget(_buildTestApp(fakeAuth: fakeAuth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'a@b.c');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'pw');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'pw');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();

      expect(fakeAuth.registerCalled, isTrue);
      expect(fakeAuth.verifyCalled, isTrue);
    });

    testWidgets('Forgot password gomb resetet küld', (tester) async {
      await tester.pumpWidget(_buildTestApp(fakeAuth: fakeAuth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'reset@test.com');

      await tester.tap(find.widgetWithText(TextButton, 'Send').last);
      await tester.pumpAndSettle();

      expect(fakeAuth.resetCalled, isTrue);
    });

    testWidgets('Welcome text lokalizált minden nyelven', (tester) async {
      for (final locale in AppLocalizations.supportedLocales) {
        fakeAuth = _FakeAuthNotifier();
        await tester.pumpWidget(
          _buildTestApp(fakeAuth: fakeAuth, locale: locale),
        );
        await tester.pumpAndSettle();
        final loc = await AppLocalizations.delegate.load(locale);
        expect(find.text(loc.login_welcome), findsOneWidget);
      }
    });

    testWidgets('Login hibakódok lokalizálva minden nyelven', (tester) async {
      for (final locale in AppLocalizations.supportedLocales) {
        fakeAuth = _FakeAuthNotifier()..loginErrorCode = 'auth/user-not-found';
        await tester.pumpWidget(
          _buildTestApp(fakeAuth: fakeAuth, locale: locale),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'a@b.c',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          'pw',
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        final loc = await AppLocalizations.delegate.load(locale);
        expect(find.text(loc.auth_error_user_not_found), findsOneWidget);
      }
    });
  });
}