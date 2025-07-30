import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/badge_config.dart';
import '../models/badge.dart';
import '../models/earned_badge_model.dart';
import '../models/user_stats_model.dart';

/// Service responsible for evaluating and assigning badges to a user.
class BadgeService {
  final FirebaseFirestore _firestore;

  BadgeService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

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
    final badgesRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('badges');
    final existing = await badgesRef.get();
    final existingKeys = existing.docs.map((d) => d.id).toSet();

    for (final badge in earned) {
      if (!existingKeys.contains(badge.key)) {
        await badgesRef.doc(badge.key).set({
          'key': badge.key,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// Returns the latest earned badge for [userId] with timestamp.
  Future<EarnedBadgeModel?> getLatestBadge(String userId) async {
    final badgesRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('badges');
    final snap = await badgesRef
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final key = doc.id;
    final data = badgeConfigs.firstWhere(
      (b) => b.key == key,
      orElse: () => throw ArgumentError('unknown badge: $key'),
    );
    final ts = doc.data()['timestamp'];
    if (ts is! Timestamp) return null;
    return EarnedBadgeModel(badge: data, timestamp: ts.toDate());
  }
}
