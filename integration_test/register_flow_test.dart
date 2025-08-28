import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tippmixapp/main.dart' as app;
import 'package:tippmixapp/router.dart';
import 'package:tippmixapp/screens/register_step1_form.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('register flow prints log', (tester) async {
    final logs = <String>[];
    await runZoned(
      () async {
        app.main();
        await tester.pumpAndSettle();
        // Ensure guest state to avoid router redirects
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
        router.go('/register');
        await tester.pumpAndSettle();
        // Ensure we are on Register page
        for (var i = 0; i < 30; i++) {
          if (find.byKey(const Key('registerPage')).evaluate().isNotEmpty) break;
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(find.byKey(const Key('registerPage')), findsOneWidget);
        // Wait up to ~5s for the form to appear
        for (var i = 0; i < 25; i++) {
          if (find.byKey(const Key('emailField')).evaluate().isNotEmpty) break;
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(find.byType(RegisterStep1Form), findsOneWidget);
        // Focus fields explicitly before typing to ensure EditableText exists
        await tester.tap(find.byKey(const Key('emailField')));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.enterText(find.byKey(const Key('emailField')), 'user@test.com');
        await tester.tap(find.byKey(const Key('passwordField')));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.enterText(find.byKey(const Key('passwordField')), 'Password1!');
        await tester.tap(find.byKey(const Key('continueStep1')));
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        await tester.enterText(
          find.byKey(const Key('nicknameField')),
          'tester',
        );
        await tester.tap(find.byKey(const Key('birthDateField')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('1'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CheckboxListTile));
        await tester.tap(find.byKey(const Key('continueStep2')));
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        await tester.tap(find.byKey(const Key('finishButton')));
        await tester.pumpAndSettle();
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, String msg) {
          logs.add(msg);
        },
      ),
    );

    expect(logs.any((l) => l.contains('[REGISTER] STARTED')), isTrue);
    expect(logs.any((l) => l.contains('[REGISTER] SUCCESS')), isTrue);
  }, skip: true);

  testWidgets('shows error for weak password', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('hu'), Locale('en'), Locale('de')],
          home: const Scaffold(body: RegisterStep1Form()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('emailField')), 'bad@test');
    await tester.enterText(find.byKey(const Key('passwordField')), 'weak');
    await tester.pump(const Duration(milliseconds: 350));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
