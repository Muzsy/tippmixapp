class UserStatsModel {
  final String uid;
  final String displayName;
  final int coins;
  final int totalBets;
  final int totalWins;
  final double winRate;
  final double? roi;
  final int? currentWinStreak;
  final int streakDays;
  final String? nextReward;
  final int coinsBalance;

  UserStatsModel({
    required this.uid,
    required this.displayName,
    required this.coins,
    required this.totalBets,
    required this.totalWins,
    required this.winRate,
    this.roi,
    this.currentWinStreak,
    this.streakDays = 0,
    this.nextReward,
    this.coinsBalance = 0,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) => UserStatsModel(
    uid: json['uid'] as String,
    displayName: json['displayName'] as String? ?? '',
    coins: json['coins'] as int? ?? 0,
    totalBets: json['totalBets'] as int? ?? 0,
    totalWins: json['totalWins'] as int? ?? 0,
    winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
    roi: (json['roi'] as num?)?.toDouble(),
    currentWinStreak: json['currentWinStreak'] as int?,
    streakDays: json['streakDays'] as int? ?? 0,
    nextReward: json['nextReward'] as String?,
    coinsBalance: json['coinsBalance'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'coins': coins,
    'totalBets': totalBets,
    'totalWins': totalWins,
    'winRate': winRate,
    if (roi != null) 'roi': roi,
    if (currentWinStreak != null) 'currentWinStreak': currentWinStreak,
    'streakDays': streakDays,
    'nextReward': nextReward,
    'coinsBalance': coinsBalance,
  };
}
