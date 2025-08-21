import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tippmixapp/services/api_football_service.dart';

void main() {
  test('maps Match Winner bet to h2h market and team names', () async {
    dotenv.testLoad(fileInput: 'API_FOOTBALL_KEY=test');
    final mockResponse = {
      'response': [
        {
          'fixture': {'id': 1, 'date': '2024-08-20T12:00:00Z'},
          'league': {'country': 'England', 'name': 'Premier League'},
          'teams': {
            'home': {'name': 'Arsenal'},
            'away': {'name': 'Chelsea'},
          },
          'bookmakers': [
            {
              'id': 1,
              'name': 'Bet365',
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
      return http.Response(jsonEncode(mockResponse), 200);
    });
    final service = ApiFootballService(client);
    final result = await service.getOdds(sport: 'soccer');
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
