import '../models/user.dart';
import 'auth_service_base.dart';

/// Fallback AuthService, ha Supabase nincs konfigurálva a buildben.
class NoopAuthService extends AuthService {
  @override
  Stream<User?> authStateChanges() async* {
    yield null;
  }

  @override
  Future<User?> registerWithEmail(String email, String password) async => null;

  @override
  Future<User?> signInWithEmail(String email, String password) async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<bool> pollEmailVerification({Duration timeout = const Duration(minutes: 3), Duration interval = const Duration(seconds: 5)}) async => true;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  bool get isEmailVerified => false;

  @override
  User? get currentUser => null;

  @override
  Future<void> resendSignupOtp(String email) async {}

  @override
  Future<void> verifyEmailOtp(String email, String code) async {}
}
