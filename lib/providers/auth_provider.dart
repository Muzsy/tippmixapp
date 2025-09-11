import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/auth_state.dart';
import '../services/auth_service_base.dart';
import '../services/auth_service_supabase.dart';
import '../env/env.dart';
import '../services/auth_service_noop.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  // Ha nincs Supabase konfiguráció (pl. .env asset nélkül), ne dőljön el induláskor.
  if (!Env.isSupabaseConfigured) return NoopAuthService();
  return AuthServiceSupabaseAdapter();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  late final Stream<User?> _authStateStream;
  late final StreamSubscription<User?> _streamSub;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _authStateStream = _authService.authStateChanges();
    _streamSub = _authStateStream.listen((user) {
      state = AuthState(user: user);
    });
  }

  /// Publikus getter – main.dart, GoRouter miatt
  Stream<User?> get authStateStream => _authStateStream;

  // Belépés
  Future<String?> login(String email, String password) async {
    try {
      final user = await _authService.signInWithEmail(email, password);
      state = AuthState(user: user);
      return null;
    } on AuthServiceException catch (e) {
      state = AuthState(errorCode: e.code);
      return e.code;
    }
  }

  // Regisztráció
  Future<String?> register(String email, String password) async {
    try {
      final user = await _authService.registerWithEmail(email, password);
      state = AuthState(user: user);
      await _authService.sendEmailVerification();
      await _authService.pollEmailVerification();
      return null;
    } on AuthServiceException catch (e) {
      state = AuthState(errorCode: e.code);
      return e.code;
    }
  }

  // Kijelentkezés
  Future<void> logout() async {
    await _authService.signOut();
    state = const AuthState(user: null);
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  // OTP verification flow
  Future<String?> requestVerifyEmailOtp(String email, String code) async {
    try {
      await _authService.verifyEmailOtp(email, code);
      // After successful verification, refresh state if session established
      state = AuthState(user: _authService.currentUser);
      return null;
    } on AuthServiceException catch (e) {
      state = AuthState(user: state.user, errorCode: e.code);
      return e.code;
    } catch (_) {
      return 'auth/unknown';
    }
  }

  Future<String?> resendSignupOtp(String email) async {
    try {
      await _authService.resendSignupOtp(email);
      return null;
    } on AuthServiceException catch (e) {
      return e.code;
    } catch (_) {
      return 'auth/unknown';
    }
  }

  bool get isEmailVerified => _authService.isEmailVerified;

  @override
  void dispose() {
    _streamSub.cancel();
    super.dispose();
  }
}
