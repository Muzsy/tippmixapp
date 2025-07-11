import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:clock/clock.dart';
import 'package:tippmixapp/services/hibp_service.dart';

void main() {
  test('returns true when suffix found', () async {
    final hashSuffix = 'C6008F9CAB4083784CBD1874F76618D2A97';
    final client = MockClient((request) async {
      return http.Response('$hashSuffix:1', 200);
    });
    final service = HIBPService(
      client: client,
      clockOverride: Clock.fixed(DateTime(2023)),
    );
    final result = await service.isPasswordPwned('password123');
    expect(result, isTrue);
  });

  test('returns false when not found', () async {
    final client = MockClient((request) async {
      return http.Response('ABC:2', 200);
    });
    final service = HIBPService(
      client: client,
      clockOverride: Clock.fixed(DateTime(2023)),
    );
    final result = await service.isPasswordPwned('password123');
    expect(result, isFalse);
  });
}
