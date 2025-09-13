import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/user.dart';
import 'auth_service_base.dart';

/// Auth adapter, a meglévő AuthService API-t biztosítja Supabase alatt.
class AuthServiceSupabaseAdapter extends AuthService {
  AuthServiceSupabaseAdapter({sb.SupabaseClient? client}) : _client = client;

  final sb.SupabaseClient? _client;

  sb.SupabaseClient get _c => _client ?? sb.Supabase.instance.client;

  @override
  Stream<User?> authStateChanges() {
    final ctrl = StreamController<User?>.broadcast();
    ctrl.add(_mapUser(_c.auth.currentUser));
    final sub = _c.auth.onAuthStateChange.listen((data) {
      ctrl.add(_mapUser(data.session?.user));
    });
    ctrl.onCancel = () => sub.cancel();
    return ctrl.stream;
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    final res = await _c.auth.signInWithPassword(email: email, password: password);
    final u = _mapUser(res.user);
    if (u != null) await _ensureProfile(u);
    return u;
  }

  @override
  Future<User?> registerWithEmail(String email, String password) async {
    final res = await _c.auth.signUp(email: email, password: password);
    final u = _mapUser(res.user);
    if (u != null) await _ensureProfile(u);
    return u;
  }

  @override
  Future<void> signOut() async {
    await _c.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _c.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    // Supabase: tipikusan magic linkkel történik, itt csak update, ha van session
    await _c.auth.updateUser(sb.UserAttributes(password: newPassword));
  }

  @override
  Future<void> sendEmailVerification() async {
    // Signupkor Supabase küld e-mailt; opcionálisan lehet resend-et hívni.
    try {
      final email = _c.auth.currentUser?.email;
      if (email != null && email.isNotEmpty) {
        await _c.auth.resend(type: sb.OtpType.signup, email: email);
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
        final res = await _c.auth.getUser();
        if (res.user?.emailConfirmedAt != null) return true;
      } catch (_) {}
    }
    return _c.auth.currentUser?.emailConfirmedAt != null;
  }

  // Nem támogatott social login hívások Supabase módban jelenleg
  @override
  Future<User?> signInWithGoogle() async {
    await _c.auth.signInWithOAuth(sb.OAuthProvider.google);
    return _mapUser(_c.auth.currentUser);
  }

  @override
  Future<User?> signInWithFacebook() async {
    await _c.auth.signInWithOAuth(sb.OAuthProvider.facebook);
    return _mapUser(_c.auth.currentUser);
  }

  @override
  Future<User?> signInWithApple() async {
    await _c.auth.signInWithOAuth(sb.OAuthProvider.apple);
    return _mapUser(_c.auth.currentUser);
  }

  @override
  Future<void> verifyEmailOtp(String email, String code) async {
    await _c.auth.verifyOTP(
      email: email,
      token: code,
      type: sb.OtpType.email,
    );
    // If no active session after verification, attempt sign-in with password is
    // deferred to the caller flow (login form) to avoid storing plaintext.
    final u = _mapUser(_c.auth.currentUser);
    if (u != null) {
      await _ensureProfile(u);
    }
  }

  @override
  Future<void> resendSignupOtp(String email) async {
    await _c.auth.resend(type: sb.OtpType.signup, email: email);
  }

  @override
  bool get isEmailVerified => (_c.auth.currentUser?.emailConfirmedAt) != null;

  @override
  User? get currentUser => _mapUser(_c.auth.currentUser);

  User? _mapUser(sb.User? u) => u == null
      ? null
      : User(
          id: u.id,
          email: u.email ?? '',
          displayName: u.userMetadata?['full_name'] as String? ?? '',
        );

  Future<void> _ensureProfile(User u) async {
    try {
      final fallback = (u.displayName.isNotEmpty)
          ? u.displayName
          : (u.email.isNotEmpty ? u.email.split('@').first : 'user_${u.id.substring(0,8)}');
      await _c.from('profiles').upsert({
        'id': u.id,
        'nickname': fallback,
      }, onConflict: 'id');
    } catch (_) {}
  }
}
