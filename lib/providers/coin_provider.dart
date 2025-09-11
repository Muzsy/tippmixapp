import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the current TippCoin balance for the logged-in user.
///
/// When USE_SUPABASE=true, it sums the deltas from coins_ledger.
/// Otherwise returns null (legacy Firestore UI path handles display).
final coinBalanceProvider = FutureProvider<int?>((ref) async {
  final useSupabase = dotenv.env['USE_SUPABASE']?.toLowerCase() == 'true';
  if (!useSupabase) return null;
  final client = Supabase.instance.client;
  final u = client.auth.currentUser;
  if (u == null) return null;
  final rows = await client
      .from('coins_ledger')
      .select('delta')
      .eq('user_id', u.id);
  final list = List<Map<String, dynamic>>.from(rows as List);
  final sum = list.fold<int>(0, (acc, r) => acc + ((r['delta'] as num?)?.toInt() ?? 0));
  return sum;
});

