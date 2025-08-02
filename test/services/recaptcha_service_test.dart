import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tippmixapp/services/recaptcha_service.dart';

void main() {
  test('returns true for success score', () async {
    final client = MockClient((request) async {
      return http.Response('{"success":true,"score":0.9}', 200);
    });
    final service = RecaptchaService(
      secret: 's',
      client: client,
      bypassDebug: true,
    );
    final result = await service.verifyToken('t');
    expect(result, isTrue);
  });

  test('returns false on low score', () async {
    final client = MockClient((request) async {
      return http.Response('{"success":true,"score":0.1}', 200);
    });
    final service = RecaptchaService(
      secret: 's',
      client: client,
      bypassDebug: true,
    );
    final result = await service.verifyToken('t');
    expect(result, isFalse);
  });
}
