import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:tippmixapp/services/auth_service.dart';

class _MockAppCheck extends Mock implements FirebaseAppCheck {}

class _MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class _MockUserCredential extends Mock implements fb.UserCredential {}

class _MockUser extends Mock implements fb.User {}

void main() {
  group('AuthService.registerWithEmail', () {
    test('does not throw if getToken() fails', () async {
      final mockAuth = _MockFirebaseAuth();
      final mockAppCheck = _MockAppCheck();
      when(
        mockAppCheck.getToken(any),
      ).thenThrow(FirebaseException(plugin: 'firebase_app_check', code: '403'));

      final cred = _MockUserCredential();
      final user = _MockUser();
      when(cred.user).thenReturn(user);
      when(
        mockAuth.createUserWithEmailAndPassword(
          email: 'a@b.c',
          password: 'pw123456',
        ),
      ).thenAnswer((_) async => cred);

      final service = AuthService(
        firebaseAuth: mockAuth,
        appCheck: mockAppCheck,
      );

      await expectLater(
        () => service.registerWithEmail('a@b.c', 'pw123456'),
        returnsNormally,
      );
    });
  });
}
