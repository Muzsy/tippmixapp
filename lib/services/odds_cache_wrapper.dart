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
    String? country,
    String? league,
    DateTime? date,
  }) async {
    await _initPrefs();
    final key = _cacheKey(
      sport: sport,
      country: country,
      league: league,
      date: date,
    );
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
      country: country,
      league: league,
      date: date,
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
    String? country,
    String? league,
    DateTime? date,
  }) {
    final datePart = date != null
        ? date.toIso8601String().split('T').first
        : '';
    return 'odds_${sport}|$datePart|${country ?? ''}|${league ?? ''}';
  }
}
