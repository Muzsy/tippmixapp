import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:tippmixapp/screens/auth/email_not_verified_screen.dart';
import 'package:tippmixapp/providers/onboarding_provider.dart';
import 'package:tippmixapp/router.dart'; // Make sure this imports the router object
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart' as tm;
import 'package:tippmixapp/controllers/splash_controller.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class MockUser extends Mock implements fb.User {}

class _FakeSplashController extends StateNotifier<AsyncValue<AppRoute>>
    implements SplashController {
  _FakeSplashController() : super(const AsyncLoading()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state = const AsyncData(AppRoute.home);
    });
  }
}

class FakeAuthService implements AuthService {
  final _controller = StreamController<tm.User?>.broadcast();
  tm.User? _current;

  @override
  Stream<tm.User?> authStateChanges() => _controller.stream;

  @override
  tm.User? get currentUser => _current;

  @override
  Future<bool> validateEmailUnique(String email) async => true;

  @override
  Future<bool> validateNicknameUnique(String nickname) async => true;

  @override
  Future<tm.User?> registerWithEmail(String email, String password) async =>
      null;

  @override
  Future<tm.User?> signInWithEmail(String email, String password) async => null;

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
  bool get isEmailVerified => false;

  @override
  Future<tm.User?> signInWithGoogle() async => null;

  @override
  Future<tm.User?> signInWithApple() async => null;

  @override
  Future<tm.User?> signInWithFacebook() async => null;

  @override
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async => false;

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(tm.User user) : super(FakeAuthService()) {
    state = AuthState(user: user);
  }
}

void main() {
  testWidgets('unverified user redirected', (tester) async {
    final mockUser = MockUser();
    when(() => mockUser.emailVerified).thenReturn(false);
    final mockAuth = MockFirebaseAuth();
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
          splashControllerProvider.overrideWith(
            (ref) => _FakeSplashController(),
          ),
          authServiceProvider.overrideWith((ref) => FakeAuthService()),
          authProvider.overrideWith(
            (ref) => FakeAuthNotifier(
              tm.User(id: 'u1', email: 'e', displayName: 't'),
            ),
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
    expect(find.byType(EmailNotVerifiedScreen), findsOneWidget);
  });
}
