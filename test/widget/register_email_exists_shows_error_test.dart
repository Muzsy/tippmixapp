import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/screens/register_wizard.dart';
import 'package:tippmixapp/services/auth_repository.dart';
import 'package:tippmixapp/services/hibp_service.dart';
import 'package:tippmixapp/services/recaptcha_service.dart';
import 'package:tippmixapp/services/analytics_service.dart';
import 'package:tippmixapp/providers/auth_repository_provider.dart';
import 'package:tippmixapp/providers/hibp_service_provider.dart';
import 'package:tippmixapp/providers/recaptcha_service_provider.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import '../mocks/mock_auth_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class _MockRepo extends Mock implements AuthRepository {}

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

class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {}

class _FakeAnalyticsService extends AnalyticsService {
  _FakeAnalyticsService() : super(FakeFirebaseAnalytics());
}

void main() {
  testWidgets('email exists shows snackbar', (t) async {
    final repo = _MockRepo();
    registerFallbackValue('');
    when(
      () => repo.isEmailAvailable(any()),
    ).thenThrow(EmailAlreadyInUseFailure());
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          hibpServiceProvider.overrideWith((ref) => FakeHIBPService()),
          recaptchaServiceProvider.overrideWith((ref) => FakeRecaptchaService()),
          authServiceProvider.overrideWith((ref) => MockAuthService()),
          analyticsServiceProvider.overrideWith(
            (ref) => _FakeAnalyticsService(),
          ),
          authRepositoryProvider.overrideWith((ref) => repo),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('hu'),
          home: RegisterWizard(),
        ),
      ),
    );
    await t.enterText(find.byType(TextFormField).first, 'taken@x.com');
    await t.enterText(find.byType(TextFormField).at(1), 'Teszt123456!');
    await t.pump(const Duration(milliseconds: 350));
    await t.tap(find.widgetWithText(ElevatedButton, 'Folytatás'));
    await t.pump(const Duration(milliseconds: 450));
    await t.pumpAndSettle();
    final loc = AppLocalizations.of(t.element(find.byType(RegisterWizard)))!;
    expect(find.text(loc.errorEmailExists), findsOneWidget);
  });
}
