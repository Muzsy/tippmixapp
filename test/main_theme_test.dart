import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/services/theme_service.dart';
import 'package:tipsterino/theme/theme_builder.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

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
      home: const SizedBox.shrink(),
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
  testWidgets('MaterialApp updates when ThemeService changes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final themeService = ThemeService(
      prefs: prefs,
      firestore: FakeFirebaseFirestore(),
      auth: FakeFirebaseAuth(null),
    );
    final container = ProviderContainer(
      overrides: [themeServiceProvider.overrideWith((ref) => themeService)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const _TestApp()),
    );
    await tester.pumpAndSettle();

    BuildContext context = tester.element(find.byType(SizedBox));
    expect(Theme.of(context).brightness, Brightness.light);

    container.read(themeServiceProvider.notifier).toggleDarkMode();
    await tester.pumpAndSettle();
    context = tester.element(find.byType(SizedBox));
    expect(container.read(themeServiceProvider).isDark, isTrue);
    final material = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(material.themeMode, ThemeMode.dark);
    expect(Theme.of(context).brightness, Brightness.dark);

    container.read(themeServiceProvider.notifier).setScheme(1);
    await tester.pumpAndSettle();
    context = tester.element(find.byType(SizedBox));
    expect(container.read(themeServiceProvider).schemeIndex, 1);
    final expectedPrimary = buildTheme(
      scheme: FlexScheme.values[1],
      brightness: Brightness.dark,
    ).colorScheme.primary;
    expect(Theme.of(context).colorScheme.primary, expectedPrimary);
  });
}
