import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/controllers/app_locale_controller.dart';
import 'package:tippmixapp/controllers/app_theme_controller.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/screens/settings/settings_screen.dart';
import 'package:tippmixapp/models/user.dart';

class FakeAuthService implements AuthService {
  bool signOutCalled = false;
  final _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<User?> signInWithEmail(String email, String password) async => null;

  @override
  Future<User?> registerWithEmail(String email, String password) async => null;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _controller.add(null);
  }

  @override
  User? get currentUser => null;
}

void main() {
  testWidgets('Settings interactions update controllers and logout', (tester) async {
    final authService = FakeAuthService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifier(authService)),
          appThemeControllerProvider.overrideWith((ref) => AppThemeController()),
          appLocaleControllerProvider.overrideWith((ref) => AppLocaleController()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const SettingsScreen(),
        ),
      ),
    );

    // change theme
    await tester.tap(find.byType(DropdownButton<ThemeMode>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(SettingsScreen));
    final container = ProviderScope.containerOf(element, listen: false);
    expect(container.read(appThemeControllerProvider), ThemeMode.dark);

    // change language
    await tester.tap(find.byType(DropdownButton<Locale>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DE').last);
    await tester.pumpAndSettle();
    expect(container.read(appLocaleControllerProvider), const Locale('de'));

    // logout
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(authService.signOutCalled, isTrue);
  });
}
