import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:tipsterino/controllers/splash_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/screens/splash_screen.dart';
import 'package:tipsterino/screens/auth/login_screen.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/services/experiment_service.dart';
import 'package:tipsterino/services/analytics_service.dart';
import '../mocks/mock_auth_service.dart';
import 'package:tipsterino/theme/theme_builder.dart';

class _FakeSplashController extends StateNotifier<AsyncValue<AppRoute>>
    implements SplashController {
  _FakeSplashController() : super(const AsyncLoading()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state = const AsyncData(AppRoute.login);
    });
  }
}

class _FakeAnalyticsService extends AnalyticsService {
  _FakeAnalyticsService() : super(FakeFirebaseAnalytics());

  @override
  Future<void> logLoginVariantExposed(String variant) async {}

  @override
  Future<void> logLoginSuccess(String variant) async {}
}

class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {}

class _FakeExperimentService extends ExperimentService {
  _FakeExperimentService() : super(remoteConfig: FakeRemoteConfig('A'));

  @override
  Future<String> getLoginVariant() async => 'A';
}

class FakeRemoteConfig extends Fake implements FirebaseRemoteConfig {
  final String variant;
  FakeRemoteConfig(this.variant);

  @override
  Future<bool> fetchAndActivate() async => true;

  @override
  String getString(String key) => variant;
}

void main() {
  testWidgets('splash navigates to login within timeout', (tester) async {
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
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          splashControllerProvider.overrideWith(
            (ref) => _FakeSplashController(),
          ),
          authServiceProvider.overrideWith((ref) => MockAuthService()),
          analyticsServiceProvider.overrideWith(
            (ref) => _FakeAnalyticsService(),
          ),
          experimentServiceProvider.overrideWith(
            (ref) => _FakeExperimentService(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: buildTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
