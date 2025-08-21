import '../models/h2h_market.dart';
import '../models/odds_outcome.dart';

class MarketMapping {
  static const String h2h = 'h2h';
  static const String overUnder = 'ou';
  static const String bothTeamsToScore = 'btts';
  static const String asianHandicap = 'ah';

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
      case 'both_teams_to_score':
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
  /// Vár forma: {response → bookmakers → bets → values}
  static H2HMarket? h2hFromApi(
    Map<String, dynamic> json, {
    int? preferredBookmakerId,
    String? homeName,
    String? awayName,
  }) {
    final resp = json['response'];
    if (resp is! List || resp.isEmpty) return null;
    const aliases = {
      'match winner',
      '1x2',
      'full time result',
      'match result',
      'winner',
      'home/away',
    };
    // 1) If a preferred bookmaker ID is provided, try that first
    if (preferredBookmakerId != null) {
      for (final item in resp) {
        final bms = (item is Map<String, dynamic>) ? item['bookmakers'] : null;
        if (bms is! List) continue;
        for (final b in bms) {
          final bid = (b is Map<String, dynamic>) ? b['id'] : null;
          if (bid is! int || bid != preferredBookmakerId) continue;
          final bets = (b is Map<String, dynamic>) ? b['bets'] : null;
          if (bets is! List) continue;
          for (final bet in bets) {
            final m = bet as Map<String, dynamic>;
            final raw = (m['name'] ?? m['key'] ?? '').toString().toLowerCase();
            if (!aliases.contains(raw)) continue;
            final values = (m['values'] as List?) ?? const [];
            String normalize(String s) => s
                .toLowerCase()
                .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
                .replaceAll(' fc', '')
                .trim();
            final hn = homeName != null ? normalize(homeName) : null;
            final an = awayName != null ? normalize(awayName) : null;
            OddsOutcome? home;
            OddsOutcome? draw;
            OddsOutcome? away;
            for (final v in values) {
              if (v is! Map) continue;
              final val0 = (v['value'] ?? '').toString();
              final val = val0.toLowerCase();
              final valn = normalize(val0);
              final oddStr = (v['odd'] ?? '').toString();
              final price = double.tryParse(oddStr.replaceAll(',', '.'));
              if (price == null) continue;
              if (val == 'home' || val == '1' || (hn != null && valn == hn)) {
                home = OddsOutcome(name: 'Home', price: price);
              } else if (val == 'draw' || val == 'x') {
                draw = OddsOutcome(name: 'Draw', price: price);
              } else if (val == 'away' ||
                  val == '2' ||
                  (an != null && valn == an)) {
                away = OddsOutcome(name: 'Away', price: price);
              }
            }
            final outs = [
              if (home != null) home,
              if (draw != null) draw,
              if (away != null) away,
            ];
            if (outs.isNotEmpty) return H2HMarket(outcomes: outs);
          }
        }
      }
    }

    for (final item in resp) {
      final bms = (item is Map<String, dynamic>) ? item['bookmakers'] : null;
      if (bms is! List) continue;
      for (final b in bms) {
        final bets = (b is Map<String, dynamic>) ? b['bets'] : null;
        if (bets is! List) continue;
        for (final bet in bets) {
          final m = bet as Map<String, dynamic>;
          final raw = (m['name'] ?? m['key'] ?? '').toString().toLowerCase();
          if (!aliases.contains(raw)) continue;
          final values = (m['values'] as List?) ?? const [];
          String normalize(String s) => s
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
              .replaceAll(' fc', '')
              .trim();
          final hn = homeName != null ? normalize(homeName) : null;
          final an = awayName != null ? normalize(awayName) : null;
          OddsOutcome? home;
          OddsOutcome? draw;
          OddsOutcome? away;
          for (final v in values) {
            if (v is! Map) continue;
            final val0 = (v['value'] ?? '').toString();
            final val = val0.toLowerCase();
            final valn = normalize(val0);
            final oddStr = (v['odd'] ?? '').toString();
            final price = double.tryParse(oddStr.replaceAll(',', '.'));
            if (price == null) continue;
            if (val == 'home' || val == '1' || (hn != null && valn == hn)) {
              home = OddsOutcome(name: 'Home', price: price);
            } else if (val == 'draw' || val == 'x') {
              draw = OddsOutcome(name: 'Draw', price: price);
            } else if (val == 'away' ||
                val == '2' ||
                (an != null && valn == an)) {
              away = OddsOutcome(name: 'Away', price: price);
            }
          }
          final outs = [
            if (home != null) home,
            if (draw != null) draw,
            if (away != null) away,
          ];
          if (outs.isNotEmpty) return H2HMarket(outcomes: outs);
        }
      }
    }
    return null;
  }
}
