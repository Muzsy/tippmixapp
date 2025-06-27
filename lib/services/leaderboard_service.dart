import '../models/user_stats_model.dart';
import 'stats_service.dart';

/// Service to provide leaderboard specific helpers.
class LeaderboardService {
  final StatsService _statsService;

  LeaderboardService([StatsService? statsService])
      : _statsService = statsService ?? StatsService();

  /// Returns the top tipster based on the default leaderboard statistics.
  Future<UserStatsModel?> fetchTopTipster() async {
    final list = await _statsService.streamUserStats().first;
    if (list.isEmpty) return null;
    return list.first;
  }
}
