import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'test_harness.dart';
import 'package:tippmixapp/screens/auth/login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('guest tap on bet slip shows login dialog', (tester) async {
    await ITTHarness.launchAsGuest(tester);
    // Wait until bottom nav is rendered
    for (var i = 0; i < 30; i++) {
      if (find.byKey(const Key('nav_bets')).evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 200));
    }
    // Tap a protected area: My Tickets requires auth
    await tester.tap(find.byKey(const Key('nav_my_tickets')));
    await tester.pumpAndSettle();

    // Router guard redirects guests to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);

    // Done
  });
}
