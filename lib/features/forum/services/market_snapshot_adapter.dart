import 'dart:async';

import 'package:tippmixapp/services/api_football_service.dart';

/// Provides cached market/odd snapshots for the forum composer.
class MarketSnapshotAdapter {
  MarketSnapshotAdapter({ApiFootballService? api, Duration? ttl})
    : _api = api ?? ApiFootballService(),
      _ttl = ttl ?? const Duration(minutes: 15);

  final ApiFootballService _api;
  final Duration _ttl;
  final _cache = <int, _CacheEntry>{};

  /// Returns odds/market snapshot for [fixtureId].
  /// Results are cached in-memory to avoid excessive API calls.
  Future<Map<String, dynamic>> getSnapshot(int fixtureId, {int? season}) async {
    final entry = _cache[fixtureId];
    if (entry != null && DateTime.now().isBefore(entry.expiry)) {
      return entry.data;
    }
    final data = await _api.getOddsForFixture(
      fixtureId.toString(),
      season: season,
    );
    _cache[fixtureId] = _CacheEntry(data, DateTime.now().add(_ttl));
    return data;
  }

  /// Clears the in-memory cache.
  void clearCache() => _cache.clear();
}

class _CacheEntry {
  _CacheEntry(this.data, this.expiry);
  final Map<String, dynamic> data;
  final DateTime expiry;
}
