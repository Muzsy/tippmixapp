// Firestore-agnosztikus modell: nem importál Firestore-t

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
    timestamp: _parseDate(json['timestamp']),
    description: json['description'] as String? ?? '',
  );

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    try {
      final ts = (v is! String && (v as dynamic).toDate is Function)
          ? (v as dynamic).toDate()
          : null;
      if (ts is DateTime) return ts;
    } catch (_) {}
    if (v is String) {
      final d = DateTime.tryParse(v);
      if (d != null) return d;
    }
    return DateTime.now();
  }

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
