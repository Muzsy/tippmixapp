import '../models/two_factor_type.dart';

class SecurityService {
  bool status;

  SecurityService() : status = false;

  Future<bool> enable(TwoFactorType type) async {
    status = true;
    return true;
  }

  Future<void> disable() async {
    status = false;
  }

  Future<bool> verifyOtp(String code) async {
    return code == '123456';
  }
}
