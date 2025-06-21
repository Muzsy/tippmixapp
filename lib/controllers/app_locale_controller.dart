import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/language_utils.dart';

/// Handles the current [Locale] of the application.
class AppLocaleController extends StateNotifier<Locale> {
  AppLocaleController() : super(const Locale('en'));

  /// Loads the saved locale or falls back to the device language.
  Future<void> loadLocale() async {
    final saved = await LanguageUtils.getSavedLanguage();
    if (saved != null) {
      state = saved;
    } else {
      state = LanguageUtils.getCurrentLanguage();
    }
  }

  /// Sets and persists the new locale.
  Future<void> setLocale(Locale locale) async {
    state = locale;
    await LanguageUtils.saveSelectedLanguage(locale);
  }
}

/// Riverpod provider for [AppLocaleController].
final appLocaleControllerProvider =
    StateNotifierProvider<AppLocaleController, Locale>(
  (ref) => AppLocaleController(),
);
