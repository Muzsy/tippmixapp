import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tippmixapp/services/api_football_service.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_FOOTBALL_KEY=dummy');
  });

  test('Fallback: üres 1X2 → teljes odds', () async {
    late Uri firstUrl;
    late Uri secondUrl;
    int call = 0;
    final client = MockClient((req) async {
      call += 1;
      if (call == 1) {
        firstUrl = req.url;
        return http.Response(jsonEncode({'response': []}), 200);
      }
      secondUrl = req.url;
      return http.Response(
        jsonEncode({
          'response': [
            {
              'bookmakers': [
                {
                  'name': 'DemoBook',
                  'bets': [
                    {
                      'name': 'Match Winner',
                      'values': [
                        {'value': '1', 'odd': '2.10'},
                        {'value': 'X', 'odd': '3.30'},
                        {'value': '2', 'odd': '3.40'},
                      ],
                    },
                  ],
                },
              ],
            },
          ],
        }),
        200,
      );
    });

    final s = ApiFootballService(client);
    // Fixtures-enrichmentet itt nem szimuláljuk; közvetlen a odds hívást ellenőrizzük
    final body = await s.getOddsForFixture('12345', season: 2025);
    expect((body['response'] as List).isNotEmpty, true);
    expect(firstUrl.queryParameters['bet'], '1X2');
    expect(secondUrl.queryParameters['bet'], isNull);
  });
}
