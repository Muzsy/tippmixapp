import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/services/auth_service.dart';

class FakeAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _current;

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    final user = User(id: '1', email: email, displayName: 'Test');
    _current = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<User?> registerWithEmail(String email, String password) async {
    return signInWithEmail(email, password);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  bool get isEmailVerified => true;

  @override
  User? get currentUser => _current;
  @override
  Future<bool> validateEmailUnique(String email) async => true;
  @override
  Future<bool> validateNicknameUnique(String nickname) async => true;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;
  @override
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async => true;
  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
}

void main() {
  test('login updates state with user', () async {
    final service = FakeAuthService();
    final notifier = AuthNotifier(service);

    await notifier.login('test@example.com', 'password');

    expect(notifier.state.user, isNotNull);
    expect(notifier.state.user!.email, 'test@example.com');
  });

  test('logout clears user state', () async {
    final service = FakeAuthService();
    final notifier = AuthNotifier(service);
    await notifier.login('test@example.com', 'password');

    await notifier.logout();

    expect(notifier.state.user, isNull);
  });
}
