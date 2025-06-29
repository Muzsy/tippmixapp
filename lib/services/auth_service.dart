import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user.dart';

class AuthService {
  final fb.FirebaseAuth _firebaseAuth;

  AuthService({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

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

  // Kijelentkezés
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

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
