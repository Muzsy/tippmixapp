import '../models/badge.dart';

/// Default badge configurations used by [BadgeService].
/// Each badge has a localization key, icon name and condition.
const List<BadgeData> badgeConfigs = [
  BadgeData(
    key: 'badge_rookie',
    iconName: 'star',
    condition: BadgeCondition.firstWin,
  ),
  BadgeData(
    key: 'badge_hot_streak',
    iconName: 'whatshot',
    condition: BadgeCondition.streak3,
  ),
  BadgeData(
    key: 'badge_parlay_pro',
    iconName: 'track_changes',
    condition: BadgeCondition.parlayWin,
  ),
  BadgeData(
    key: 'badge_night_owl',
    iconName: 'nights_stay',
    condition: BadgeCondition.lateNightWin,
  ),
  BadgeData(
    key: 'badge_comeback_kid',
    iconName: 'bolt',
    condition: BadgeCondition.comebackWin,
  ),
];
