import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/services/api_football_service.dart';
import 'package:tippmixapp/models/h2h_market.dart';

class _TestApiFootballService extends ApiFootballService {
  @override
  Future<Map<String, dynamic>> getOddsForFixture(
    String fixtureId, {
    int? season,
  }) async {
    return {
      'markets': [
        {
          'key': 'H2H',
          'outcomes': [
            {'name': 'Home', 'price': 1.0},
            {'name': 'Draw', 'price': 2.0},
            {'name': 'Away', 'price': 3.0},
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
