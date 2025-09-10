import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTicketService {
  SupabaseTicketService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<String?> createTicket({
    required List<Map<String, dynamic>> tips,
    required num stake,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final uid = user.id;

    double totalOdd = 1.0;
    for (final t in tips) {
      final o = (t['odds'] as num?)?.toDouble() ?? 1.0;
      totalOdd *= o;
    }
    final potentialWin = stake * totalOdd;

    final insert = await _client.from('tickets').insert({
      'user_id': uid,
      'status': 'pending',
      'stake': stake,
      'total_odd': double.parse(totalOdd.toStringAsFixed(2)),
      'potential_win': double.parse(potentialWin.toStringAsFixed(2)),
    }).select('id').single();

    final ticketId = (insert['id'] as String);

    // Insert items
    final items = tips.map((t) => {
          'ticket_id': ticketId,
          'fixture_id': (t['eventId'] ?? t['fixtureId']).toString(),
          'market': (t['marketKey'] ?? t['market'] ?? 'h2h').toString(),
          'odd': (t['odds'] as num?)?.toDouble() ?? 1.0,
          'selection': (t['outcome'] ?? t['selection']).toString(),
        });
    if (items.isNotEmpty) {
      await _client.from('ticket_items').insert(items.toList());
    }

    return ticketId;
  }
}

