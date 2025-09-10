import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCoinService {
  SupabaseCoinService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<bool> hasClaimedToday() async {
    final u = _client.auth.currentUser;
    if (u == null) return true;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final rows = await _client
        .from('coins_ledger')
        .select('id')
        .eq('user_id', u.id)
        .eq('type', 'daily_bonus')
        .gte('created_at', start.toIso8601String())
        .limit(1);
    return (rows as List).isNotEmpty;
  }

  Future<void> claimDailyBonus() async {
    await _client.functions.invoke('claim_daily_bonus');
  }
}

