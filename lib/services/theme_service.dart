import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../env/env.dart';
import 'dart:async';
import '../theme/available_themes.dart';

/// Immutable state for [ThemeService].
class ThemeState {
  const ThemeState({this.schemeIndex = 0, this.isDark = false});

  /// Index of the selected [FlexScheme].
  final int schemeIndex;

  /// Whether dark mode is active.
  final bool isDark;

  /// Returns a copy with overridden fields.
  ThemeState copyWith({int? schemeIndex, bool? isDark}) {
    return ThemeState(
      schemeIndex: schemeIndex ?? this.schemeIndex,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ThemeState &&
      other.schemeIndex == schemeIndex &&
      other.isDark == isDark;

  @override
  int get hashCode => Object.hash(schemeIndex, isDark);
}

/// Service responsible for the application's theme state.
///
/// Holds the selected [FlexScheme] index and the dark mode flag. Widgets should
/// read the state via [themeServiceProvider] and call the exposed methods to
/// modify it.
class ThemeService extends StateNotifier<ThemeState> {
  ThemeService({SharedPreferences? prefs})
      : _prefs = prefs,
        super(const ThemeState());

  SharedPreferences? _prefs;

  static const _schemeKey = 'theme_scheme';
  static const _darkKey = 'theme_dark';

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Loads saved settings from local storage and Firestore.
  Future<void> hydrate() async {
    try {
      await _initPrefs();
      final index = _prefs?.getInt(_schemeKey);
      final dark = _prefs?.getBool(_darkKey);
      var newState = state.copyWith(
        schemeIndex: index ?? state.schemeIndex,
        isDark: dark ?? state.isDark,
      );
      if (Env.isSupabaseConfigured) {
        final u = sb.Supabase.instance.client.auth.currentUser;
        if (u != null) {
          final row = await sb.Supabase.instance.client
              .from('user_settings')
              .select('theme_scheme_index, theme_is_dark')
              .eq('user_id', u.id)
              .maybeSingle();
          final s = (row as Map?)?.cast<String, dynamic>();
          if (s != null) {
            final fsIndex = s['theme_scheme_index'] as int?;
            final fsDark = s['theme_is_dark'] as bool?;
            newState = newState.copyWith(
              schemeIndex: fsIndex ?? newState.schemeIndex,
              isDark: fsDark ?? newState.isDark,
            );
          }
        }
      }
      await _prefs?.setInt(_schemeKey, newState.schemeIndex);
      await _prefs?.setBool(_darkKey, newState.isDark);
      state = newState;
    } catch (_) {
      state = const ThemeState();
    }
  }

  /// Persists the current scheme index.
  Future<void> saveTheme() async {
    await _initPrefs();
    await _prefs?.setInt(_schemeKey, state.schemeIndex);
    if (Env.isSupabaseConfigured) {
      final u = sb.Supabase.instance.client.auth.currentUser;
      if (u != null) {
        await sb.Supabase.instance.client.from('user_settings').upsert({
          'user_id': u.id,
          'theme_scheme_index': state.schemeIndex,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }
    }
  }

  /// Persists the current dark mode flag.
  Future<void> saveDarkMode() async {
    await _initPrefs();
    await _prefs?.setBool(_darkKey, state.isDark);
    if (Env.isSupabaseConfigured) {
      final u = sb.Supabase.instance.client.auth.currentUser;
      if (u != null) {
        await sb.Supabase.instance.client.from('user_settings').upsert({
          'user_id': u.id,
          'theme_is_dark': state.isDark,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }
    }
  }

  /// Switches to the next available [FlexScheme].
  void toggleTheme() {
    final next = (state.schemeIndex + 1) % availableThemes.length;
    state = state.copyWith(schemeIndex: next);
    // ignore: discarded_futures
    saveTheme();
  }

  /// Toggles dark and light mode.
  void toggleDarkMode() {
    state = state.copyWith(isDark: !state.isDark);
    // ignore: discarded_futures
    saveDarkMode();
  }

  /// Sets the scheme to [index] when within range of [availableThemes].
  void setScheme(int index) {
    if (index >= 0 && index < availableThemes.length) {
      state = state.copyWith(schemeIndex: index);
      // ignore: discarded_futures
      saveTheme();
    }
  }
}

/// Riverpod provider for [ThemeService].
final themeServiceProvider = StateNotifierProvider<ThemeService, ThemeState>(
  (ref) => ThemeService(),
);
