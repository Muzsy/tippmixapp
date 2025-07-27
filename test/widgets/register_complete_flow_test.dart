import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/register_state_notifier.dart';
import 'package:tippmixapp/screens/register_step3_form.dart';
import 'package:tippmixapp/services/auth_service.dart';
import '../mocks/mock_auth_service.dart';

class FakeRegisterNotifier extends RegisterStateNotifier {
  final AuthService auth;
  FakeRegisterNotifier(this.auth) : super(auth) {
    state = state.copyWith(
      email: 'user@test.com',
      password: 'Password1!',
      nickname: 'tester',
      gdprConsent: true,
    );
  }

  @override
  Future<void> completeRegistration() async {
    await auth.registerWithEmail(state.email, state.password);
  }
}

void main() {
  testWidgets('finish button triggers register log', (tester) async {
    final mockAuth = MockAuthService();
    final logs = <String>[];
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'register',
          builder: (context, state) => const RegisterStep3Form(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const Placeholder(),
        ),
      ],
    );
    await runZoned(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
            registerStateNotifierProvider.overrideWith((ref) => FakeRegisterNotifier(mockAuth)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Finish'));
      await tester.pumpAndSettle();
    }, zoneSpecification: ZoneSpecification(print: (self, parent, zone, String msg) {
      logs.add(msg);
    }));

    expect(logs.any((l) => l.contains('[REGISTER] STARTED')), isTrue);
    expect(logs.any((l) => l.contains('[REGISTER] SUCCESS')), isTrue);
  });
}
