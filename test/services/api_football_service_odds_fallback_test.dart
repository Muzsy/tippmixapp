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

  test('fallback: üres 1X2 → teljes odds', () async {
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
                  'name': 'Demo',
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
    final m = await s.getH2HForFixture(42, season: 2025);
    expect(m, isNotNull);
    expect(firstUrl.queryParameters['bet'], '1X2');
    expect(secondUrl.queryParameters['bet'], isNull);
  });
}
