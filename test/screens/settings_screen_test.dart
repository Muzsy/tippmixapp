import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/controllers/app_locale_controller.dart';
import 'package:tippmixapp/controllers/app_theme_controller.dart';
import 'package:tippmixapp/services/theme_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/screens/settings/settings_screen.dart';
import 'package:tippmixapp/models/user.dart';

class FakeUser extends Fake implements fb.User {
  @override
  final String uid;
  FakeUser(this.uid);
}

class FakeFirebaseAuth extends Fake implements fb.FirebaseAuth {
  FakeFirebaseAuth(this._user);
  final fb.User? _user;
  @override
  fb.User? get currentUser => _user;
}

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
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  bool get isEmailVerified => true;

  @override
  User? get currentUser => null;
}

void main() {
  testWidgets('Settings interactions update controllers and logout', (
    tester,
  ) async {
    final authService = FakeAuthService();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final themeService = ThemeService(
      prefs: prefs,
      firestore: FakeFirebaseFirestore(),
      auth: FakeFirebaseAuth(null),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifier(authService)),
          appThemeControllerProvider.overrideWith(
            (ref) => AppThemeController(),
          ),
          appLocaleControllerProvider.overrideWith(
            (ref) => AppLocaleController(),
          ),
          themeServiceProvider.overrideWith((ref) => themeService),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SettingsScreen(),
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

    // toggle dark mode
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    expect(container.read(themeServiceProvider).isDark, isTrue);

    // change skin
    await tester.tap(find.text('Pink Party'));
    await tester.pumpAndSettle();
    expect(
      container.read(themeServiceProvider).schemeIndex,
      FlexScheme.pinkM3.index,
    );

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
