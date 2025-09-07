import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/router.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/controllers/splash_controller.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/services/auth_service.dart';

class _FakeAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _current = User(id: 'u1', email: 'u@x.com', displayName: 'U');

  _FakeAuthService() {
    _controller.add(_current);
  }

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
  Future<void> confirmPasswordReset(String code, String newPassword) async {}

  @override
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async => true;
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier() : super(_FakeAuthService()) {
    state = AuthState(
      user: User(id: 'u1', email: 'u@x.com', displayName: 'U'),
    );
  }
}

class _FakeSplashController extends StateNotifier<AsyncValue<AppRoute>>
    implements SplashController {
  _FakeSplashController() : super(const AsyncLoading()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state = const AsyncData(AppRoute.home);
    });
  }
}

void main() {
  testWidgets('Verified user → stays on / and sees Home content', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => _FakeAuthNotifier()),
        splashControllerProvider.overrideWith((ref) => _FakeSplashController()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // A gyökér útvonal maradjon aktív
    expect(router.routerDelegate.currentConfiguration.fullPath, '/');

    // A HomeScreen jellegzetes elemei megjelennek (pl. Scaffold)
    expect(find.byType(Scaffold), findsOneWidget);
    // Nem a FeedScreen a kezdő
    expect(find.text('Feed'), findsNothing);
  });
}
