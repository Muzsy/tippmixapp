import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/services/market_mapping.dart';

void main() {
  test('h2hFromApi: Match Winner → 1/X/2', () {
    final json = {
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
    };
    final m = MarketMapping.h2hFromApi(json);
    expect(m, isNotNull);
    expect(m!.outcomes.length, 3);
  });
}
