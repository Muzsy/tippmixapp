import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:tippmixapp/services/auth_service.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../mocks/mock_facebook_auth.dart';

// ignore: subtype_of_sealed_class
class FakeUser extends Fake implements fb.User {
  @override
  final String uid;
  @override
  String? email;
  @override
  String? displayName;
  FakeUser(this.uid, {this.email, this.displayName});
}

// ignore: subtype_of_sealed_class
class FakeUserCredential extends Fake implements fb.UserCredential {
  final fb.User? _user;
  FakeUserCredential(this._user);
  @override
  fb.User? get user => _user;
}

// ignore: subtype_of_sealed_class
class FakeFirebaseAuth extends Fake implements fb.FirebaseAuth {
  fb.UserCredential? credential;
  @override
  Future<fb.UserCredential> signInWithCredential(
    fb.AuthCredential credential,
  ) async {
    return this.credential!;
  }
}

class FakeFunctions extends Fake implements FirebaseFunctions {}

class FakeFirebaseAppCheck extends Fake implements FirebaseAppCheck {}

void main() {
  test('signInWithFacebook returns user when login success', () async {
    final fbAuth = FakeFirebaseAuth();
    final user = FakeUser('u1', email: 'a@b.c');
    fbAuth.credential = FakeUserCredential(user);
    final service = AuthService(
      firebaseAuth: fbAuth,
      facebookAuth: MockFacebookAuth(
        LoginResult(LoginStatus.success, accessToken: AccessToken('t')),
      ),
      functions: FakeFunctions(),
      appCheck: FakeFirebaseAppCheck(),
    );

    final result = await service.signInWithFacebook();

    expect(result, isNotNull);
    expect(result!.id, 'u1');
  });

  test('signInWithFacebook throws when cancelled', () async {
    final fbAuth = FakeFirebaseAuth()
      ..credential = FakeUserCredential(FakeUser('u1'));
    final service = AuthService(
      firebaseAuth: fbAuth,
      facebookAuth: MockFacebookAuth(LoginResult(LoginStatus.cancelled)),
      functions: FakeFunctions(),
      appCheck: FakeFirebaseAppCheck(),
    );

    expect(
      () => service.signInWithFacebook(),
      throwsA(
        isA<AuthServiceException>().having(
          (e) => e.code,
          'code',
          'auth/facebook-cancelled',
        ),
      ),
    );
  });
}
