import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tippmixapp/theme/brand_colors.dart';
import 'package:tippmixapp/theme/brand_colors_presets.dart';
import 'package:tippmixapp/theme/theme_builder.dart';

void main() {
  testWidgets('BrandColors accessible via Theme.of for light mode', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(),
      home: Builder(
        builder: (context) {
          final colors = Theme.of(context).extension<BrandColors>()!;
          return Container(key: const Key('light'), color: colors.gradientStart);
        },
      ),
    ));

    final context = tester.element(find.byKey(const Key('light')));
    final colors = Theme.of(context).extension<BrandColors>();
    expect(colors, brandColorsLight);
    expect(colors!.gradientStart, brandColorsLight.gradientStart);
    expect(colors.gradientEnd, brandColorsLight.gradientEnd);
  });

  testWidgets('BrandColors accessible via Theme.of for dark mode', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(brightness: Brightness.dark),
      home: Builder(
        builder: (context) {
          final colors = Theme.of(context).extension<BrandColors>()!;
          return Container(key: const Key('dark'), color: colors.gradientEnd);
        },
      ),
    ));

    final context = tester.element(find.byKey(const Key('dark')));
    final colors = Theme.of(context).extension<BrandColors>();
    expect(colors, brandColorsDark);
    expect(colors!.gradientStart, brandColorsDark.gradientStart);
    expect(colors.gradientEnd, brandColorsDark.gradientEnd);
  });
}
