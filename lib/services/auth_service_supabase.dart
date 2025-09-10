import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/user.dart';
import 'auth_service.dart';

/// Auth adapter, a meglévő AuthService API-t biztosítja Supabase alatt.
class AuthServiceSupabaseAdapter extends AuthService {
  AuthServiceSupabaseAdapter({sb.SupabaseClient? client}) : _client = client ?? sb.Supabase.instance.client;

  final sb.SupabaseClient _client;

  @override
  Stream<User?> authStateChanges() {
    final ctrl = StreamController<User?>.broadcast();
    ctrl.add(_mapUser(_client.auth.currentUser));
    final sub = _client.auth.onAuthStateChange.listen((data) {
      ctrl.add(_mapUser(data.session?.user));
    });
    ctrl.onCancel = () => sub.cancel();
    return ctrl.stream;
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    return _mapUser(res.user);
  }

  @override
  Future<User?> registerWithEmail(String email, String password) async {
    final res = await _client.auth.signUp(email: email, password: password, emailRedirectTo: null);
    return _mapUser(res.user);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    // Supabase: tipikusan magic linkkel történik, itt csak update, ha van session
    await _client.auth.updateUser(sb.UserAttributes(password: newPassword));
  }

  @override
  Future<void> sendEmailVerification() async {
    // Signupkor Supabase küld e-mailt; opcionálisan lehet resend-et hívni.
    try {
      final email = _client.auth.currentUser?.email;
      if (email != null && email.isNotEmpty) {
        await _client.auth.resend(type: sb.OtpType.signup, email: email);
      }
    } catch (_) {}
  }

  @override
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await Future.delayed(interval);
      try {
        // Frissítsük az aktuális user-t
        final res = await _client.auth.getUser();
        if (res.user?.emailConfirmedAt != null) return true;
      } catch (_) {}
    }
    return _client.auth.currentUser?.emailConfirmedAt != null;
  }

  // Nem támogatott social login hívások Supabase módban jelenleg
  @override
  Future<User?> signInWithGoogle() async {
    throw AuthServiceException('auth/unsupported');
  }

  @override
  Future<User?> signInWithFacebook() async {
    throw AuthServiceException('auth/unsupported');
  }

  @override
  Future<User?> signInWithApple() async {
    throw AuthServiceException('auth/unsupported');
  }

  @override
  bool get isEmailVerified => (_client.auth.currentUser?.emailConfirmedAt) != null;

  @override
  User? get currentUser => _mapUser(_client.auth.currentUser);

  User? _mapUser(sb.User? u) => u == null
      ? null
      : User(
          id: u.id,
          email: u.email ?? '',
          displayName: u.userMetadata?['full_name'] as String? ?? '',
        );
}
