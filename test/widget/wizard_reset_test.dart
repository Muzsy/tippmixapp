import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/screens/register_wizard.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../mocks/mock_auth_service.dart';
import 'package:tipsterino/providers/auth_provider.dart';

void main() {
  testWidgets('wizard dispose resets state', (tester) async {
    final mockAuth = MockAuthService();
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
      find.byType(TextFormField).first,
      'test@example.com',
    );
    expect(find.text('test@example.com'), findsOneWidget);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(mockAuth)],
        child: const MaterialApp(home: Placeholder()),
      ),
    );
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    expect(find.text('test@example.com'), findsNothing);
  });
}
