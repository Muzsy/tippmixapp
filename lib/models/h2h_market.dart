import 'odds_market.dart';
import 'odds_outcome.dart';

/// Specialized market class for H2H (1X2) outcomes.
class H2HMarket extends OddsMarket {
  H2HMarket({required List<OddsOutcome> outcomes})
      : super(key: 'h2h', outcomes: outcomes);

  factory H2HMarket.fromJson(Map<String, dynamic> json) {
    final outcomes = (json['outcomes'] as List?)
            ?.map((o) => OddsOutcome.fromJson(Map<String, dynamic>.from(o)))
            .toList() ??
        [];
    return H2HMarket(outcomes: outcomes);
  }
}
