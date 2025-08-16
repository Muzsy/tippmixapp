import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/services/odds_drift_checker.dart';
import 'package:tippmixapp/services/api_football_service.dart';

class _MockApiFootballService extends ApiFootballService {
  final Map<String, Map<String, dynamic>> fixtures;
  _MockApiFootballService(this.fixtures) : super();

  @override
  Future<Map<String, dynamic>> getOddsForFixture(
    String fixtureId, {
    int? season,
    bool includeBet1 = true,
  }) async {
    return fixtures[fixtureId] ?? {};
  }
}

void main() {
  final fixtureData = {
    '1': {
      'markets': [
        {
          'code': '1X2',
          'outcomes': [
            {'code': 'HOME', 'price': 1.90},
            {'code': 'DRAW', 'price': 3.30},
            {'code': 'AWAY', 'price': 4.50},
          ],
        },
      ],
    },
  };

  test('no drift when identical', () async {
    final checker = OddsDriftChecker(_MockApiFootballService(fixtureData));
    final tips = [
      {
        'fixtureId': '1',
        'market': '1X2',
        'selection': 'HOME',
        'oddsSnapshot': 1.90,
      },
    ];
    final result = await checker.check(tips);
    expect(result.changes, isEmpty);
    expect(result.hasBlocking(0.05), isFalse);
  });

  test('small drift below threshold', () async {
    final data = {
      '1': {
        'markets': [
          {
            'code': '1X2',
            'outcomes': [
              {'code': 'HOME', 'price': 1.92},
            ],
          },
        ],
      },
    };
    final checker = OddsDriftChecker(_MockApiFootballService(data));
    final tips = [
      {
        'fixtureId': '1',
        'market': '1X2',
        'selection': 'HOME',
        'oddsSnapshot': 1.90,
      },
    ];
    final result = await checker.check(tips);
    expect(result.changes.length, 1);
    expect(result.changes.first.diff, closeTo(0.02, 0.0001));
    expect(result.hasBlocking(0.05), isFalse);
  });

  test('large drift above threshold', () async {
    final data = {
      '1': {
        'markets': [
          {
            'code': '1X2',
            'outcomes': [
              {'code': 'HOME', 'price': 2.05},
            ],
          },
        ],
      },
    };
    final checker = OddsDriftChecker(_MockApiFootballService(data));
    final tips = [
      {
        'fixtureId': '1',
        'market': '1X2',
        'selection': 'HOME',
        'oddsSnapshot': 1.90,
      },
    ];
    final result = await checker.check(tips);
    expect(result.changes.length, 1);
    expect(result.hasBlocking(0.05), isTrue);
  });
}
