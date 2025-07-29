import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/services/auth_repository.dart';
import 'package:tippmixapp/screens/register_step1_form.dart';
import 'package:tippmixapp/providers/auth_repository_provider.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  testWidgets('taken email shows snackbar', (t) async {
    final repo = _MockRepo();
    when(() => repo.isEmailAvailable(any())).thenAnswer((_) async => false);
    await t.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWith((ref) => repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('hu'),
          home: Scaffold(body: RegisterStep1Form()),
        ),
      ),
    );
    await t.enterText(find.byKey(const Key('emailField')), 'taken@x.com');
    await t.enterText(find.byKey(const Key('passwordField')), 'Teszt123!');
    await t.tap(find.widgetWithText(ElevatedButton, 'Tovább'));
    await t.pump();
    expect(find.textContaining('e-mail cím már foglalt'), findsOneWidget);
  });
}
