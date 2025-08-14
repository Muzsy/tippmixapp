import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/screens/home_screen.dart';
import 'package:tippmixapp/features/home/widgets/guest_cta_tile.dart';
import 'package:tippmixapp/widgets/profile_summary.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/stats_provider.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/models/user_stats_model.dart';

class _FakeAuthNotifier extends StateNotifier<AuthState> {
  _FakeAuthNotifier(AuthState state) : super(state);
}

void main() {
  testWidgets('Guest shows GuestCtaTile', (tester) async {
    final container = ProviderContainer(overrides: [
      authProvider.overrideWith((ref) => _FakeAuthNotifier(const AuthState()) as dynamic),
      userStatsProvider.overrideWith((ref) async => null),
    ]);
    await tester.pumpWidget(ProviderScope(
      parent: container,
      child: const MaterialApp(home: HomeScreen(showStats: true)),
    ));
    expect(find.byType(GuestCtaTile), findsOneWidget);
  });

  testWidgets('Logged-in shows ProfileSummary', (tester) async {
    final user = User(id: '1', email: 'a@a.com', displayName: 'Alice');
    final container = ProviderContainer(overrides: [
      authProvider.overrideWith((ref) => _FakeAuthNotifier(AuthState(user: user)) as dynamic),
      userStatsProvider.overrideWith((ref) async => UserStatsModel(
            uid: '1',
            displayName: 'Alice',
            coins: 0,
            totalBets: 0,
            totalWins: 0,
            winRate: 0,
          )),
    ]);
    await tester.pumpWidget(ProviderScope(
      parent: container,
      child: const MaterialApp(home: HomeScreen(showStats: true)),
    ));
    expect(find.byType(ProfileSummary), findsOneWidget);
  });
}
