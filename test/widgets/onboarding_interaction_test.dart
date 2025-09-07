import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/screens/onboarding/onboarding_flow_screen.dart';
import 'package:tipsterino/providers/onboarding_provider.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/services/user_service.dart';
import 'package:tipsterino/services/analytics_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

// ignore: subtype_of_sealed_class
class FakeUser extends Fake implements fb.User {
  @override
  final String uid;
  FakeUser(this.uid);
}

// ignore: subtype_of_sealed_class
class FakeFirebaseAuth extends Fake implements fb.FirebaseAuth {
  FakeFirebaseAuth(this._user);
  final fb.User? _user;

  @override
  fb.User? get currentUser => _user;
}

class FakeUserService extends Fake implements UserService {
  int calls = 0;
  @override
  Future<void> markOnboardingCompleted(String uid) async {
    calls++;
  }
}

class FakeAnalyticsService extends Fake implements AnalyticsService {
  int completed = 0;
  int skipped = 0;
  @override
  Future<void> logOnboardingCompleted(Duration duration) async {
    completed++;
  }

  @override
  Future<void> logOnboardingSkipped(Duration duration) async {
    skipped++;
  }
}

void main() {
  testWidgets('complete onboarding triggers service', (tester) async {
    final fakeUser = FakeUserService();
    final fakeAnalytics = FakeAnalyticsService();
    final fakeAuth = FakeFirebaseAuth(FakeUser('u1'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userServiceProvider.overrideWithValue(fakeUser),
          analyticsServiceProvider.overrideWithValue(fakeAnalytics),
          firebaseAuthProvider.overrideWithValue(fakeAuth),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: OnboardingFlowScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(fakeUser.calls, 1);
    expect(fakeAnalytics.completed, 1);
  });
}
