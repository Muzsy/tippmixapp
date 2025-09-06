import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/register_state_notifier.dart';
import 'package:tipsterino/screens/register_wizard.dart';
import '../mocks/mock_auth_service.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/hibp_service_provider.dart';
import 'package:tipsterino/providers/recaptcha_service_provider.dart';
import 'package:tipsterino/providers/auth_repository_provider.dart';
import 'package:tipsterino/services/hibp_service.dart';
import 'package:tipsterino/services/recaptcha_service.dart';
import 'package:tipsterino/services/auth_repository.dart';
import 'package:tipsterino/services/analytics_service.dart';
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

class FakeAuthRepository implements AuthRepository {
  @override
  Future<bool> isEmailAvailable(String email) async => true;
}

class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {}

class _FakeAnalyticsService extends AnalyticsService {
  _FakeAnalyticsService() : super(FakeFirebaseAnalytics());
}

void main() {
  testWidgets('entering valid data enables continue and navigates', (
    tester,
  ) async {
    final mockAuth = MockAuthService();
    mockAuth.emailUnique = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
          hibpServiceProvider.overrideWith((ref) => FakeHIBPService()),
          recaptchaServiceProvider.overrideWith(
            (ref) => FakeRecaptchaService(),
          ),
          authRepositoryProvider.overrideWith((ref) => FakeAuthRepository()),
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
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'ValidPass!123');
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(RegisterWizard)),
    );
    final data = container.read(registerStateNotifierProvider);
    expect(data.email, 'user@example.com');
    expect(find.byKey(const Key('nicknameField')), findsOneWidget);
  });
}
