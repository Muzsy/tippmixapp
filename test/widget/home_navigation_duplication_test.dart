import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tippmixapp/router.dart';
import 'package:tippmixapp/providers/onboarding_provider.dart';
import '../mocks/mock_splash_controller.dart';
import 'package:tippmixapp/controllers/splash_controller.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  testWidgets('Home route has single AppBar and BottomNavigationBar', (
    tester,
  ) async {
    final mockUser = MockUser();
    when(() => mockUser.emailVerified).thenReturn(true);
    final mockAuth = MockFirebaseAuth();
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
          splashControllerProvider.overrideWith(
            (ref) => MockSplashController(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
