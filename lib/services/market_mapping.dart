import '../models/h2h_market.dart';
import '../models/odds_outcome.dart';

class MarketMapping {
  static const String h2h = 'h2h';
  static const String overUnder = 'ou';
  static const String bothTeamsToScore = 'btts';
  static const String asianHandicap = 'ah';

  static const _h2hAliases = <String>{
    'match winner',
    '1x2',
    'full time result',
    'match result',
    'winner',
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

  /// API-Football /odds válasz → H2HMarket
  static H2HMarket? h2hFromApi(
    Map<String, dynamic> json, {
    String? homeLabel,
    String? awayLabel,
  }) {
    final resp = json['response'];
    if (resp is! List || resp.isEmpty) return null;

    for (final item in resp) {
      final bms = item is Map<String, dynamic> ? item['bookmakers'] : null;
      if (bms is! List) continue;
      for (final b in bms) {
        final bets = (b is Map<String, dynamic>) ? b['bets'] : null;
        if (bets is! List) continue;
        for (final bet in bets) {
          final betName = (bet is Map<String, dynamic>)
              ? (bet['name'] ?? '').toString().toLowerCase()
              : '';
          if (!_h2hAliases.contains(betName)) continue;
          final values = (bet['values'] as List?) ?? const [];
          OddsOutcome? home;
          OddsOutcome? draw;
          OddsOutcome? away;
          for (final v in values) {
            if (v is! Map) continue;
            final val = (v['value'] ?? '').toString().toLowerCase();
            final oddStr = (v['odd'] ?? '').toString();
            final price = double.tryParse(oddStr.replaceAll(',', '.'));
            if (price == null) continue;
            if (val == 'home' || val == '1') {
              home = OddsOutcome(name: homeLabel ?? 'Home', price: price);
            } else if (val == 'draw' || val == 'x') {
              draw = OddsOutcome(name: 'Draw', price: price);
            } else if (val == 'away' || val == '2') {
              away = OddsOutcome(name: awayLabel ?? 'Away', price: price);
            }
          }
          final outs = <OddsOutcome>[
            if (home != null) home,
            if (draw != null) draw,
            if (away != null) away,
          ];
          if (outs.isEmpty) continue;
          return H2HMarket(outcomes: outs);
        }
      }
    }
    return null;
  }
}
