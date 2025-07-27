import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/main.dart' as app;
import 'package:tippmixapp/router.dart';
import 'package:tippmixapp/screens/register_step1_form.dart';

void main() {
  testWidgets('register flow prints log', (tester) async {
    final logs = <String>[];
    await runZoned(() async {
      app.main();
      await tester.pumpAndSettle();
      router.go('/register');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'Password1!');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      await tester.enterText(find.byKey(const Key('nicknameField')), 'tester');
      await tester.tap(find.byKey(const Key('birthDateField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Finish'));
      await tester.pumpAndSettle();
    }, zoneSpecification: ZoneSpecification(print: (_, __, ___, String msg) {
      logs.add(msg);
    }));

    expect(logs.any((l) => l.contains('[REGISTER] STARTED')), isTrue);
    expect(logs.any((l) => l.contains('[REGISTER] SUCCESS')), isTrue);
  });

  testWidgets('shows error for weak password', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RegisterStep1Form())));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'bad@test');
    await tester.enterText(find.byType(TextFormField).at(1), 'weak');
    await tester.pump(const Duration(milliseconds: 350));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
