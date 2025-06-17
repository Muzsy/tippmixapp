import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppColorTheme { pink, blue }

class ThemeNotifier extends StateNotifier<AppColorTheme> {
  ThemeNotifier() : super(AppColorTheme.blue);

  void toggleTheme() {
    state = state == AppColorTheme.pink ? AppColorTheme.blue : AppColorTheme.pink;
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, AppColorTheme>((ref) => ThemeNotifier());
