import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/controllers/splash_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/screens/splash_screen.dart';
import 'package:tipsterino/screens/register_wizard.dart';

class _FakeSplashController extends StateNotifier<AsyncValue<AppRoute>>
    implements SplashController {
  _FakeSplashController() : super(const AsyncLoading()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state = const AsyncData(AppRoute.login);
    });
  }
}

void main() {
  testWidgets('splash navigates to login without errors', (tester) async {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: AppRoute.login.name,
          builder: (context, state) => const Scaffold(body: Text('login')),
        ),
        GoRoute(
          path: '/register',
          name: AppRoute.register.name,
          builder: (context, state) => const RegisterWizard(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          splashControllerProvider.overrideWith(
            (ref) => _FakeSplashController(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en'), Locale('hu'), Locale('de')],
          locale: const Locale('en'),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.fullPath, '/login');
    expect(tester.takeException(), isNull);
  });
}
