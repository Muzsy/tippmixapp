import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/badge_config.dart';
import '../models/badge.dart';
import '../models/earned_badge_model.dart';
import '../models/user_stats_model.dart';

/// Service responsible for evaluating and assigning badges to a user.
class BadgeService {
  // Keep legacy optional positional param for test compatibility (ignored)
  BadgeService([Object? legacyFirestore]);

  /// Evaluate which badges the user has earned based on [stats].
  List<BadgeData> evaluateUserBadges(UserStatsModel stats) {
    final earned = <BadgeData>[];
    for (final badge in badgeConfigs) {
      if (_checkCondition(badge.condition, stats)) {
        earned.add(badge);
      }
    }
    return earned;
  }

  bool _checkCondition(BadgeCondition condition, UserStatsModel stats) {
    switch (condition) {
      case BadgeCondition.firstWin:
        return _checkFirstWin(stats);
      case BadgeCondition.streak3:
        return _checkStreak3(stats);
      case BadgeCondition.parlayWin:
        return _checkParlayWin(stats);
      case BadgeCondition.lateNightWin:
        return _checkLateNightWin(stats);
      case BadgeCondition.comebackWin:
        return _checkComebackWin(stats);
    }
  }

  bool _checkFirstWin(UserStatsModel stats) => stats.totalWins >= 1;

  bool _checkStreak3(UserStatsModel stats) =>
      (stats.currentWinStreak ?? 0) >= 3;

  bool _checkParlayWin(UserStatsModel stats) => false;

  bool _checkLateNightWin(UserStatsModel stats) => false;

  bool _checkComebackWin(UserStatsModel stats) => false;

  /// Assign newly earned badges for [userId] based on [stats].
  Future<void> assignNewBadges(String userId, UserStatsModel stats) async {
    final earned = evaluateUserBadges(stats);
    final useSupabase = dotenv.env['USE_SUPABASE']?.toLowerCase() == 'true';
    if (useSupabase) {
      final client = Supabase.instance.client;
      final rows = await client
          .from('badges')
          .select('key')
          .eq('user_id', userId);
      final existingKeys = (rows as List)
          .map((r) => (r['key'] as String))
          .toSet();
      for (final badge in earned) {
        if (!existingKeys.contains(badge.key)) {
          await client.from('badges').insert({
            'user_id': userId,
            'key': badge.key,
          });
        }
      }
    }
  }

  /// Returns the latest earned badge for [userId] with timestamp.
  Future<EarnedBadgeModel?> getLatestBadge(String userId) async {
    final useSupabase = dotenv.env['USE_SUPABASE']?.toLowerCase() == 'true';
    if (useSupabase) {
      final client = Supabase.instance.client;
      final rows = await client
          .from('badges')
          .select('key, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);
      if ((rows as List).isEmpty) return null;
      final r = (rows.first as Map<String, dynamic>);
      final key = r['key'] as String;
      final data = badgeConfigs.firstWhere(
        (b) => b.key == key,
        orElse: () => throw ArgumentError('unknown badge: $key'),
      );
      final tsStr = r['created_at'] as String?;
      final ts = tsStr != null ? DateTime.tryParse(tsStr) : null;
      if (ts == null) return null;
      return EarnedBadgeModel(badge: data, timestamp: ts);
    }
    return null;
  }
}
