import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_stats_model.dart';
import '../services/leaderboard_service.dart';
import '../services/club_service.dart';

/// Provides a single [LeaderboardService] instance.
final leaderboardServiceProvider = Provider<LeaderboardService>(
  (ref) => LeaderboardService(),
);

/// Provides a single [ClubService] instance.
final clubServiceProvider = Provider<ClubService>((ref) => ClubService());

/// Fetches the current top tipster if a club is available.
final topTipsterProvider = FutureProvider<UserStatsModel?>((ref) async {
  final clubService = ref.watch(clubServiceProvider);
  final hasClub = await clubService.hasClub();
  if (!hasClub) return null;
  final service = ref.watch(leaderboardServiceProvider);
  return service.fetchTopTipster();
});
