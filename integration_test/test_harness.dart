import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tipsterino/main.dart' as app;
import 'package:tipsterino/router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ITTHarness {
  static Future<void> launchAsGuest(WidgetTester tester, {String? route}) async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    app.main();
    // Avoid indefinite pumpAndSettle hangs due to ongoing animations/timers.
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    if (route != null) {
      router.go(route);
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
  }
}
