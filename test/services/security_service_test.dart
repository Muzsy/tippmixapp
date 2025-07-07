import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/services/security_service.dart';
import 'package:tippmixapp/models/two_factor_type.dart';

void main() {
  test('verifyOtp returns true for 123456', () async {
    final service = SecurityService();
    final result = await service.verifyOtp('123456');
    expect(result, isTrue);
  });

  test('enable sets status', () async {
    final service = SecurityService();
    expect(service.status, isFalse);
    await service.enable(TwoFactorType.sms);
    expect(service.status, isTrue);
  });
}
