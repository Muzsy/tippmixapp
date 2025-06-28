import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_stats_model.dart';
import '../models/leaderboard_mode.dart';
import '../models/stats_backend_mode.dart';

class StatsService {
  final FirebaseFirestore? _firestore;

  StatsService([FirebaseFirestore? firestore]) : _firestore = firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Stream<List<UserStatsModel>> streamUserStats({
    LeaderboardMode mode = LeaderboardMode.byCoin,
    StatsBackendMode backend = StatsBackendMode.firestore,
  }) {
    switch (backend) {
      case StatsBackendMode.firestore:
        return _streamFromFirestore(mode);
      case StatsBackendMode.bigQuery:
        throw UnimplementedError('BigQuery backend not implemented');
    }
  }

  Stream<List<UserStatsModel>> _streamFromFirestore(LeaderboardMode mode) {
    final usersRef = _db.collection('users');
    final ticketsRef = _db.collection('tickets');

    return usersRef.snapshots().asyncMap((userSnap) async {
      final stats = <UserStatsModel>[];
      for (final userDoc in userSnap.docs) {
        final data = userDoc.data();
        final uid = userDoc.id;
        final coins = (data['coins'] as int?) ?? 0;
        final displayName = data['nickname'] as String? ?? '';

        final userTickets = await ticketsRef
            .where('userId', isEqualTo: uid)
            .get();
        final totalBets = userTickets.docs.length;
        final totalWins = userTickets.docs
            .where((t) => t.data()['status'] == 'won')
            .length;
        final winRate = totalBets == 0 ? 0.0 : totalWins / totalBets;

        stats.add(UserStatsModel(
          uid: uid,
          displayName: displayName,
          coins: coins,
          totalBets: totalBets,
          totalWins: totalWins,
          winRate: winRate,
        ));
      }

      _sortStats(stats, mode);
      return stats;
    });
  }

  static List<UserStatsModel> computeStats(
    List<Map<String, dynamic>> users,
    List<Map<String, dynamic>> tickets,
    LeaderboardMode mode,
  ) {
    final stats = <UserStatsModel>[];
    for (final user in users) {
      final uid = user['uid'] as String;
      final coins = user['coins'] as int? ?? 0;
      final displayName = user['nickname'] as String? ?? '';
      final userTickets =
          tickets.where((t) => t['userId'] == uid).toList();
      final totalBets = userTickets.length;
      final totalWins =
          userTickets.where((t) => t['status'] == 'won').length;
      final winRate = totalBets == 0 ? 0.0 : totalWins / totalBets;
      stats.add(UserStatsModel(
        uid: uid,
        displayName: displayName,
        coins: coins,
        totalBets: totalBets,
        totalWins: totalWins,
        winRate: winRate,
      ));
    }
    _sortStats(stats, mode);
    return stats;
  }

  static void _sortStats(List<UserStatsModel> stats, LeaderboardMode mode) {
    stats.sort((a, b) {
      switch (mode) {
        case LeaderboardMode.byCoin:
          return b.coins.compareTo(a.coins);
        case LeaderboardMode.byWinrate:
          return b.winRate.compareTo(a.winRate);
        case LeaderboardMode.byStreak:
          return (b.currentWinStreak ?? 0)
              .compareTo(a.currentWinStreak ?? 0);
      }
    });
  }

  /// Returns aggregated statistics for the currently authenticated user.
  ///
  /// When no user is logged in `null` is returned. The [FirebaseAuth] instance
  /// is injectable for testing similarly to [CoinService.hasClaimedToday].
  Future<UserStatsModel?> getUserStats({FirebaseAuth? auth}) async {
    final currentUser = auth?.currentUser ?? FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    final uid = currentUser.uid;
    final userDoc = await _db.collection('users').doc(uid).get();
    if (!userDoc.exists) return null;
    final userData = userDoc.data() ?? <String, dynamic>{};

    final coins = (userData['coins'] as int?) ?? 0;
    final displayName = userData['nickname'] as String? ?? '';

    final ticketSnap = await _db
        .collection('tickets')
        .where('userId', isEqualTo: uid)
        .get();
    final totalBets = ticketSnap.docs.length;
    final totalWins = ticketSnap.docs
        .where((t) => t.data()['status'] == 'won')
        .length;
    final winRate = totalBets == 0 ? 0.0 : totalWins / totalBets;

    return UserStatsModel(
      uid: uid,
      displayName: displayName,
      coins: coins,
      totalBets: totalBets,
      totalWins: totalWins,
      winRate: winRate,
    );
  }
}
