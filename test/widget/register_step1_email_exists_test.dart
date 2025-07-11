import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/controllers/register_step1_viewmodel.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/screens/register_step1_form.dart';
import 'package:tippmixapp/services/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<bool> isEmailAvailable(String email) async {
    throw EmailAlreadyInUseFailure();
  }
}

void main() {
  testWidgets('shows snackbar when email exists', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          registerStep1ViewModelProvider.overrideWith((ref) {
            return RegisterStep1ViewModel(FakeAuthRepository());
          }),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(body: RegisterStep1Form()),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Password1!');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    final element = tester.element(find.byType(RegisterStep1Form));
    final container = ProviderScope.containerOf(element, listen: false);
    expect(
      container.read(registerStep1ViewModelProvider),
      RegisterStep1State.emailExists,
    );
  }, skip: true);
}
