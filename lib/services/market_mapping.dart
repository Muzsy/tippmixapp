import '../models/h2h_market.dart';
import '../models/odds_outcome.dart';

class MarketMapping {
  static const String h2h = 'h2h';
  static const String overUnder = 'ou';
  static const String bothTeamsToScore = 'btts';
  static const String asianHandicap = 'ah';

  static const h2hAliases = {
    'H2H',
    '1X2',
    '1x2',
    'Match Winner',
    'Winner',
    'Full Time Result',
  };

  static String? fromApiFootball(String key) {
    switch (key.toLowerCase()) {
      case '1x2':
      case 'h2h':
      case 'match winner':
      case 'full time result':
      case 'winner':
        return h2h;
      case 'over_under':
      case 'ou':
      case 'totals':
      case 'goals over/under':
        return overUnder;
      case 'btts':
      case 'both teams to score':
        return bothTeamsToScore;
      case 'ah':
      case 'asian_handicap':
      case 'handicap':
        return asianHandicap;
      default:
        return null;
    }
  }

  /// Parse API‑Football odds válaszból H2H (1X2) piaccá.
  /// Elvárt forma: { response: [ { bookmakers: [ { bets: [ { name: 'Match Winner'|'1X2', values: [ {value: 'Home|1|Draw|X|Away|2', odd: '1.50'} ] } ] } ] } ] }
  static H2HMarket? h2hFromApi(Map<String, dynamic> json) {
    final resp = json['response'];
    if (resp is! List || resp.isEmpty) return null;
    final first = resp.first as Map<String, dynamic>;
    final bookmakers = (first['bookmakers'] as List?) ?? const [];
    for (final b in bookmakers) {
      final bm = b as Map<String, dynamic>;
      final bets = (bm['bets'] as List?) ?? const [];
      for (final bet in bets) {
        final m = bet as Map<String, dynamic>;
        final rawName = (m['name'] ?? m['key'] ?? '').toString();
        if (!h2hAliases.contains(rawName)) continue;
        final values = (m['values'] as List?) ?? const [];
        final outs = <OddsOutcome>[];
        for (final v in values) {
          final mv = v as Map<String, dynamic>;
          final val = (mv['value'] ?? '').toString().toLowerCase();
          final oddStr = (mv['odd'] ?? '').toString();
          final price = double.tryParse(oddStr.replaceAll(',', '.'));
          if (price == null) continue;
          if (val.contains('home') || val == '1') {
            outs.add(OddsOutcome(name: 'Home', price: price));
          } else if (val.contains('draw') || val == 'x') {
            outs.add(OddsOutcome(name: 'Draw', price: price));
          } else if (val.contains('away') || val == '2') {
            outs.add(OddsOutcome(name: 'Away', price: price));
          }
        }
        if (outs.isNotEmpty) {
          // Rögzített H‑D‑V sorrend
          const order = {'Home': 0, 'Draw': 1, 'Away': 2};
          outs.sort(
            (a, b) => (order[a.name] ?? 0).compareTo(order[b.name] ?? 0),
          );
          return H2HMarket(outcomes: outs);
        }
      }
    }
    return null;
  }
}
