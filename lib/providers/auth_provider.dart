import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth_service_supabase.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  final useSupabase = dotenv.env['USE_SUPABASE']?.toLowerCase() == 'true';
  if (useSupabase) {
    return AuthServiceSupabaseAdapter();
  }
  return AuthService();
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

  bool get isEmailVerified => _authService.isEmailVerified;

  @override
  void dispose() {
    _streamSub.cancel();
    super.dispose();
  }
}
