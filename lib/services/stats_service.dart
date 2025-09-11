// Firebase removed – Supabase only
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user_stats_model.dart';
import '../models/leaderboard_mode.dart';
import '../models/stats_backend_mode.dart';

class StatsService {
  StatsService();

  Stream<List<UserStatsModel>> streamUserStats({
    LeaderboardMode mode = LeaderboardMode.byCoin,
    StatsBackendMode backend = StatsBackendMode.firestore,
  }) {
    final useSupabase = dotenv.env['USE_SUPABASE']?.toLowerCase() == 'true';
    if (useSupabase) {
      return Stream.fromFuture(_fetchFromSupabase(mode));
    }
    return Stream.fromFuture(_fetchFromSupabase(mode));
  }

  Future<List<UserStatsModel>> _fetchFromSupabase(LeaderboardMode mode) async {
    final client = sb.Supabase.instance.client;
    // Profiles: id + nickname/display_name
    final profRows = await client.from('profiles').select('id, nickname, display_name');
    final profiles = List<Map<String, dynamic>>.from(profRows as List);

    // Tickets: user_id + status
    final tRows = await client.from('tickets').select('user_id, status');
    final tickets = List<Map<String, dynamic>>.from(tRows as List);

    // Coins: sum of deltas per user (fallback to 0 if ledger empty)
    final ledgerRows = await client.from('coins_ledger').select('user_id, delta');
    final ledger = List<Map<String, dynamic>>.from(ledgerRows as List);
    final coinsByUser = <String, int>{};
    for (final r in ledger) {
      final uid = r['user_id'] as String;
      final d = (r['delta'] as num?)?.toInt() ?? 0;
      coinsByUser.update(uid, (v) => v + d, ifAbsent: () => d);
    }

    final stats = <UserStatsModel>[];
    for (final p in profiles) {
      final uid = p['id'] as String;
      final displayName = (p['nickname'] as String?) ?? (p['display_name'] as String?) ?? '';
      final userTickets = tickets.where((t) => t['user_id'] == uid);
      final totalBets = userTickets.length;
      final totalWins = userTickets.where((t) => (t['status'] as String?) == 'won').length;
      final winRate = totalBets == 0 ? 0.0 : totalWins / totalBets;
      final coins = coinsByUser[uid] ?? 0;
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
      final userTickets = tickets.where((t) => t['userId'] == uid).toList();
      final totalBets = userTickets.length;
      final totalWins = userTickets.where((t) => t['status'] == 'won').length;
      final winRate = totalBets == 0 ? 0.0 : totalWins / totalBets;
      stats.add(
        UserStatsModel(
          uid: uid,
          displayName: displayName,
          coins: coins,
          totalBets: totalBets,
          totalWins: totalWins,
          winRate: winRate,
        ),
      );
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
          return (b.currentWinStreak ?? 0).compareTo(a.currentWinStreak ?? 0);
      }
    });
  }

  /// Returns aggregated statistics for the currently authenticated user.
  ///
  /// When no user is logged in `null` is returned. The [FirebaseAuth] instance
  /// is injectable for testing similarly to [CoinService.hasClaimedToday].
  Future<UserStatsModel?> getUserStats() async {
    final u = sb.Supabase.instance.client.auth.currentUser;
    if (u == null) return null;
    final uid = u.id;
    final profRow = await sb.Supabase.instance.client
        .from('profiles')
        .select('nickname, display_name')
        .eq('id', uid)
        .maybeSingle();
    final prof = (profRow as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final displayName = (prof['nickname'] as String?) ?? (prof['display_name'] as String?) ?? '';

    final tRows = await sb.Supabase.instance.client
        .from('tickets')
        .select('status')
        .eq('user_id', uid);
    final tList = List<Map<String, dynamic>>.from(tRows as List);
    final totalBets = tList.length;
    final totalWins = tList.where((t) => (t['status'] as String?) == 'won').length;
    final winRate = totalBets == 0 ? 0.0 : totalWins / totalBets;

    final lRows = await sb.Supabase.instance.client
        .from('coins_ledger')
        .select('delta')
        .eq('user_id', uid);
    final coins = List<Map<String, dynamic>>.from(lRows as List)
        .fold<int>(0, (acc, r) => acc + ((r['delta'] as num?)?.toInt() ?? 0));

    return UserStatsModel(
      uid: uid,
      displayName: displayName,
      coins: coins,
      totalBets: totalBets,
      totalWins: totalWins,
      winRate: winRate,
    );
  }

  /// Streams live statistics for a specific user from `/users/{uid}/stats`.
  Stream<UserStatsModel> statsDocStream(String uid) {
    return Stream.fromFuture(() async {
      final profRow = await sb.Supabase.instance.client
          .from('profiles')
          .select('nickname, display_name')
          .eq('id', uid)
          .maybeSingle();
      final prof = (profRow as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      final displayName = (prof['nickname'] as String?) ?? (prof['display_name'] as String?) ?? '';
      final tRows = await sb.Supabase.instance.client
          .from('tickets')
          .select('status')
          .eq('user_id', uid);
      final tList = List<Map<String, dynamic>>.from(tRows as List);
      final totalBets = tList.length;
      final totalWins = tList.where((t) => (t['status'] as String?) == 'won').length;
      final winRate = totalBets == 0 ? 0.0 : totalWins / totalBets;
      final lRows = await sb.Supabase.instance.client
          .from('coins_ledger')
          .select('delta')
          .eq('user_id', uid);
      final coins = List<Map<String, dynamic>>.from(lRows as List)
          .fold<int>(0, (acc, r) => acc + ((r['delta'] as num?)?.toInt() ?? 0));
      return UserStatsModel(
        uid: uid,
        displayName: displayName,
        coins: coins,
        totalBets: totalBets,
        totalWins: totalWins,
        winRate: winRate,
      );
    }());
  }
}
