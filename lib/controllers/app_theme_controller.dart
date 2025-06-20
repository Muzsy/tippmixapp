import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the current [ThemeMode] of the application.
class AppThemeController extends StateNotifier<ThemeMode> {
  AppThemeController() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) => state = mode;
}

/// Riverpod provider for [AppThemeController].
final appThemeControllerProvider =
    StateNotifierProvider<AppThemeController, ThemeMode>(
  (ref) => AppThemeController(),
);
