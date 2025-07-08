import 'dart:async';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/models/user.dart';

class MockAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _user;

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
  Future<User?> registerWithEmail(String email, String password) async => null;

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  bool get isEmailVerified => true;

  @override
  User? get currentUser => _user;
  @override
  Future<bool> validateEmailUnique(String email) async => emailUnique;

  @override
  Future<bool> validateNicknameUnique(String nickname) async => nicknameUnique;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;
}
