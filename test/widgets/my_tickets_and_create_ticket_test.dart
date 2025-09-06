import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/ticket_model.dart';
import 'package:tipsterino/models/tip_model.dart';
import 'package:tipsterino/models/user.dart' as app;
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/onboarding_provider.dart'
    show firebaseAuthProvider;
import 'package:tipsterino/services/auth_service.dart';
import 'package:tipsterino/providers/bet_slip_provider.dart';
import 'package:tipsterino/screens/create_ticket_screen.dart';
import 'package:tipsterino/screens/my_tickets_screen.dart';
import 'package:tipsterino/widgets/empty_ticket_placeholder.dart';

// We avoid real Firebase by injecting a fake AuthService that exposes
// a controllable auth state stream without platform channels.
class _FakeAuthService implements AuthService {
  _FakeAuthService(this._controller);
  final StreamController<app.User?> _controller;
  @override
  Stream<app.User?> authStateChanges() => _controller.stream;
  @override
  Future<app.User?> signInWithEmail(String email, String password) async =>
      null;
  @override
  Future<app.User?> signInWithGoogle() async => null;
  @override
  Future<app.User?> signInWithApple() async => null;
  @override
  Future<app.User?> signInWithFacebook() async => null;
  @override
  Future<app.User?> registerWithEmail(String email, String password) async =>
      null;
  @override
  Future<bool> validateEmailUnique(String email) async => true;
  @override
  Future<bool> validateNicknameUnique(String nickname) async => true;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
  @override
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async => true;
  @override
  bool get isEmailVerified => true;
  @override
  app.User? get currentUser => null;
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MyTicketsScreen', () {
    testWidgets('shows empty placeholder when user is null', (tester) async {
      final authCtrl = StreamController<app.User?>();
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWith(
              (ref) => _FakeAuthService(authCtrl),
            ),
            firebaseAuthProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MyTicketsScreen(showAppBar: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: empty placeholder widget visible (independent of locale)
      expect(find.byType(EmptyTicketPlaceholder), findsOneWidget);
    });

    testWidgets('shows tickets when user present and stream has items', (
      tester,
    ) async {
      final sampleTip = TipModel(
        eventId: 'e1',
        eventName: 'Team A vs Team B',
        startTime: DateTime.now(),
        sportKey: 'soccer',
        marketKey: 'h2h',
        outcome: 'Team A',
        odds: 2.1,
      );
      final t = Ticket(
        id: 't1',
        userId: 'u1',
        tips: [sampleTip],
        stake: 100,
        totalOdd: 2.1,
        potentialWin: 210,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        status: TicketStatus.pending,
      );

      // Override ticketsProvider to avoid real Firestore
      final ticketsOverride = ticketsProvider.overrideWith(
        (ref) => Stream.value([t]),
      );

      final authCtrl = StreamController<app.User?>();
      final mockAuth = MockFirebaseAuth();
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('u1');
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ticketsOverride,
            authServiceProvider.overrideWith(
              (ref) => _FakeAuthService(authCtrl),
            ),
            firebaseAuthProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MyTicketsScreen(showAppBar: true),
          ),
        ),
      );

      // After mounting, push a user into the fake auth stream
      authCtrl.add(app.User(id: 'u1', email: 'x@y', displayName: 'X'));

      await tester.pumpAndSettle();

      // Assert: at least one TicketCard is rendered (by finding status stripe key)
      expect(find.byKey(const Key('ticket_status_stripe')), findsWidgets);
    });
  });

  group('CreateTicketScreen layout', () {
    testWidgets('does not overflow with long labels on small width', (
      tester,
    ) async {
      // Arrange a tip in the bet slip
      final tip = TipModel(
        eventId: 'e1',
        eventName: 'A very very long event name that could overflow',
        startTime: DateTime.now(),
        sportKey: 'soccer',
        marketKey: 'h2h',
        outcome: 'Team with a Very Long Name',
        odds: 3.14159,
      );

      final betOverride = betSlipProvider.overrideWith((ref) {
        final s = BetSlipProviderState(tips: [tip]);
        return BetSlipProvider()..state = s;
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [betOverride],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: MediaQueryData(size: Size(320, 640)),
              child: CreateTicketScreen(),
            ),
          ),
        ),
      );

      // Enter a stake to populate potential win text
      await tester.enterText(find.byType(TextField), '100');
      await tester.pumpAndSettle();

      // If there is any layout exception (e.g. overflow), Flutter will surface it here
      final ex = tester.takeException();
      expect(
        ex,
        isNull,
        reason: 'CreateTicket layout should not overflow on small width',
      );
    });
  });
}
