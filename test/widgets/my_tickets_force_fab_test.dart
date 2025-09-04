import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart' as app;
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/screens/my_tickets_screen.dart'
    show MyTicketsScreen, ticketsProvider;
import 'package:tippmixapp/models/ticket_model.dart';
import 'package:tippmixapp/providers/onboarding_provider.dart'
    show firebaseAuthProvider;

class FakeAuthService implements AuthService {
  final _controller = StreamController<app.User?>.broadcast();
  app.User? _current;

  @override
  Stream<app.User?> authStateChanges() => _controller.stream;
  @override
  Future<app.User?> signInWithEmail(String email, String password) async =>
      null;
  @override
  Future<app.User?> registerWithEmail(String email, String password) async =>
      null;
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
  app.User? get currentUser => _current;
  @override
  Future<bool> validateEmailUnique(String email) async => true;
  @override
  Future<bool> validateNicknameUnique(String nickname) async => true;
  @override
  Future<app.User?> signInWithGoogle() async => null;
  @override
  Future<app.User?> signInWithApple() async => null;
  @override
  Future<app.User?> signInWithFacebook() async => null;
  @override
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async => true;
  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(FakeAuthService()) {
    state = const AuthState(user: null);
  }
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  testWidgets('FAB visible for allowed uid', (tester) async {
    final mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('2pEEqMzCsBfkrv4jWx3YP5yDb0F2');
    final mockAuth = MockFirebaseAuth();
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
          ticketsProvider.overrideWith((ref) => Stream.value(const <Ticket>[])),
          authServiceProvider.overrideWith((ref) => FakeAuthService()),
          authProvider.overrideWith((ref) => FakeAuthNotifier()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MyTicketsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('FAB hidden for other uids', (tester) async {
    final mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('other');
    final mockAuth = MockFirebaseAuth();
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
          ticketsProvider.overrideWith((ref) => Stream.value(const <Ticket>[])),
          authServiceProvider.overrideWith((ref) => FakeAuthService()),
          authProvider.overrideWith((ref) => FakeAuthNotifier()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MyTicketsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
