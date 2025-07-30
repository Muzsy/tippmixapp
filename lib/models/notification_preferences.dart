class NotificationPreferences {
  final bool tips;
  final bool friendActivity;
  final bool badge;
  final bool rewards;
  final bool system;

  const NotificationPreferences({
    this.tips = true,
    this.friendActivity = true,
    this.badge = true,
    this.rewards = true,
    this.system = true,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic>? map) {
    map = map ?? {};
    return NotificationPreferences(
      tips: map['tips'] as bool? ?? true,
      friendActivity: map['friendActivity'] as bool? ?? true,
      badge: map['badge'] as bool? ?? true,
      rewards: map['rewards'] as bool? ?? true,
      system: map['system'] as bool? ?? true,
    );
  }

  Map<String, bool> toMap() => {
    'tips': tips,
    'friendActivity': friendActivity,
    'badge': badge,
    'rewards': rewards,
    'system': system,
  };
}
