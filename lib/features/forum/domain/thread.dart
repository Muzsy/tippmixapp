import 'package:cloud_firestore/cloud_firestore.dart';

/// Forum thread document.
class Thread {
  final String id;
  final String fixtureId;
  final String type;
  final DateTime createdAt;
  final bool locked;

  const Thread({
    required this.id,
    required this.fixtureId,
    required this.type,
    required this.createdAt,
    this.locked = false,
  });

  factory Thread.fromJson(String id, Map<String, dynamic> json) {
    return Thread(
      id: id,
      fixtureId: json['fixtureId'] as String,
      type: json['type'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      locked: json['locked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'fixtureId': fixtureId,
    'type': type,
    'createdAt': Timestamp.fromDate(createdAt),
    'locked': locked,
  };
}
