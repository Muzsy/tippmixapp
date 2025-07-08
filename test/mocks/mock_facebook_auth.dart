import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class MockFacebookAuth extends FacebookAuth {
  LoginResult result;
  MockFacebookAuth(this.result);

  @override
  Future<LoginResult> login() async => result;
}
