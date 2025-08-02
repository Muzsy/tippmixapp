import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/models/user.dart';

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
  fb.User? _currentUser;
  final _controller = StreamController<fb.User?>.broadcast();

  fb.FirebaseAuthException? signInException;
  fb.FirebaseAuthException? registerException;

  @override
  Stream<fb.User?> authStateChanges() => _controller.stream;

  @override
  fb.User? get currentUser => _currentUser;

  @override
  Future<fb.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (signInException != null) throw signInException!;
    _currentUser = FakeUser('u1', email: email, displayName: 'Test');
    _controller.add(_currentUser);
    return FakeUserCredential(_currentUser);
  }

  @override
  Future<fb.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (registerException != null) throw registerException!;
    _currentUser = FakeUser('u2', email: email, displayName: 'Reg');
    _controller.add(_currentUser);
    return FakeUserCredential(_currentUser);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}

class FakeFunctions extends Fake implements FirebaseFunctions {}

class FakeFacebook extends Fake implements FacebookAuth {}

class FakeFirebaseAppCheck extends Fake implements FirebaseAppCheck {}

void main() {
  group('AuthService', () {
    test('signInWithEmail returns user on success', () async {
      final auth = FakeFirebaseAuth();
      final service = AuthService(
        firebaseAuth: auth,
        functions: FakeFunctions(),
        facebookAuth: FakeFacebook(),
        appCheck: FakeFirebaseAppCheck(),
      );

      final user = await service.signInWithEmail('test@example.com', 'pw');

      expect(user, isA<User>());
      expect(user!.email, 'test@example.com');
    });

    test('signInWithEmail throws on wrong password', () async {
      final auth = FakeFirebaseAuth()
        ..signInException = fb.FirebaseAuthException(code: 'wrong-password');
      final service = AuthService(
        firebaseAuth: auth,
        functions: FakeFunctions(),
        facebookAuth: FakeFacebook(),
        appCheck: FakeFirebaseAppCheck(),
      );

      expect(
        () => service.signInWithEmail('a@test.com', 'pw'),
        throwsA(
          isA<AuthServiceException>().having(
            (e) => e.code,
            'code',
            'auth/wrong-password',
          ),
        ),
      );
    });

    test('signInWithEmail maps server error to unknown', () async {
      final auth = FakeFirebaseAuth()
        ..signInException = fb.FirebaseAuthException(code: 'internal-error');
      final service = AuthService(
        firebaseAuth: auth,
        functions: FakeFunctions(),
        facebookAuth: FakeFacebook(),
        appCheck: FakeFirebaseAppCheck(),
      );

      expect(
        () => service.signInWithEmail('a@test.com', 'pw'),
        throwsA(
          isA<AuthServiceException>().having(
            (e) => e.code,
            'code',
            'auth/unknown',
          ),
        ),
      );
    });

    test('authStateChanges emits user then null on signOut', () async {
      final auth = FakeFirebaseAuth();
      final service = AuthService(
        firebaseAuth: auth,
        functions: FakeFunctions(),
        facebookAuth: FakeFacebook(),
        appCheck: FakeFirebaseAppCheck(),
      );
      final emitted = <User?>[];

      final sub = service.authStateChanges().listen(emitted.add);

      await service.signInWithEmail('a@test.com', 'pw');
      await service.signOut();

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted.first, isA<User>());
      expect(emitted.last, isNull);
    });
  });
}
