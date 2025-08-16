import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tippmixapp/services/api_football_service.dart';

class FailingOnceClient extends http.BaseClient {
  int calls = 0;
  final http.Client _inner;
  FailingOnceClient(this._inner);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    calls += 1;
    if (calls == 1) {
      // first attempt: simulated timeout
      throw TimeoutException('simulated');
    }
    return _inner.send(request);
  }
}

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_FOOTBALL_KEY=dummy');
  });

  test('fixtures hívás 1× retry-ol timeout után', () async {
    // successful response on second call
    final inner = MockClient((req) async {
      final body = jsonEncode({
        'response': [
          {
            'fixture': {'id': 123, 'date': '2025-01-01T00:00:00Z'},
            'league': {
              'season': 2025,
              'country': 'X',
              'name': 'L',
              'logo': null,
            },
            'teams': {
              'home': {'name': 'A', 'logo': null},
              'away': {'name': 'B', 'logo': null},
            },
          },
        ],
      });
      return http.Response(body, 200);
    });
    final client = FailingOnceClient(inner);
    final api = ApiFootballService(client);

    final res = await api.getOdds(sport: 'soccer', date: DateTime(2025, 1, 1));
    expect(res.data, isNotNull);
    expect(client.calls, 2);
  });
}
