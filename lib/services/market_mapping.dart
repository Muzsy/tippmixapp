class MarketMapping {
  static const String h2h = 'h2h';
  static const String overUnder = 'ou';
  static const String bothTeamsToScore = 'btts';
  static const String asianHandicap = 'ah';

  static String? fromApiFootball(String key) {
    switch (key.toLowerCase()) {
      case '1x2':
      case 'h2h':
        return h2h;
      case 'over_under':
      case 'ou':
      case 'totals':
        return overUnder;
      case 'btts':
      case 'both_teams_to_score':
        return bothTeamsToScore;
      case 'ah':
      case 'asian_handicap':
        return asianHandicap;
      default:
        return null;
    }
  }
}
