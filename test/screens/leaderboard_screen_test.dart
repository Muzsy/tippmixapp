import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/models/user_stats_model.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/stats_provider.dart';
import 'package:tippmixapp/screens/leaderboard/leaderboard_screen.dart';
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
  User? get currentUser => _current;
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User? user)
      : super(FakeAuthService()) {
    state = user;
  }
}

void main() {
  testWidgets('LeaderboardScreen displays stats and highlights user', (tester) async {
    final controller = StreamController<List<UserStatsModel>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          leaderboardStreamProvider.overrideWith((ref) => controller.stream),
          authProvider.overrideWith((ref) => FakeAuthNotifier(User(id: 'u1', email: 'a@a.hu', displayName: 'Me'))),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LeaderboardScreen(),
        ),
      ),
    );

    controller.add([
      UserStatsModel(
        uid: 'u1',
        displayName: 'Me',
        coins: 100,
        totalBets: 1,
        totalWins: 1,
        winRate: 1.0,
      ),
      UserStatsModel(
        uid: 'u2',
        displayName: 'Other',
        coins: 50,
        totalBets: 1,
        totalWins: 0,
        winRate: 0.0,
      ),
    ]);
    await tester.pump();

    expect(find.text('You (Me)'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
  });

  testWidgets('LeaderboardScreen shows empty state', (tester) async {
    final controller = StreamController<List<UserStatsModel>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          leaderboardStreamProvider.overrideWith((ref) => controller.stream),
          authProvider.overrideWith((ref) => FakeAuthNotifier(null)),
        ],
          child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LeaderboardScreen(),
        ),
      ),
    );

    controller.add([]);
    await tester.pump();

    expect(find.text('No users yet'), findsOneWidget);
  });
}
