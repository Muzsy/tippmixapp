import 'odds_market.dart';

/// Egy fogadóiroda ajánlata egy eseményhez.
class OddsBookmaker {
  final String key; // Pl. "bet365"
  final String title; // Pl. "Bet365"
  final List<OddsMarket> markets;

  OddsBookmaker({
    required this.key,
    required this.title,
    required this.markets,
  });

  factory OddsBookmaker.fromJson(Map<String, dynamic> json) {
    return OddsBookmaker(
      key: json['key'] as String,
      title: json['title'] as String,
      markets: (json['markets'] as List)
          .map((m) => OddsMarket.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'title': title,
    'markets': markets.map((m) => m.toJson()).toList(),
  };
}
