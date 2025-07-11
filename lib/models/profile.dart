class Profile {
  final String uid;
  final String displayName;
  final String avatarUrl;
  final DateTime createdAt;
  final int coins;

  Profile({
    required this.uid,
    required this.displayName,
    required this.avatarUrl,
    required this.createdAt,
    required this.coins,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        uid: json['uid'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        coins: json['coins'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
        'coins': coins,
      };
}
