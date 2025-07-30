import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:dynamic_color/test_utils.dart';
import 'package:dynamic_color/samples.dart';

import 'package:tippmixapp/theme/theme_builder.dart';
import 'package:tippmixapp/theme/brand_colors.dart';
import 'package:tippmixapp/theme/brand_colors_presets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildDynamicTheme uses system palette when available', () async {
    DynamicColorTestingUtils.setMockDynamicColors(
      corePalette: SampleCorePalettes.green,
    );
    final theme = await buildDynamicTheme(brightness: Brightness.light);
    final expected = SampleColorSchemes.green(Brightness.light).harmonized();
    expect(theme.colorScheme.primary, expected.primary);
    expect(theme.extension<BrandColors>(), brandColorsLight);
  });

  test('buildDynamicTheme falls back when palette unavailable', () async {
    DynamicColorTestingUtils.setMockDynamicColors();
    final fallback = buildTheme(brightness: Brightness.dark);
    final theme = await buildDynamicTheme(brightness: Brightness.dark);
    expect(theme.colorScheme.primary, fallback.colorScheme.primary);
    expect(theme.extension<BrandColors>(), brandColorsDark);
  });
}
