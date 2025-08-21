import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/home_profile_header.dart';
import 'package:tippmixapp/widgets/guest_promo_tile.dart';
import 'package:tippmixapp/widgets/home/user_stats_header.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/stats_provider.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/models/user_stats_model.dart';
import 'package:tippmixapp/services/auth_service.dart';

class _FakeAuthService implements AuthService {
  @override
  Stream<User?> authStateChanges() => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  bool get isEmailVerified => true;

  @override
  Future<User?> signInWithEmail(String email, String password) async => null;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;

  @override
  Future<User?> registerWithEmail(String email, String password) async => null;

  @override
  Future<bool> validateEmailUnique(String email) async => true;

  @override
  Future<bool> validateNicknameUnique(String nickname) async => true;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(seconds: 1),
  }) async => true;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(AuthState state) : super(_FakeAuthService()) {
    this.state = state;
  }
}

Widget _wrap({required Widget child, required AuthState authState, UserStatsModel? stats}) {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith((ref) => _FakeAuthNotifier(authState)),
      userStatsProvider.overrideWith((ref) async => stats),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  testWidgets('Guest shows GuestPromoTile', (tester) async {
    await tester.pumpWidget(
      _wrap(
        child: HomeProfileHeader(isLoggedIn: () => false),
        authState: const AuthState(),
        stats: null,
      ),
    );
    expect(find.byType(GuestPromoTile), findsOneWidget);
  });

  testWidgets('Logged-in shows UserStatsHeader', (tester) async {
    final user = User(id: '1', email: 'a@a.com', displayName: 'Alice');
    await tester.pumpWidget(
      _wrap(
        child: HomeProfileHeader(isLoggedIn: () => true),
        authState: AuthState(user: user),
        stats: UserStatsModel(
          uid: '1',
          displayName: 'Alice',
          coins: 0,
          totalBets: 0,
          totalWins: 0,
          winRate: 0,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(UserStatsHeader), findsOneWidget);
  });
}
