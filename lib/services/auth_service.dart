import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthService {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService({fb.FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

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

  // Google sign-in
  Future<User?> signInWithGoogle() async {
    try {
      final cred = await _firebaseAuth.signInWithProvider(
        fb.GoogleAuthProvider(),
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

  // Facebook sign-in
  Future<User?> signInWithFacebook() async {
    try {
      final cred = await _firebaseAuth.signInWithProvider(
        fb.FacebookAuthProvider(),
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

  // Regisztráció email/jelszóval
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
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

  Future<bool> validateEmailUnique(String email) async {
    final query = await _firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  Future<bool> validateNicknameUnique(String nickname) async {
    final query = await _firestore
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .limit(1)
        .get();
    return query.docs.isEmpty;
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
