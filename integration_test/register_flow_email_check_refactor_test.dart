import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_harness.dart';
import 'package:tipsterino/screens/auth/login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('guest navigating to my-tickets shows login screen', (t) async {
    await ITTHarness.launchAsGuest(t);
    // Wait for bottom nav, then tap a protected destination
    for (var i = 0; i < 30; i++) {
      if (find.byKey(const Key('nav_my_tickets')).evaluate().isNotEmpty) break;
      await t.pump(const Duration(milliseconds: 200));
    }
    await t.tap(find.byKey(const Key('nav_my_tickets')));
    await t.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
