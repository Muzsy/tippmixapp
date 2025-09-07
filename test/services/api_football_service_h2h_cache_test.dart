import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/services/api_football_service.dart';
import 'package:tipsterino/models/h2h_market.dart';

class _TestApiFootballService extends ApiFootballService {
  @override
  Future<Map<String, dynamic>> getOddsForFixture(
    String fixtureId, {
    int? season,
    bool includeBet1 = true,
  }) async {
    return {
      'response': [
        {
          'bookmakers': [
            {
              'id': 1,
              'name': 'Demo',
              'bets': [
                {
                  'name': '1X2',
                  'values': [
                    {'value': '1', 'odd': '1.0'},
                    {'value': 'X', 'odd': '2.0'},
                    {'value': '2', 'odd': '3.0'},
                  ],
                },
              ],
            },
          ],
        },
      ],
    };
  }
}

void main() {
  test('getH2HForFixture cache-eli az eredményt', () async {
    final s = _TestApiFootballService();
    final f1 = s.getH2HForFixture(123);
    final f2 = s.getH2HForFixture(123);
    expect(identical(f1, f2), isTrue);
    final r = await f1;
    expect(r, isA<H2HMarket>());
  });
}
