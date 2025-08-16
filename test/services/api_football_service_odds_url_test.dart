import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tippmixapp/services/api_football_service.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_FOOTBALL_KEY=dummy');
  });

  test('odds URL tartalmazza a season és bet=1 paramétert', () async {
    late Uri captured;
    final client = MockClient((req) async {
      captured = req.url;
      return http.Response(jsonEncode({'response': []}), 200);
    });
    final s = ApiFootballService(client);
    await s.getOddsForFixture('12345', season: 2024);
    expect(captured.queryParameters['fixture'], '12345');
    expect(captured.queryParameters['season'], '2024');
    expect(captured.queryParameters['bet'], '1');
  });
}
