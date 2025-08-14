import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/services/market_mapping.dart';

void main() {
  test('H2H parser kinyeri az 1/X/2 oddsokat', () {
    final json = {
      'response': [
        {
          'bookmakers': [
            {
              'id': 99,
              'name': 'DemoBook',
              'bets': [
                {
                  'name': '1X2',
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
    final m = MarketMapping.h2hFromApi(
      json,
      homeLabel: 'Home',
      awayLabel: 'Away',
    );
    expect(m, isNotNull);
    expect(m!.outcomes.length, 3);
  });
}
