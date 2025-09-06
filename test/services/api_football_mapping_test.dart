import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tipsterino/services/api_football_service.dart';

void main() {
  test('maps Match Winner bet to h2h market and team names', () async {
    dotenv.testLoad(fileInput: 'API_FOOTBALL_KEY=test');
    final fixturesResponse = {
      'response': [
        {
          'fixture': {'id': 1, 'date': '2024-08-20T12:00:00Z'},
          'league': {'country': 'England', 'name': 'Premier League'},
          'teams': {
            'home': {'name': 'Arsenal'},
            'away': {'name': 'Chelsea'},
          },
        },
      ],
    };
    final oddsResponse = {
      'response': [
        {
          'bookmakers': [
            {
              'id': 8,
              'name': 'DemoBook',
              'bets': [
                {
                  'name': 'Match Winner',
                  'values': [
                    {'value': 'Home', 'odd': '1.50'},
                    {'value': 'Draw', 'odd': '3.80'},
                    {'value': 'Away', 'odd': '2.10'},
                  ],
                },
              ],
            },
          ],
        },
      ],
    };
    final client = MockClient((request) async {
      if (request.url.path.contains('/fixtures')) {
        return http.Response(jsonEncode(fixturesResponse), 200);
      }
      if (request.url.path.contains('/odds')) {
        return http.Response(jsonEncode(oddsResponse), 200);
      }
      return http.Response('Not Found', 404);
    });
    final service = ApiFootballService(client);
    final result = await service.getOdds(sport: 'soccer', includeH2H: true);
    final event = result.data!.first;
    expect(event.countryName, 'England');
    expect(event.leagueName, 'Premier League');
    final market = event.bookmakers.first.markets.first;
    expect(market.key, 'h2h');
    final outcomes = market.outcomes;
    expect(outcomes[0].name, 'Arsenal');
    expect(outcomes[1].name, 'Draw');
    expect(outcomes[2].name, 'Chelsea');
  });
}
