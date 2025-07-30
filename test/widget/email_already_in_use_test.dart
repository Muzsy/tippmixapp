import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/providers/hibp_service_provider.dart';
import 'package:tippmixapp/providers/recaptcha_service_provider.dart';
import 'package:tippmixapp/providers/auth_repository_provider.dart';
import 'package:tippmixapp/services/hibp_service.dart';
import 'package:tippmixapp/services/recaptcha_service.dart';
import 'package:tippmixapp/services/auth_repository.dart';
import 'package:tippmixapp/services/analytics_service.dart';
import 'package:tippmixapp/screens/register_wizard.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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

class FailingAuthRepository implements AuthRepository {
  @override
  Future<bool> isEmailAvailable(String email) async {
    throw EmailAlreadyInUseFailure();
  }
}

class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {}

class _FakeAnalyticsService extends AnalyticsService {
  _FakeAnalyticsService() : super(FakeFirebaseAnalytics());
}

void main() {
  testWidgets('email already in use shows snackbar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hibpServiceProvider.overrideWith((ref) => FakeHIBPService()),
          recaptchaServiceProvider.overrideWith(
            (ref) => FakeRecaptchaService(),
          ),
          authRepositoryProvider.overrideWith((ref) => FailingAuthRepository()),
          analyticsServiceProvider.overrideWith(
            (ref) => _FakeAnalyticsService(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: RegisterWizard(),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'taken@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Test123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.text('This e-mail is already registered'), findsOneWidget);
  }, skip: true);
}
