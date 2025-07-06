import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

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
  ThemeService() : super(const ThemeState());

  /// Switches to the next available [FlexScheme].
  void toggleTheme() {
    final next = (state.schemeIndex + 1) % FlexScheme.values.length;
    state = state.copyWith(schemeIndex: next);
  }

  /// Toggles dark and light mode.
  void toggleDarkMode() {
    state = state.copyWith(isDark: !state.isDark);
  }

  /// Sets the scheme to [index] when within range of [FlexScheme.values].
  void setScheme(int index) {
    if (index >= 0 && index < FlexScheme.values.length) {
      state = state.copyWith(schemeIndex: index);
    }
  }
}

/// Riverpod provider for [ThemeService].
final themeServiceProvider =
    StateNotifierProvider<ThemeService, ThemeState>((ref) => ThemeService());
