import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Handles the current [Locale] of the application.
class AppLocaleController extends StateNotifier<Locale> {
  AppLocaleController() : super(const Locale('en'));

  void setLocale(Locale locale) => state = locale;
}

/// Riverpod provider for [AppLocaleController].
final appLocaleControllerProvider =
    StateNotifierProvider<AppLocaleController, Locale>(
  (ref) => AppLocaleController(),
);
