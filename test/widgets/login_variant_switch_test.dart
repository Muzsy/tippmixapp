import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/screens/auth/login_screen.dart';
import 'package:tippmixapp/services/experiment_service.dart';
import 'package:tippmixapp/services/analytics_service.dart';
import 'package:tippmixapp/widgets/promo_panel.dart';

class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {}

class FakeAnalyticsService extends AnalyticsService {
  FakeAnalyticsService() : super(FakeFirebaseAnalytics());
  @override
  Future<void> logLoginVariantExposed(String variant) async {}
  @override
  Future<void> logLoginSuccess(String variant) async {}
}

class FakeRemoteConfig extends Fake implements FirebaseRemoteConfig {
  String variant;
  FakeRemoteConfig(this.variant);
  @override
  Future<bool> fetchAndActivate() async => true;
  @override
  String getString(String key) => variant;
}

class FakeExperimentService extends ExperimentService {
  FakeExperimentService() : super(remoteConfig: FakeRemoteConfig('B'));
  @override
  Future<String> getLoginVariant() async => 'B';
}

Widget _buildApp(ProviderContainer container) {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      name: AppRoute.login.name,
      builder: (context, state) => const LoginScreen(),
    ),
  ]);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  testWidgets('shows promo panel when variant B', (tester) async {
    final container = ProviderContainer(overrides: [
      experimentServiceProvider.overrideWith((ref) => FakeExperimentService()),
      analyticsServiceProvider.overrideWith((ref) => FakeAnalyticsService()),
    ]);
    await tester.pumpWidget(_buildApp(container));
    await tester.pumpAndSettle();

    expect(find.byType(PromoPanel), findsOneWidget);
  });
}
