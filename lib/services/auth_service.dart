import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  final fb.FirebaseAuth _firebaseAuth;
  final FacebookAuth _facebookAuth;
  final FirebaseFunctions _functions;

  AuthService({
    fb.FirebaseAuth? firebaseAuth,
    FacebookAuth? facebookAuth,
    FirebaseFunctions? functions,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _facebookAuth = facebookAuth ?? FacebookAuth.instance,
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'europe-central2');

  // Stream a bejelentkezési állapot figyelésére
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((fb.User? firebaseUser) {
      if (firebaseUser == null) return null;
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
      );
    });
  }

  // Bejelentkezés email/jelszóval
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) return null;
      return User(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthServiceException(_firebaseErrorToCode(e));
    }
  }

  // Google sign-in using google_sign_in for a smoother UX
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final GoogleSignInClientAuthorization authz =
          await googleUser.authorizationClient.authorizeScopes(<String>['email']);

      final credential = fb.GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _firebaseAuth.signInWithCredential(credential);
      final user = cred.user;
      if (user == null) return null;
      return User(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthServiceException(_firebaseErrorToCode(e));
    }
  }

  // Apple sign-in
  Future<User?> signInWithApple() async {
    if (kIsWeb) throw UnsupportedError('Apple sign-in not supported on web');
    try {
      final cred = await _firebaseAuth.signInWithProvider(
        fb.AppleAuthProvider(),
      );
      final user = cred.user;
      if (user == null) return null;
      return User(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthServiceException(_firebaseErrorToCode(e));
    }
  }

  // Facebook sign-in using flutter_facebook_auth
  Future<User?> signInWithFacebook() async {
    try {
      final res = await _facebookAuth.login();
      if (res.status == LoginStatus.success) {
        final credential =
            fb.FacebookAuthProvider.credential(res.accessToken!.token);
        final cred = await _firebaseAuth.signInWithCredential(credential);
        final user = cred.user;
        if (user == null) return null;
        return User(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
        );
      } else if (res.status == LoginStatus.cancelled) {
        throw AuthServiceException('auth/facebook-cancelled');
      } else {
        throw AuthServiceException('auth/unknown');
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthServiceException(_firebaseErrorToCode(e));
    }
  }

  // Regisztráció email/jelszóval
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.sendEmailVerification();
      final user = cred.user;
      if (user == null) return null;
      return User(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthServiceException(_firebaseErrorToCode(e));
    }
  }

  Future<bool> validateEmailUnique(String email) async {
    final callable = _functions.httpsCallable('checkEmailUnique');
    try {
      final result =
          await callable.call<Map<String, dynamic>>({'email': email});
      return result.data['unique'] as bool? ?? true;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        if (kDebugMode) {
          // ignore: avoid_print
          print('validateEmailUnique permission-denied, assuming unique');
        }
        return true;
      }
      rethrow;
    } on TimeoutException {
      if (kDebugMode) {
        // ignore: avoid_print
        print('validateEmailUnique timeout, assuming unique');
      }
      return true;
    }
  }

  Future<bool> validateNicknameUnique(String nickname) async {
    final callable = _functions.httpsCallable('checkNicknameUnique');
    try {
      final result =
          await callable.call<Map<String, dynamic>>({'nickname': nickname});
      return result.data['unique'] as bool? ?? true;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        if (kDebugMode) {
          // ignore: avoid_print
          print('validateNicknameUnique permission-denied, assuming unique');
        }
        return true;
      }
      rethrow;
    } on TimeoutException {
      if (kDebugMode) {
        // ignore: avoid_print
        print('validateNicknameUnique timeout, assuming unique');
      }
      return true;
    }
  }

  // Kijelentkezés
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Verifikációs email küldése
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async {
    var user = _firebaseAuth.currentUser;
    if (user == null) return false;
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await _firebaseAuth.currentUser?.reload();
      user = _firebaseAuth.currentUser;
      if (user?.emailVerified ?? false) {
        return true;
      }
      await Future.delayed(interval);
    }
    return user?.emailVerified ?? false;
  }

  // Jelszó visszaállító email küldése
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> confirmPasswordReset(String code, String newPassword) async {
    await _firebaseAuth.confirmPasswordReset(
      code: code,
      newPassword: newPassword,
    );
  }

  // Email cím ellenőrzöttsége
  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  // Aktuális user lekérdezése (ha van)
  User? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return User(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    );
  }

  // Hibakódok lokalizált visszaadására
  String _firebaseErrorToCode(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'auth/user-not-found';
      case 'wrong-password':
        return 'auth/wrong-password';
      case 'email-already-in-use':
        return 'auth/email-already-in-use';
      case 'invalid-email':
        return 'auth/invalid-email';
      case 'weak-password':
        return 'auth/weak-password';
      default:
        return 'auth/unknown';
    }
  }
}

// Személyre szabott Exception, lokalizációra kész
class AuthServiceException implements Exception {
  final String code;
  AuthServiceException(this.code);

  @override
  String toString() => code;
}
