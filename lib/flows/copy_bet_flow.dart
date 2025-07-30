import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tip_model.dart';

/// Save a copy of a ticket for later editing.
/// Returns the generated copyId.
Future<String> copyTicket({
  required String userId,
  required String ticketId,
  required List<TipModel> tips,
  String? sourceUserId,
  FirebaseFirestore? firestore,
}) async {
  final fs = firestore ?? FirebaseFirestore.instance;
  final collection = fs.collection('copied_bets/$userId');
  final docRef = collection.doc();
  await docRef.set({
    'ticketId': ticketId,
    'sourceUserId': sourceUserId,
    'createdAt': FieldValue.serverTimestamp(),
    'wasModified': false,
    'tips': tips.map((e) => e.toJson()).toList(),
  });
  return docRef.id;
}

typedef CopyTicketFn =
    Future<String> Function({
      required String userId,
      required String ticketId,
      required List<TipModel> tips,
      String? sourceUserId,
      FirebaseFirestore? firestore,
    });

/// Provider exposing the [copyTicket] flow for easier testing.
final copyTicketProvider = Provider<CopyTicketFn>((ref) => copyTicket);
