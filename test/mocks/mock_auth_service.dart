import 'dart:async';
import 'package:tipsterino/services/auth_service_base.dart';
import 'package:tipsterino/models/user.dart';

class MockAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _user;

  String? sentEmail;
  String? confirmCode;
  String? confirmPassword;

  bool emailUnique = true;
  bool nicknameUnique = true;
  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    _user = User(id: 'u1', email: email, displayName: 'Test');
    _controller.add(_user);
    return _user;
  }

  @override
  Future<User?> registerWithEmail(String email, String password) async {
    // ignore: avoid_print
    print('[REGISTER] STARTED');
    // ignore: avoid_print
    print('[REGISTER] registerWithEmail STARTED');
    _user = User(id: 'u1', email: email, displayName: 'Test');
    _controller.add(_user);
    // ignore: avoid_print
    print('[REGISTER] SUCCESS');
    return _user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    sentEmail = email;
  }

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    confirmCode = code;
    confirmPassword = newPassword;
  }

  @override
  bool get isEmailVerified => true;

  @override
  User? get currentUser => _user;
  @override
  Future<bool> validateEmailUnique(String email) async => emailUnique;

  @override
  Future<bool> validateNicknameUnique(String nickname) async => nicknameUnique;

  // reserveNickname removed from AuthService interface – no-op here

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
}
