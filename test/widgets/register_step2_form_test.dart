import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/providers/register_state_notifier.dart';
import 'package:tippmixapp/screens/register_wizard.dart';
import '../mocks/mock_auth_service.dart';
import 'package:tippmixapp/providers/auth_provider.dart';

Future<void> _selectDate(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('birthDateField')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('1'));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('gdpr unchecked disables continue', (tester) async {
    final mockAuth = MockAuthService();
    mockAuth.nicknameUnique = true;

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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );
    // Wait for the PageView to attach to the controller before jumping
    await tester.pumpAndSettle();
    container.read(registerPageControllerProvider).jumpToPage(1);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('nicknameField')), 'tester');
    await _selectDate(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    final controller = container.read(registerPageControllerProvider);
    expect(controller.page, 1);
  });

  testWidgets('nickname not unique shows error', (tester) async {
    final mockAuth = MockAuthService();
    mockAuth.nicknameUnique = false;

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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );
    // Allow PageView to attach to controller
    await tester.pumpAndSettle();
    container.read(registerPageControllerProvider).jumpToPage(1);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('nicknameField')), 'tester');
    await _selectDate(tester);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    expect(find.text('Nickname already taken'), findsOneWidget);
    final controller = container.read(registerPageControllerProvider);
    expect(controller.page, 1);
  });

  testWidgets('valid input navigates to step 3', (tester) async {
    final mockAuth = MockAuthService();
    mockAuth.nicknameUnique = true;

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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );
    // Wait for controller to attach
    await tester.pumpAndSettle();
    container.read(registerPageControllerProvider).jumpToPage(1);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('nicknameField')), 'tester');
    await _selectDate(tester);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    final data = container.read(registerStateNotifierProvider);
    final controller = container.read(registerPageControllerProvider);
    expect(data.nickname, 'tester');
    expect(controller.page, 2);
  });
}
