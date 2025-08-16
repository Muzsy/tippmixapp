import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/services/market_mapping.dart';

void main() {
  test('h2hFromApi parses Match Winner → Home/Draw/Away', () {
    final json = {
      'response': [
        {
          'bookmakers': [
            {
              'name': 'Bwin',
              'bets': [
                {
                  'name': 'Match Winner',
                  'values': [
                    {'value': 'Home', 'odd': '1.50'},
                    {'value': 'Draw', 'odd': '3.20'},
                    {'value': 'Away', 'odd': '5.00'},
                  ],
                },
              ],
            },
          ],
        },
      ],
    };
    final h2h = MarketMapping.h2hFromApi(json);
    expect(h2h, isNotNull);
    expect(h2h!.outcomes.length, 3);
    expect(h2h.outcomes[0].name, 'Home');
    expect(h2h.outcomes[1].name, 'Draw');
    expect(h2h.outcomes[2].name, 'Away');
  });
}
