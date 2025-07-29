// Cloud Functions import eltávolítva – nincs többé szükség
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Thrown when the checked email already exists in backend.
class EmailAlreadyInUseFailure implements Exception {}

/// Repository handling auth related network calls.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Returns `true` if the email does not exist yet.
  ///
  /// Throws [EmailAlreadyInUseFailure] when the backend
  /// responds with HTTP 409 or `already-exists` code.
  Future<bool> isEmailAvailable(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isEmpty; // true ⇒ szabad e‑mail
    } on FirebaseAuthException catch (e) {
      // Offline vagy egyéb hiba → fail-open, de logoljuk
      if (kDebugMode) {
        // ignore: avoid_print
        print('[EMAIL_CHECK] fetchSignInMethods error: ${e.code}');
      }
      return true; // ne blokkoljuk a flow‑t
    }
  }
}
