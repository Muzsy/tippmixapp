import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tippmixapp/services/api_football_service.dart';

void main() {
  test('kiválasztott dátum a service URL-ben', () async {
    dotenv.testLoad(fileInput: 'API_FOOTBALL_KEY=dummy');
    late Uri captured;
    final client = MockClient((req) async {
      captured = req.url;
      return http.Response(jsonEncode({'response': []}), 200);
    });
    final s = ApiFootballService(client);
    final d = DateTime(2024, 5, 1);
    await s.getOdds(sport: 'soccer', date: d);
    expect(captured.queryParameters['date'], '2024-05-01');
  });
}
