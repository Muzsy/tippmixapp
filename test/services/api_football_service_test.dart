import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tippmixapp/models/api_response.dart';
import 'package:tippmixapp/services/api_football_service.dart';
import 'package:tippmixapp/services/market_mapping.dart';

void main() {
  group('ApiFootballService', () {
    test('parses fixtures into OddsEvent list', () async {
      dotenv.testLoad(fileInput: 'API_FOOTBALL_KEY=test');
      final service = ApiFootballService(
        MockClient((_) async {
          final sample = {
            'response': [
              {
                'fixture': {'id': 1, 'date': '2024-01-01T12:00:00+00:00'},
                'teams': {
                  'home': {'name': 'Arsenal'},
                  'away': {'name': 'Chelsea'}
                }
              }
            ]
          };
          return http.Response(jsonEncode(sample), 200);
        }),
      );

      final res = await service.getOdds(sport: 'soccer');
      expect(res.errorType, ApiErrorType.none);
      expect(res.data, isNotNull);
      expect(res.data!.first.homeTeam, 'Arsenal');
    });

    test('missing api key returns unauthorized', () async {
      dotenv.testLoad(fileInput: '');
      final service = ApiFootballService(
        MockClient((_) async => http.Response('{}', 200)),
      );

      final res = await service.getOdds(sport: 'soccer');
      expect(res.errorType, ApiErrorType.unauthorized);
    });
  });

  group('MarketMapping', () {
    test('maps various keys correctly', () {
      expect(MarketMapping.fromApiFootball('1x2'), MarketMapping.h2h);
      expect(MarketMapping.fromApiFootball('h2h'), MarketMapping.h2h);
      expect(MarketMapping.fromApiFootball('over_under'), MarketMapping.overUnder);
      expect(MarketMapping.fromApiFootball('ou'), MarketMapping.overUnder);
      expect(MarketMapping.fromApiFootball('totals'), MarketMapping.overUnder);
      expect(MarketMapping.fromApiFootball('btts'), MarketMapping.bothTeamsToScore);
      expect(MarketMapping.fromApiFootball('both_teams_to_score'),
          MarketMapping.bothTeamsToScore);
      expect(MarketMapping.fromApiFootball('ah'), MarketMapping.asianHandicap);
      expect(MarketMapping.fromApiFootball('asian_handicap'),
          MarketMapping.asianHandicap);
      expect(MarketMapping.fromApiFootball('unknown'), isNull);
    });
  });
}
