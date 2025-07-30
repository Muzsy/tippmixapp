import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Represents a single AI generated betting tip.
class AiTip {
  final String team;
  final int percent;

  AiTip({required this.team, required this.percent});

  Map<String, dynamic> toJson() => {'team': team, 'percent': percent};

  factory AiTip.fromJson(Map<String, dynamic> json) {
    return AiTip(team: json['team'] as String, percent: json['percent'] as int);
  }
}

/// Service returning at most one AI tip per day.
class AiTipProvider {
  static const _cacheKey = 'ai_tip_cache';
  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Returns the daily AI betting tip. Generates a new one if none cached.
  Future<AiTip?> getDailyTip() async {
    await _initPrefs();
    final stored = _prefs!.getString(_cacheKey);
    final today = DateTime.now();

    if (stored != null) {
      final data = jsonDecode(stored) as Map<String, dynamic>;
      final date = DateTime.parse(data['date'] as String);
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        return AiTip.fromJson(Map<String, dynamic>.from(data['tip']));
      }
    }

    final tip = await _generateTip();
    if (tip != null) {
      final encoded = jsonEncode({
        'date': today.toIso8601String(),
        'tip': tip.toJson(),
      });
      await _prefs!.setString(_cacheKey, encoded);
    }
    return tip;
  }

  Future<AiTip?> _generateTip() async {
    // Placeholder implementation using random data.
    final teams = ['Bayern', 'Real Madrid', 'Juventus'];
    final team = teams[Random().nextInt(teams.length)];
    final percent = 70 + Random().nextInt(21); // 70-90
    return AiTip(team: team, percent: percent);
  }
}
