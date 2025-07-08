enum LoginStatus { success, cancelled, failed }

class AccessToken {
  final String token;
  AccessToken(this.token);
}

class LoginResult {
  final LoginStatus status;
  final AccessToken? accessToken;
  LoginResult(this.status, {this.accessToken});
}

class FacebookAuth {
  static FacebookAuth instance = FacebookAuth();

  Future<LoginResult> login() async {
    // Placeholder implementation used in tests.
    return LoginResult(LoginStatus.cancelled);
  }
}
