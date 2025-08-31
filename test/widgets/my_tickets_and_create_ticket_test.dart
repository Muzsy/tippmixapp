import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/ticket_model.dart';
import 'package:tippmixapp/models/tip_model.dart';
import 'package:tippmixapp/models/user.dart' as app;
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/bet_slip_provider.dart';
import 'package:tippmixapp/screens/create_ticket_screen.dart';
import 'package:tippmixapp/screens/my_tickets_screen.dart';

class _TestAuthNotifier extends StateNotifier<AuthState> {
  _TestAuthNotifier(AuthState initial) : super(initial);
  void setUser(app.User? u) => state = AuthState(user: u);
}

void main() {
  group('MyTicketsScreen', () {
    testWidgets('shows empty placeholder when user is null', (tester) async {
      // Arrange
      final auth = StateNotifierProvider<_TestAuthNotifier, AuthState>(
        (ref) => _TestAuthNotifier(const AuthState(user: null)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override the real authProvider with a test version
            authProvider.overrideWithProvider(auth),
            // No tickets since user is null; provider would return [] anyway
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MyTicketsScreen(showAppBar: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: empty placeholder text visible
      expect(find.textContaining('no tickets').or(find.textContaining('nincs szelvény')), findsWidgets);
    });

    testWidgets('shows tickets when user present and stream has items', (tester) async {
      // Arrange auth with a user
      final auth = StateNotifierProvider<_TestAuthNotifier, AuthState>(
        (ref) => _TestAuthNotifier(AuthState(user: app.User(id: 'u1', email: 'x@y', displayName: 'X'))),
      );

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
      final ticketsOverride = ticketsProvider.overrideWith((ref) => Stream.value([t]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWithProvider(auth), ticketsOverride],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MyTicketsScreen(showAppBar: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: at least one TicketCard is rendered (by finding status stripe key)
      expect(find.byKey(const Key('ticket_status_stripe')), findsWidgets);
    });
  });

  group('CreateTicketScreen layout', () {
    testWidgets('does not overflow with long labels on small width', (tester) async {
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
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MediaQuery(
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
      expect(ex, isNull, reason: 'CreateTicket layout should not overflow on small width');
    });
  });
}

