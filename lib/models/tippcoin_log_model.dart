import 'package:cloud_firestore/cloud_firestore.dart';

class TippCoinLogModel {
  final String id;
  final String userId;
  final int amount;
  final String type;
  final DateTime timestamp;
  final String? txId;
  final Map<String, dynamic>? meta;

  TippCoinLogModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.txId,
    this.meta,
  });

  factory TippCoinLogModel.fromJson(String id, Map<String, dynamic> json) {
    final t = json['type'] as String? ?? '';
    const allowed = ['bet', 'deposit', 'withdraw', 'adjust'];
    if (!allowed.contains(t)) {
      throw const FormatException('invalid type');
    }
    return TippCoinLogModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      type: t,
      timestamp: DateTime.parse(json['timestamp'] as String),
      txId: json['txId'] as String?,
      meta: (json['meta'] as Map?)?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'amount': amount,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    if (txId != null) 'txId': txId,
    if (meta != null) 'meta': meta,
  };

  TippCoinLogModel copyWith({
    String? id,
    String? userId,
    int? amount,
    String? type,
    DateTime? timestamp,
    String? txId,
    Map<String, dynamic>? meta,
  }) {
    return TippCoinLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      txId: txId ?? this.txId,
      meta: meta ?? this.meta,
    );
  }

  factory TippCoinLogModel.newDebit({
    required String id,
    required String userId,
    required int amount,
    required String type,
    String? txId,
    Map<String, dynamic>? meta,
  }) {
    return TippCoinLogModel(
      id: id,
      userId: userId,
      amount: -amount.abs(),
      type: type,
      timestamp: DateTime.now(),
      txId: txId,
      meta: meta,
    );
  }

  factory TippCoinLogModel.newCredit({
    required String id,
    required String userId,
    required int amount,
    required String type,
    String? txId,
    Map<String, dynamic>? meta,
  }) {
    return TippCoinLogModel(
      id: id,
      userId: userId,
      amount: amount.abs(),
      type: type,
      timestamp: DateTime.now(),
      txId: txId,
      meta: meta,
    );
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('coin_logs');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TippCoinLogModel) return false;
    return id == other.id &&
        userId == other.userId &&
        amount == other.amount &&
        type == other.type &&
        timestamp.isAtSameMomentAs(other.timestamp) &&
        txId == other.txId &&
        _mapEquals(meta, other.meta);
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, amount, type, timestamp, txId, meta?.hashCode);

  static bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (b[key] != a[key]) return false;
    }
    return true;
  }
}
