import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tippmixapp/screens/forgot_password_screen.dart';
import 'package:tippmixapp/screens/password_reset_confirm_screen.dart';
import 'package:tippmixapp/screens/reset_password_screen.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import '../mocks/mock_auth_service.dart';

void main() {
  testWidgets('forgot password happy path', (tester) async {
    final service = MockAuthService();
    final router = GoRouter(
      initialLocation: '/forgot',
      routes: [
        GoRoute(
          path: '/login',
          name: AppRoute.login.name,
          builder: (context, state) => const Scaffold(body: Text('login')),
        ),
        GoRoute(
          path: '/forgot',
          name: AppRoute.forgotPassword.name,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/confirm',
          name: AppRoute.passwordResetConfirm.name,
          builder: (context, state) => const PasswordResetConfirmScreen(),
        ),
        GoRoute(
          path: '/reset/:code',
          name: AppRoute.resetPassword.name,
          builder: (context, state) =>
              ResetPasswordScreen(oobCode: state.pathParameters['code']!),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWith((ref) => service)],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'a@b.c');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(service.sentEmail, 'a@b.c');
    expect(router.routerDelegate.currentConfiguration.fullPath, '/confirm');

    router.go('/reset/abc');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Password123');
    await tester.enterText(find.byType(TextFormField).at(1), 'Password123');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(service.confirmCode, 'abc');
    expect(service.confirmPassword, 'Password123');
    expect(router.routerDelegate.currentConfiguration.fullPath, '/login');
  });
}
