import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/models/leaderboard_mode.dart';
import 'package:tipsterino/services/stats_service.dart';

void main() {
  group('StatsService.computeStats', () {
    final users = [
      {'uid': 'u1', 'displayName': 'A', 'coins': 200},
      {'uid': 'u2', 'displayName': 'B', 'coins': 100},
    ];
    final tickets = [
      {'userId': 'u1', 'status': 'won'},
      {'userId': 'u1', 'status': 'lost'},
      {'userId': 'u2', 'status': 'won'},
    ];

    test('sorts by coin by default', () {
      final result = StatsService.computeStats(
        users,
        tickets,
        LeaderboardMode.byCoin,
      );

      expect(result.first.uid, 'u1');
      expect(result[1].uid, 'u2');
    });

    test('calculates winrate correctly and sorts by winrate', () {
      final result = StatsService.computeStats(
        users,
        tickets,
        LeaderboardMode.byWinrate,
      );

      expect(result.first.uid, 'u2');
      expect(result.first.winRate, 1.0);
      expect(result[1].uid, 'u1');
      expect(result[1].winRate, closeTo(0.5, 0.001));
    });
  });
}
