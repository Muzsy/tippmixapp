import '../models/user.dart';

class AuthState {
  final User? user;
  final String? errorCode;

  const AuthState({this.user, this.errorCode});
}
