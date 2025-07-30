import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'brand_colors_presets.dart';

/// Generates [ThemeData] using [FlexColorScheme].
///
/// The [scheme] parameter defines the base color scheme. [brightness] switches
/// between light and dark modes. Both parameters have defaults so the function
/// can easily be expanded for dynamic platform colors or additional skins.
ThemeData buildTheme({
  FlexScheme scheme = FlexScheme.dellGenoa,
  Brightness brightness = Brightness.light,
}) {
  final useDark = brightness == Brightness.dark;
  final brand = useDark ? brandColorsDark : brandColorsLight;
  if (useDark) {
    return FlexThemeData.dark(
      scheme: scheme,
      useMaterial3: true,
      extensions: <ThemeExtension<dynamic>>[brand],
    );
  }
  return FlexThemeData.light(
    scheme: scheme,
    useMaterial3: true,
    extensions: <ThemeExtension<dynamic>>[brand],
  );
}

/// Generates [ThemeData] using system dynamic color when available.
///
/// Falls back to [buildTheme] when dynamic color is not supported or
/// retrieval fails. This uses [DynamicColorPlugin.getCorePalette] on
/// Android 12+ to obtain the system core palette.
Future<ThemeData> buildDynamicTheme({
  FlexScheme scheme = FlexScheme.dellGenoa,
  Brightness brightness = Brightness.light,
}) async {
  try {
    final palette = await DynamicColorPlugin.getCorePalette();
    if (palette != null) {
      final colorScheme = palette
          .toColorScheme(brightness: brightness)
          .harmonized();
      final brand = brightness == Brightness.dark
          ? brandColorsDark
          : brandColorsLight;
      return ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        extensions: <ThemeExtension<dynamic>>[brand],
      );
    }
  } catch (_) {
    // ignore any platform or plugin errors and fall back to scheme theme
  }
  return buildTheme(scheme: scheme, brightness: brightness);
}
