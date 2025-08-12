import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/odds_event.dart';
import '../models/api_response.dart';
import 'api_football_service.dart';

class OddsCacheWrapper {
  static const _ttl = Duration(minutes: 15);
  final ApiFootballService _service;
  SharedPreferences? _prefs;

  OddsCacheWrapper(this._service, [SharedPreferences? prefs]) {
    _prefs = prefs;
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<ApiResponse<List<OddsEvent>>> getOdds({
    required String sport,
    String? league,
    DateTime? from,
    DateTime? to,
  }) async {
    await _initPrefs();
    final key = _cacheKey(sport: sport, league: league, from: from, to: to);
    final cached = _prefs!.getString(key);
    if (cached != null) {
      final Map<String, dynamic> data = jsonDecode(cached);
      final expiry = DateTime.parse(data['expiry'] as String);
      if (DateTime.now().isBefore(expiry)) {
        final events = (data['events'] as List)
            .map((e) => OddsEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return ApiResponse(data: events);
      } else {
        await _prefs!.remove(key);
      }
    }

    final response = await _service.getOdds(
      sport: sport,
      league: league,
      from: from,
      to: to,
    );

    if (response.errorType == ApiErrorType.none && response.data != null) {
      final expiry = DateTime.now().add(_ttl);
      final encoded = jsonEncode({
        'expiry': expiry.toIso8601String(),
        'events': response.data!.map((e) => e.toJson()).toList(),
      });
      await _prefs!.setString(key, encoded);
    }

    return response;
  }

  String _cacheKey({
    required String sport,
    String? league,
    DateTime? from,
    DateTime? to,
  }) {
    final sb = StringBuffer('odds_')..write(sport);
    if (league != null) sb.write('_$league');
    if (from != null) sb.write('_from_${from.toIso8601String()}');
    if (to != null) sb.write('_to_${to.toIso8601String()}');
    return sb.toString();
  }
}
