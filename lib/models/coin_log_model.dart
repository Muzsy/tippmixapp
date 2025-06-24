import 'package:cloud_firestore/cloud_firestore.dart';

class CoinLogModel {
  final String userId;
  final int amount;
  final String type;
  final String reason;
  final String transactionId;
  final DateTime timestamp;
  final String description;

  CoinLogModel({
    required this.userId,
    required this.amount,
    required this.type,
    required this.reason,
    required this.transactionId,
    required this.timestamp,
    required this.description,
  });

  factory CoinLogModel.fromJson(Map<String, dynamic> json) => CoinLogModel(
        userId: json['userId'] as String,
        amount: json['amount'] as int,
        type: json['type'] as String,
        reason: json['reason'] as String,
        transactionId: json['transactionId'] as String,
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        description: json['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'amount': amount,
        'type': type,
        'reason': reason,
        'transactionId': transactionId,
        'timestamp': timestamp.toIso8601String(),
        'description': description,
      };
}
