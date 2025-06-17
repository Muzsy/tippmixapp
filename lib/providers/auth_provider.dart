import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthNotifier extends StateNotifier<User?> {
  final AuthService _authService;
  late final Stream<User?> _authStateStream;
  late final StreamSubscription<User?> _streamSub;

  AuthNotifier(this._authService) : super(null) {
    _authStateStream = _authService.authStateChanges();
    _streamSub = _authStateStream.listen((user) {
      state = user;
    });
  }

  /// Publikus getter – main.dart, GoRouter miatt
  Stream<User?> get authStateStream => _authStateStream;

  // Belépés
  Future<void> login(String email, String password) async {
    try {
      final user = await _authService.signInWithEmail(email, password);
      state = user;
    } on AuthServiceException catch (_) {
      rethrow;
    }
  }

  // Regisztráció
  Future<void> register(String email, String password) async {
    try {
      final user = await _authService.registerWithEmail(email, password);
      state = user;
    } on AuthServiceException catch (_) {
      rethrow;
    }
  }

  // Kijelentkezés
  Future<void> logout() async {
    await _authService.signOut();
    state = null;
  }

  @override
  void dispose() {
    _streamSub.cancel();
    super.dispose();
  }
}
