import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/ticket_model.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/screens/my_tickets_screen.dart';
import 'package:tippmixapp/widgets/empty_ticket_placeholder.dart';
import 'package:tippmixapp/widgets/ticket_card.dart';
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

final sampleTickets = [
  Ticket(
    id: 't1',
    userId: 'u1',
    tips: const [],
    stake: 100,
    totalOdd: 3.5,
    potentialWin: 350,
    createdAt: DateTime(2025, 6, 15),
    updatedAt: DateTime(2025, 6, 15),
    status: TicketStatus.pending,
  ),
];

Widget _buildApp({required Override auth, required Override tickets}) {
  return ProviderScope(
    overrides: [auth, tickets],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: MyTicketsScreen(showAppBar: false),
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('shows placeholder when signed out', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        auth: authProvider.overrideWith((ref) => FakeAuthNotifier(null)),
        tickets: ticketsProvider.overrideWith(
          (ref) => Stream.value(const <Ticket>[]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EmptyTicketPlaceholder), findsOneWidget);
  });

  testWidgets('shows list of tickets', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        auth: authProvider.overrideWith(
          (ref) =>
              FakeAuthNotifier(User(id: 'u1', email: 'e', displayName: 'Me')),
        ),
        tickets: ticketsProvider.overrideWith(
          (ref) => Stream.value(sampleTickets),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TicketCard), findsNWidgets(sampleTickets.length));
  });

  testWidgets('pull to refresh refreshes provider', (tester) async {
    var calls = 0;
    final override = ticketsProvider.overrideWith((ref) {
      calls++;
      return Stream.value(sampleTickets);
    });

    await tester.pumpWidget(
      _buildApp(
        auth: authProvider.overrideWith(
          (ref) =>
              FakeAuthNotifier(User(id: 'u1', email: 'e', displayName: 'Me')),
        ),
        tickets: override,
      ),
    );
    await tester.pumpAndSettle();

    expect(calls, 1);

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(calls, 2);
  });
}
