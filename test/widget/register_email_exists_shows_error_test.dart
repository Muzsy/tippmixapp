import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/screens/register_wizard.dart';
import 'package:tippmixapp/services/auth_repository.dart';
import 'package:tippmixapp/providers/auth_repository_provider.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  testWidgets('email exists shows snackbar', (t) async {
    final repo = _MockRepo();
    when(
      () => repo.isEmailAvailable(any()),
    ).thenThrow(EmailAlreadyInUseFailure());
    await t.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWith((ref) => repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('hu'),
          home: RegisterWizard(),
        ),
      ),
    );
    await t.enterText(find.byType(TextFormField).first, 'taken@x.com');
    await t.enterText(find.byType(TextFormField).at(1), 'Teszt123!');
    await t.tap(find.widgetWithText(ElevatedButton, 'Folytatás'));
    await t.pump(const Duration(milliseconds: 350));
    expect(find.text('Ez az e-mail már foglalt'), findsOneWidget);
  });
}
