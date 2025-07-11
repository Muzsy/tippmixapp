import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/cooldown_button.dart';

void main() {
  testWidgets('CooldownButton disables after tap', (tester) async {
    int called = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CooldownButton(
            cooldown: const Duration(seconds: 1),
            onPressed: () async {
              called++;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(called, 1);

    // Button should be disabled immediately
    ElevatedButton btn = tester.widget(find.byType(ElevatedButton));
    expect(btn.onPressed, isNull);

    // After cooldown it becomes enabled again
    await tester.pump(const Duration(seconds: 1));
    btn = tester.widget(find.byType(ElevatedButton));
    expect(btn.onPressed, isNotNull);
  });
}
