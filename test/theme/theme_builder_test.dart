import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:tippmixapp/theme/theme_builder.dart';
import 'package:tippmixapp/theme/brand_colors.dart';
import 'package:tippmixapp/theme/brand_colors_presets.dart';

void main() {
  test('buildTheme generates correct ThemeData for schemes and brightness', () {
    final indexes = [0, 1];
    for (final index in indexes) {
      final scheme = FlexScheme.values[index];
      final light = buildTheme(scheme: scheme, brightness: Brightness.light);
      final expectedLight = FlexThemeData.light(
        scheme: scheme,
        useMaterial3: true,
        extensions: const <ThemeExtension<dynamic>>[brandColorsLight],
      );
      expect(light.colorScheme.primary, expectedLight.colorScheme.primary);
      expect(light.extension<BrandColors>(), brandColorsLight);

      final dark = buildTheme(scheme: scheme, brightness: Brightness.dark);
      final expectedDark = FlexThemeData.dark(
        scheme: scheme,
        useMaterial3: true,
        extensions: const <ThemeExtension<dynamic>>[brandColorsDark],
      );
      expect(dark.colorScheme.primary, expectedDark.colorScheme.primary);
      expect(dark.extension<BrandColors>(), brandColorsDark);
    }
  });
}
