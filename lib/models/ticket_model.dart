import 'tip_model.dart';

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
    return Ticket(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      tips: (json['tips'] as List<dynamic>)
          .map((e) => TipModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      stake: (json['stake'] as num).toDouble(),
      totalOdd: (json['totalOdd'] as num).toDouble(),
      potentialWin: (json['potentialWin'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => TicketStatus.pending,
      ),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.name,
    };
  }
}
