enum BadgeCondition { firstWin, streak3, parlayWin, lateNightWin, comebackWin }

class BadgeData {
  final String key;
  final String iconName;
  final BadgeCondition condition;

  const BadgeData({
    required this.key,
    required this.iconName,
    required this.condition,
  });
}
