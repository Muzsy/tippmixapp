import 'tip_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketStatus { pending, won, lost, voided }

class Ticket {
  final String id;
  final String userId;
  final List<TipModel> tips;
  final double stake;
  final double totalOdd;
  final double potentialWin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TicketStatus status;

  Ticket({
    required this.id,
    required this.userId,
    required this.tips,
    required this.stake,
    required this.totalOdd,
    required this.potentialWin,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      final ts = (v is! String && v is! DateTime && (v as dynamic).toDate is Function)
          ? v.toDate()
          : null;
      if (ts is DateTime) return ts;
      if (v is String) {
        final d = DateTime.tryParse(v);
        if (d != null) return d;
      }
      return DateTime.now();
    }

    String statusRaw = (json['status'] as String? ?? 'pending').toLowerCase();
    if (statusRaw == 'void') statusRaw = 'voided';

    final tipsRaw = (json['tips'] as List<dynamic>?) ?? const [];

    final stake = (json['stake'] as num?)?.toDouble() ?? 0.0;
    final totalOdd = (json['totalOdd'] as num?)?.toDouble() ?? 1.0;
    final potentialWin = (json['potentialWin'] as num?)?.toDouble() ?? (stake * totalOdd);

    return Ticket(
      id: (json['id'] ?? json['ticketId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      tips: tipsRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => TipModel.fromJson(e))
          .toList(),
      stake: stake,
      totalOdd: totalOdd,
      potentialWin: potentialWin,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt'] ?? json['processedAt']),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == statusRaw,
        orElse: () => TicketStatus.pending,
      ),
    );
  }

  factory Ticket.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final t = Ticket.fromJson(data);
    // Biztosítsuk, hogy az id a doc.id legyen
    return Ticket(
      id: doc.id,
      userId: t.userId,
      tips: t.tips,
      stake: t.stake,
      totalOdd: t.totalOdd,
      potentialWin: t.potentialWin,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
      status: t.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tips': tips.map((e) => e.toJson()).toList(),
      'stake': stake,
      'totalOdd': totalOdd,
      'potentialWin': potentialWin,
      // Store as Firestore Timestamp for proper ordering & cursors
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status.name,
    };
  }
}
