import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/screens/profile/security/security_screen.dart';
import 'package:tipsterino/screens/profile/security/two_factor_wizard.dart';
import 'package:tipsterino/services/security_service.dart';

void main() {
  testWidgets('toggle navigates to wizard', (tester) async {
    final service = SecurityService();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: AppRoute.security.name,
          builder: (c, s) => SecurityScreen(service: service),
          routes: [
            GoRoute(
              path: 'wizard',
              name: AppRoute.twoFactorWizard.name,
              builder: (c, s) => TwoFactorWizard(service: service),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.byType(TwoFactorWizard), findsOneWidget);
  });
}
