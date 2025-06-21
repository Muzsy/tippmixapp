import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageUtils {
  static const _key = 'selectedLanguage';
  static const _supported = ['hu', 'en', 'de'];

  /// Returns [SharedPreferences] instance or null if unavailable.
  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  /// Returns the saved language or null if not set.
  static Future<Locale?> getSavedLanguage() async {
    final prefs = await _prefs();
    final code = prefs?.getString(_key);
    return code != null ? Locale(code) : null;
  }

  /// Persists the selected [locale].
  static Future<void> saveSelectedLanguage(Locale locale) async {
    final prefs = await _prefs();
    if (prefs != null) {
      await prefs.setString(_key, locale.languageCode);
    }
  }

  /// Returns the current device language with english fallback.
  static Locale getCurrentLanguage() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return _supported.contains(code) ? Locale(code) : const Locale('en');
  }
}
