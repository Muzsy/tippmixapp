import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tippmixapp/main.dart' as app;
import 'package:tippmixapp/router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ITTHarness {
  static Future<void> launchAsGuest(WidgetTester tester, {String? route}) async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    app.main();
    await tester.pumpAndSettle();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    await tester.pumpAndSettle();
    if (route != null) {
      router.go(route);
      await tester.pumpAndSettle();
    }
  }
}

