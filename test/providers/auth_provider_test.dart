import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/services/auth_service.dart';

class ThrowingAuthService implements AuthService {
  final String code;
  ThrowingAuthService(this.code);

  @override
  Stream<User?> authStateChanges() => const Stream.empty();

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    throw AuthServiceException(code);
  }

  @override
  Future<User?> registerWithEmail(String email, String password) async {
    throw AuthServiceException(code);
  }

  @override
  Future<void> signOut() async {}

  @override
  User? get currentUser => null;
}

void main() {
  test('login returns error code and updates state', () async {
    final notifier = AuthNotifier(ThrowingAuthService('auth/wrong-password'));
    final code = await notifier.login('a@a.hu', 'pw');
    expect(code, 'auth/wrong-password');
    expect(notifier.state.errorCode, 'auth/wrong-password');
    expect(notifier.state.user, isNull);
  });

  test('register returns error code and updates state', () async {
    final notifier = AuthNotifier(ThrowingAuthService('auth/user-not-found'));
    final code = await notifier.register('a@a.hu', 'pw');
    expect(code, 'auth/user-not-found');
    expect(notifier.state.errorCode, 'auth/user-not-found');
    expect(notifier.state.user, isNull);
  });
}
