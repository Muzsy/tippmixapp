import 'odds_outcome.dart';

/// Egy fogadási piac, pl. "h2h" (1X2), "totals", stb.
class OddsMarket {
  final String key; // Pl. "h2h"
  final List<OddsOutcome> outcomes;

  OddsMarket({required this.key, required this.outcomes});

  factory OddsMarket.fromJson(Map<String, dynamic> json) {
    return OddsMarket(
      key: json['key'] as String,
      outcomes: (json['outcomes'] as List)
          .map((o) => OddsOutcome.fromJson(o))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'outcomes': outcomes.map((o) => o.toJson()).toList(),
  };
}
