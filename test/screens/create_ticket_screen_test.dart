import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/tip_model.dart';
import 'package:tippmixapp/providers/bet_slip_provider.dart';
import 'package:tippmixapp/screens/create_ticket_screen.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/models/user.dart' as m;
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/services/auth_service.dart';

// ------------------------------------------------------------------
// T04 – CreateTicketScreen widget-tesztek (Sprint5) – **FIXED v3**
//   • Igazodunk a projekthez: a provider típusa
//     StateNotifierProvider<BetSlipProvider, BetSlipProviderState>.
//   • A fake notifier most a **BetSlipProvider** class-t örökli, így
//     maradéktalanul illeszkedik.
// ------------------------------------------------------------------

// -------------------------
// 1. Fakes / Stubok
// -------------------------
class _FakeAuthService implements AuthService {
  @override
  Stream<m.User?> authStateChanges() => const Stream.empty();
  @override
  m.User? get currentUser => null;
  Future<bool> validateEmailUnique(String email) async => true;
  Future<bool> validateNicknameUnique(String nickname) async => true;
  @override
  Future<m.User?> signInWithEmail(String email, String password) async => null;
  @override
  Future<m.User?> registerWithEmail(String email, String password) async =>
      null;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  bool get isEmailVerified => true;

  @override
  Future<m.User?> signInWithGoogle() async => null;

  @override
  Future<m.User?> signInWithApple() async => null;

  @override
  Future<m.User?> signInWithFacebook() async => null;
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier() : super(_FakeAuthService()) {
    state = AuthState(
      user: m.User(id: 'u1', email: 'dev@example.com', displayName: 'Dev'),
    );
  }
}

/// Mockolt BetSlipProvider – a projektben `StateNotifier<BetSlipProviderState>`.
class _FakeBetSlipProvider extends BetSlipProvider {
  _FakeBetSlipProvider({required List<TipModel> initialTips}) : super() {
    state = BetSlipProviderState(tips: initialTips);
  }

  Future<void> submitTicket(double stake) async {
    // stub – nem történik hálózati hívás vagy Firestore írás
  }
}

// -------------------------
// 2. Segédfüggvény a teszt-apphoz
// -------------------------
Widget _buildTestApp({required List<TipModel> tips}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) => _FakeAuthNotifier()),
      // closure *BetSlipProvider* típust ad vissza, OK a fordítónak
      betSlipProvider.overrideWith(
        (ref) => _FakeBetSlipProvider(initialTips: tips),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en'), Locale('hu')],
      locale: Locale('en'),
      home: CreateTicketScreen(),
    ),
  );
}

// -------------------------
// 3. Tesztesetek (stake‑validáció logikához igazítva)
// -------------------------
void main() {
  group('CreateTicketScreen', () {
    final sampleTips = [
      TipModel(
        eventId: 'e1',
        eventName: 'Arsenal vs City',
        odds: 2.0,
        startTime: DateTime(2025, 7, 1),
        sportKey: 'soccer',
        bookmaker: 'Bet365',
        marketKey: 'h2h',
        outcome: 'Arsenal',
      ),
      TipModel(
        eventId: 'e2',
        eventName: 'Real vs Barca',
        odds: 1.5,
        startTime: DateTime(2025, 7, 2),
        sportKey: 'soccer',
        bookmaker: 'Bet365',
        marketKey: 'h2h',
        outcome: 'Real Madrid',
      ),
    ];

    testWidgets('Tippek listája jelenik meg', (tester) async {
      await tester.pumpWidget(_buildTestApp(tips: sampleTips));
      await tester.pumpAndSettle();

      expect(find.text('Arsenal vs City'), findsOneWidget);
      expect(find.text('Real vs Barca'), findsOneWidget);
    });

    testWidgets(
      'Stake = 0 esetén hibaüzenet jelenik meg "Place Bet" gombnyomásra',
      (tester) async {
        await tester.pumpWidget(_buildTestApp(tips: sampleTips));
        await tester.pumpAndSettle();

        // Stake 0
        await tester.enterText(find.byType(TextField), '0');
        await tester.pump();

        // Gomb lenyomása
        await tester.tap(find.widgetWithText(ElevatedButton, 'Place Bet'));
        await tester.pump();

        // SnackBar ‑ vagy Text ‑ hibajelzés várható ("Invalid stake" stb.)
        expect(find.textContaining('stake'), findsOneWidget);
      },
    );

    testWidgets('Potenciális nyeremény 100 Ft Stake esetén 300.00 Ft', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(tips: sampleTips));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '100');
      await tester.pump();

      expect(find.text('Total odds: 3.0'), findsOneWidget);
      expect(find.text('Potential win: 300.00 Ft'), findsOneWidget);
    });
  });
}
