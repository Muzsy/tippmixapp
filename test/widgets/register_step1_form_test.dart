import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/providers/register_state_notifier.dart';
import 'package:tippmixapp/screens/register_wizard.dart';
import '../mocks/mock_auth_service.dart';
import 'package:tippmixapp/providers/auth_provider.dart';

void main() {
  testWidgets('entering valid data enables continue and navigates', (
    tester,
  ) async {
    final mockAuth = MockAuthService();
    mockAuth.emailUnique = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(mockAuth)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: RegisterWizard(),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Password1');
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(RegisterWizard)),
    );
    final data = container.read(registerStateNotifierProvider);
    final controller = container.read(registerPageControllerProvider);
    expect(data.email, 'user@example.com');
    expect(controller.page, 1);
  });
}
