// Firebase removed

/// Entity types that can receive votes.
enum VoteEntityType { post }

extension VoteEntityTypeX on VoteEntityType {
  String toJson() => name;
  static VoteEntityType fromJson(String value) =>
      VoteEntityType.values.firstWhere((e) => e.name == value);
}

/// Vote document linking a user to an entity.
class Vote {
  final String id;
  final VoteEntityType entityType;
  final String entityId;
  final String userId;
  final DateTime createdAt;

  const Vote({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.userId,
    required this.createdAt,
  });

  factory Vote.fromJson(String id, Map<String, dynamic> json) {
    return Vote(
      id: id,
      entityType: VoteEntityTypeX.fromJson(json['entityType'] as String),
      entityId: json['entityId'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'entityType': entityType.toJson(),
        'entityId': entityId,
        'userId': userId, // must match auth.uid per rules
        'createdAt': createdAt.toIso8601String(),
      };
}
