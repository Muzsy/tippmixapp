import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/leaderboard_mode.dart';
import 'package:tippmixapp/models/stats_backend_mode.dart';
import 'package:tippmixapp/models/user_stats_model.dart';
import 'package:tippmixapp/services/leaderboard_service.dart';
import 'package:tippmixapp/services/stats_service.dart';

class FakeStatsService extends StatsService {
  final Stream<List<UserStatsModel>> _stream;

  FakeStatsService(this._stream);

  @override
  Stream<List<UserStatsModel>> streamUserStats({
    LeaderboardMode mode = LeaderboardMode.byCoin,
    StatsBackendMode backend = StatsBackendMode.firestore,
  }) => _stream;
}

void main() {
  test('fetchTopTipster returns first user from stats', () async {
    final stats = [
      UserStatsModel(
        uid: 'u1',
        displayName: 'Alice',
        coins: 100,
        totalBets: 5,
        totalWins: 5,
        winRate: 1.0,
      ),
    ];
    final service = LeaderboardService(FakeStatsService(Stream.value(stats)));

    final result = await service.fetchTopTipster();

    expect(result, isNotNull);
  expect(result!.uid, 'u1');
  });
}