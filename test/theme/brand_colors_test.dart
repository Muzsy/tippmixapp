import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tippmixapp/theme/brand_colors.dart';
import 'package:tippmixapp/theme/brand_colors_presets.dart';
import 'package:tippmixapp/theme/theme_builder.dart';

void main() {
  test('BrandColors available in ThemeData', () {
    final light = buildTheme();
    expect(light.extension<BrandColors>(), brandColorsLight);

    final dark = buildTheme(brightness: Brightness.dark);
    expect(dark.extension<BrandColors>(), brandColorsDark);
  });
}
