import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tippmixapp/main.dart' as app;
import 'package:tippmixapp/router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full register flow – debug reCAPTCHA bypass', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    router.go('/register');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Password1!');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('nicknameField')), 'tester');
    await tester.tap(find.byKey(const Key('birthDateField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.text('E‑mail megerősítése szükséges'), findsOneWidget);
  });
}
