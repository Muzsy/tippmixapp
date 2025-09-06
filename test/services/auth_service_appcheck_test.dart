import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tipsterino/services/auth_service.dart';

class _FailingAppCheck extends Fake implements FirebaseAppCheck {
  @override
  Future<String?> getToken([bool? autoRefresh = false]) {
    return Future.error(
      FirebaseException(plugin: 'firebase_app_check', code: '403'),
    );
  }
}

class _FakeFirebaseAuth extends Fake implements fb.FirebaseAuth {
  final fb.UserCredential credential;

  _FakeFirebaseAuth(this.credential);

  @override
  Future<fb.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return credential;
  }
}

class _MockUserCredential extends Mock implements fb.UserCredential {}

class FakeUser extends Fake implements fb.User {
  @override
  String get uid => 'uid';

  @override
  String? get email => 'user@test.com';

  @override
  String? get displayName => 'User';

  @override
  Future<void> sendEmailVerification([
    fb.ActionCodeSettings? actionCodeSettings,
  ]) async {}
}

class FakeHttpsCallable extends Fake implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    return FakeHttpsCallableResult<T>(null as T);
  }
}

class FakeHttpsCallableResult<T> implements HttpsCallableResult<T> {
  @override
  final T data;
  FakeHttpsCallableResult(this.data);
}

class FakeFirebaseFunctions extends Fake implements FirebaseFunctions {
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return FakeHttpsCallable();
  }
}

void main() {
  group('AuthService.registerWithEmail', () {
    test('does not throw if getToken() fails', () async {
      final cred = _MockUserCredential();
      final mockAuth = _FakeFirebaseAuth(cred);
      final failingAppCheck = _FailingAppCheck();
      final user = FakeUser();
      when(cred.user).thenReturn(user);

      final service = AuthService(
        firebaseAuth: mockAuth,
        appCheck: failingAppCheck,
        functions: FakeFirebaseFunctions(),
      );

      await expectLater(
        () => service.registerWithEmail('a@b.c', 'pw123456'),
        returnsNormally,
      );
    });
  });
}
