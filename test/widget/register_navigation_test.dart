import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tippmixapp/screens/register_wizard.dart';
import 'package:tippmixapp/providers/hibp_service_provider.dart';
import 'package:tippmixapp/providers/recaptcha_service_provider.dart';
import 'package:tippmixapp/providers/auth_repository_provider.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/services/hibp_service.dart';
import 'package:tippmixapp/services/recaptcha_service.dart';
import 'package:tippmixapp/services/auth_repository.dart';
import 'package:tippmixapp/services/analytics_service.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../mocks/mock_auth_service.dart';

class FakeHIBPService extends HIBPService {
  FakeHIBPService() : super();

  @override
  Future<bool> isPasswordPwned(String password) async => false;
}

class FakeRecaptchaService extends RecaptchaService {
  FakeRecaptchaService() : super(secret: 's');

  @override
  Future<bool> verifyToken(String token) async => true;
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<bool> isEmailAvailable(String email) async => true;
}

class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {}

class _FakeAnalyticsService extends AnalyticsService {
  _FakeAnalyticsService() : super(FakeFirebaseAnalytics());
}

void main() {
  testWidgets('navigation from step1 to step2 works', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hibpServiceProvider.overrideWith((ref) => FakeHIBPService()),
          recaptchaServiceProvider.overrideWith((ref) => FakeRecaptchaService()),
          authServiceProvider.overrideWith((ref) => MockAuthService()),
          authRepositoryProvider.overrideWith((ref) => FakeAuthRepository()),
          analyticsServiceProvider.overrideWith((ref) => _FakeAnalyticsService()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: RegisterWizard(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'TestPassword1!');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byKey(const Key('nicknameField')), findsOneWidget);
  });
}
