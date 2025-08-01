import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/services/auth_repository.dart';
import 'package:tippmixapp/services/hibp_service.dart';
import 'package:tippmixapp/services/analytics_service.dart';
import 'package:tippmixapp/services/recaptcha_service.dart';
import 'package:tippmixapp/screens/register_step1_form.dart';
import 'package:tippmixapp/providers/auth_repository_provider.dart';
import 'package:tippmixapp/providers/hibp_service_provider.dart';
import 'package:tippmixapp/providers/recaptcha_service_provider.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class _MockRepo extends Mock implements AuthRepository {}
class _MockHIBP extends Mock implements HIBPService {}
class _MockAnalytics extends Mock implements AnalyticsService {}
class _MockRecaptcha extends Mock implements RecaptchaService {}

void main() {
  testWidgets('taken email shows snackbar', (t) async {
    final repo = _MockRepo();
    final hibp = _MockHIBP();
    final analytics = _MockAnalytics();
    final recaptcha = _MockRecaptcha();

    when(() => repo.isEmailAvailable(any())).thenAnswer((_) async => false);
    when(() => hibp.isPasswordPwned(any())).thenAnswer((_) async => false);
    when(() => analytics.logRegPasswordPwned()).thenAnswer((_) async {});
    when(() => recaptcha.execute()).thenAnswer((_) async => 'token');
    when(() => recaptcha.verifyToken(any())).thenAnswer((_) async => true);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => repo),
          hibpServiceProvider.overrideWith((ref) => hibp),
          analyticsServiceProvider.overrideWith((ref) => analytics),
          recaptchaServiceProvider.overrideWith((ref) => recaptcha),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('hu'),
          home: Scaffold(body: RegisterStep1Form()),
        ),
      ),
    );
    await t.enterText(find.byType(TextFormField).at(0), 'taken@x.com');
    await t.enterText(find.byType(TextFormField).at(1), 'ValidPass123!');
    await t.pump();
    await t.tap(find.byType(ElevatedButton));
    await t.pump(const Duration(milliseconds: 350));
    await t.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
