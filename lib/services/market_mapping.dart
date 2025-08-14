import '../models/h2h_market.dart';

class MarketMapping {
  static const String h2h = 'h2h';
  static const String overUnder = 'ou';
  static const String bothTeamsToScore = 'btts';
  static const String asianHandicap = 'ah';

  static const h2hAliases = {
    'H2H', '1X2', '1x2', 'Match Winner', 'Winner', 'Full Time Result'
  };

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

  static H2HMarket? h2hFromApi(Map<String, dynamic> json) {
    final markets = json['markets'] as List<dynamic>?;
    if (markets == null) return null;
    for (final m in markets) {
      final map = Map<String, dynamic>.from(m as Map);
      final name = (map['key'] ?? map['name'] ?? '').toString();
      if (h2hAliases.contains(name)) {
        return H2HMarket.fromJson(map);
      }
    }
    return null;
  }
}
