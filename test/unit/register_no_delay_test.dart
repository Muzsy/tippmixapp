import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tipsterino/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_functions/cloud_functions.dart';

class _MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class _MockAppCheck extends Mock implements FirebaseAppCheck {}

class _FakeFunctions extends Fake implements FirebaseFunctions {
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    throw UnimplementedError();
  }
}

class _FakeUserCredential extends Fake implements fb.UserCredential {
  @override
  fb.User? get user => null;
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUserCredential());
  });

  test('registerWithEmail completes quickly without artificial delay', () {
    fakeAsync((async) {
      final mockAuth = _MockFirebaseAuth();
      final mockAppCheck = _MockAppCheck();
      when(() => mockAppCheck.getToken(true)).thenAnswer((_) async => 'token');
      when(
        () => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _FakeUserCredential());
      final service = AuthService(
        firebaseAuth: mockAuth,
        appCheck: mockAppCheck,
        functions: _FakeFunctions(),
      );
      var completed = false;
      service
          .registerWithEmail('a@b.com', 'Secret123')
          .then((_) => completed = true);
      async.elapse(const Duration(milliseconds: 80));
      expect(completed, isTrue);
    });
  });
}
