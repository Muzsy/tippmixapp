import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/screens/auth/login_form.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../mocks/mock_auth_service.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/theme/brand_colors_presets.dart';

void main() {
  testWidgets('LoginForm scrolls on small screens', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWith((ref) => MockAuthService()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          theme: ThemeData(extensions: const [brandColorsLight]),
          home: const Scaffold(body: LoginForm(variant: 'A')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
