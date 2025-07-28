import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/screens/register_wizard.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

void main() {
  testWidgets('recaptcha bypass allows navigation to step2', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: RegisterWizard(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'test@exam.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Teszt123!');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('nicknameField')), findsOneWidget);
  });
}
