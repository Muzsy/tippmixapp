import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tippmixapp/ui/auth/auth_gate.dart';
import 'package:tippmixapp/ui/auth/email_not_verified_screen.dart';
import 'package:tippmixapp/providers/onboarding_provider.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  testWidgets('unverified user redirected', (tester) async {
    final mockUser = MockUser();
    when(() => mockUser.emailVerified).thenReturn(false);
    final mockAuth = MockFirebaseAuth();
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        child: const MaterialApp(home: AuthGate()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EmailNotVerifiedScreen), findsOneWidget);
  });
}
