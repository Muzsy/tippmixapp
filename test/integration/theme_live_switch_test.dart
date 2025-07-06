import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:tippmixapp/services/theme_service.dart';
import 'package:tippmixapp/theme/theme_builder.dart';
import 'package:tippmixapp/screens/settings/settings_screen.dart';
import 'package:tippmixapp/controllers/app_locale_controller.dart';
import 'package:tippmixapp/controllers/app_theme_controller.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class FakeFirebaseAuth extends Fake implements fb.FirebaseAuth {
  FakeFirebaseAuth(this._user);
  final fb.User? _user;
  @override
  fb.User? get currentUser => _user;
}

class _TestApp extends ConsumerWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServiceProvider);
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const SettingsScreen(),
      theme: buildTheme(
        scheme: FlexScheme.values[theme.schemeIndex],
        brightness: Brightness.light,
      ),
      darkTheme: buildTheme(
        scheme: FlexScheme.values[theme.schemeIndex],
        brightness: Brightness.dark,
      ),
      themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}

void main() {
  testWidgets('skin and dark mode changes apply globally', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final themeService = ThemeService(
      prefs: prefs,
      firestore: FakeFirebaseFirestore(),
      auth: FakeFirebaseAuth(null),
    );

    final container = ProviderContainer(overrides: [
      themeServiceProvider.overrideWith((ref) => themeService),
      appLocaleControllerProvider.overrideWith((ref) => AppLocaleController()),
      appThemeControllerProvider.overrideWith((ref) => AppThemeController()),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const _TestApp(),
    ));
    await tester.pumpAndSettle();

    BuildContext context = tester.element(find.byType(SettingsScreen));
    expect(Theme.of(context).brightness, Brightness.light);

    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    context = tester.element(find.byType(SettingsScreen));
    expect(container.read(themeServiceProvider).isDark, isTrue);
    expect(Theme.of(context).brightness, Brightness.dark);

    await tester.tap(find.text('Pink Party'));
    await tester.pumpAndSettle();
    context = tester.element(find.byType(SettingsScreen));
    expect(container.read(themeServiceProvider).schemeIndex, FlexScheme.pinkM3.index);
    final expectedPrimary = buildTheme(
      scheme: FlexScheme.pinkM3,
      brightness: Brightness.dark,
    ).colorScheme.primary;
    expect(Theme.of(context).colorScheme.primary, expectedPrimary);
  });
}
