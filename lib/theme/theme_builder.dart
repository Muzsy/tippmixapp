import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

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
  if (useDark) {
    return FlexThemeData.dark(
      scheme: scheme,
      useMaterial3: true,
    );
  }
  return FlexThemeData.light(
    scheme: scheme,
    useMaterial3: true,
  );
}
