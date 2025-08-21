import 'dart:async';
import '../models/odds_drift.dart';
import 'api_football_service.dart';

class OddsDriftChecker {
  final ApiFootballService api;
  OddsDriftChecker(this.api);

  /// tips: list of maps with keys: fixtureId, market, selection, oddsSnapshot
  Future<OddsDriftResult> check(List<Map<String, dynamic>> tips) async {
    // Group by fixture for efficient fetching
    final byFixture = <String, List<Map<String, dynamic>>>{};
    for (final t in tips) {
      final f = t['fixtureId'] as String;
      byFixture.putIfAbsent(f, () => []).add(t);
    }
    final changes = <DriftItem>[];
    for (final entry in byFixture.entries) {
      final fixtureId = entry.key;
      final fresh = await api.getOddsForFixture(
        fixtureId,
      ); // implement this in ApiFootballService if not present
      for (final tip in entry.value) {
        final market = tip['market'] as String;
        final selection = tip['selection'] as String;
        final oldOdds = (tip['oddsSnapshot'] as num).toDouble();
        final newOdds = _readOdds(fresh, market, selection) ?? oldOdds;
        if (newOdds != oldOdds) {
          changes.add(
            DriftItem(
              fixtureId: fixtureId,
              market: market,
              selection: selection,
              oldOdds: oldOdds,
              newOdds: newOdds,
            ),
          );
        }
      }
    }
    return OddsDriftResult(changes);
  }

  double? _readOdds(
    Map<String, dynamic> fresh,
    String market,
    String selection,
  ) {
    // Map API‑Football markets to internal markets; currently expecting normalized keys
    try {
      final markets =
          fresh['markets'] as List<dynamic>?; // expected normalized structure
      if (markets == null) return null;
      for (final m in markets) {
        if (m['code'] == market) {
          final outcomes = m['outcomes'] as List<dynamic>?;
          if (outcomes == null) continue;
          for (final o in outcomes) {
            if (o['code'] == selection) {
              return (o['price'] as num).toDouble();
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
