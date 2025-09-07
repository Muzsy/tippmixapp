import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/screens/auth/login_screen.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/services/experiment_service.dart';
import 'package:tipsterino/services/analytics_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tipsterino/theme/theme_builder.dart';
import '../mocks/mock_auth_service.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(super.service);
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

late GoRouter _router;
late _FakeAuthNotifier _notifier;
late MockAuthService _service;

Widget _buildApp({required Locale locale}) {
  _service = MockAuthService();
  _notifier = _FakeAuthNotifier(_service);
  _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) => const Scaffold(body: Text('Home')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) => _notifier),
      authServiceProvider.overrideWith((ref) => _service),
      analyticsServiceProvider.overrideWith((ref) => _FakeAnalyticsService()),
      experimentServiceProvider.overrideWith((ref) => _FakeExperimentService()),
    ],
    child: MaterialApp.router(
      routerConfig: _router,
      theme: buildTheme(),
      darkTheme: buildTheme(brightness: Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
    ),
  );
}

void main() {
  testWidgets('successful email login navigates to home for all locales', (
    tester,
  ) async {
    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(_buildApp(locale: locale));
      await tester.pumpAndSettle();

      await _notifier.login('a@b.c', 'pw');
      _router.go('/home');
      await tester.pumpAndSettle();

      expect(_router.routerDelegate.currentConfiguration.fullPath, '/home');
    }
  });
}
