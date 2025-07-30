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

class PassAuthRepository implements AuthRepository {
  @override
  Future<bool> isEmailAvailable(String email) async => true;
}

class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {}

class _FakeAnalyticsService extends AnalyticsService {
  _FakeAnalyticsService() : super(FakeFirebaseAnalytics());
}

void main() {
  testWidgets('missing consent shows error', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hibpServiceProvider.overrideWith((ref) => FakeHIBPService()),
          recaptchaServiceProvider.overrideWith(
            (ref) => FakeRecaptchaService(),
          ),
          authRepositoryProvider.overrideWith((ref) => PassAuthRepository()),
          analyticsServiceProvider.overrideWith(
            (ref) => _FakeAnalyticsService(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('hu'),
          home: RegisterWizard(),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Test123!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Folytatás'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Folytatás'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Hiányos adatok, kérlek töltsd ki!'), findsOneWidget);
    expect(find.byKey(const Key('avatarPicker')), findsNothing);
  }, skip: true);
}
