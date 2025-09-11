import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tip_model.dart';

/// Save a copy of a ticket for later editing.
/// Returns the generated copyId.
Future<String> copyTicket({
  required String userId,
  required String ticketId,
  required List<TipModel> tips,
  String? sourceUserId,
}) async {
  try {
    final rows = await sb.Supabase.instance.client
        .from('copied_bets')
        .insert({
          'user_id': userId,
          'tips': tips.map((e) => e.toJson()).toList(),
          'was_modified': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();
    return (rows['id'] as String);
  } catch (_) {
    return '';
  }
}

typedef CopyTicketFn =
    Future<String> Function({
      required String userId,
      required String ticketId,
      required List<TipModel> tips,
      String? sourceUserId,
    });

/// Provider exposing the [copyTicket] flow for easier testing.
final copyTicketProvider = Provider<CopyTicketFn>((ref) => copyTicket);
