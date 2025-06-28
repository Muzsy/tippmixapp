import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/stats_service.dart';
import '../models/leaderboard_mode.dart';
import '../models/user_stats_model.dart';

/// Provides a single [StatsService] instance.
final statsServiceProvider = Provider<StatsService>((ref) => StatsService());

/// Currently selected leaderboard sorting mode.
final leaderboardModeProvider =
    StateProvider<LeaderboardMode>((ref) => LeaderboardMode.byCoin);

/// Streams leaderboard data based on the selected [LeaderboardMode].
final leaderboardStreamProvider =
    StreamProvider<List<UserStatsModel>>((ref) {
  final service = ref.watch(statsServiceProvider);
  final mode = ref.watch(leaderboardModeProvider);
  return service.streamUserStats(mode: mode);
});

/// Fetches statistics for the currently authenticated user.
final userStatsProvider = FutureProvider<UserStatsModel?>((ref) {
  final service = ref.watch(statsServiceProvider);
  return service.getUserStats();
});
