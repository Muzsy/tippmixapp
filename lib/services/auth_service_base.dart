import '../models/user.dart';

/// Abstract auth contract used across the app.
abstract class AuthService {
  Stream<User?> authStateChanges();

  Future<User?> signInWithEmail(String email, String password);
  Future<User?> registerWithEmail(String email, String password);
  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
  Future<void> confirmPasswordReset(String code, String newPassword);
  Future<void> sendEmailVerification();
  Future<bool> pollEmailVerification({
    Duration timeout,
    Duration interval,
  });

  Future<User?> signInWithGoogle();
  Future<User?> signInWithFacebook();
  Future<User?> signInWithApple();

  // OTP email verification support
  Future<void> verifyEmailOtp(String email, String code);
  Future<void> resendSignupOtp(String email);

  bool get isEmailVerified;
  User? get currentUser;
}

// Személyre szabott Exception, lokalizációra kész
class AuthServiceException implements Exception {
  final String code;
  AuthServiceException(this.code);

  @override
  String toString() => code;
}
