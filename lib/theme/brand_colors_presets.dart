import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'brand_colors.dart';

/// Collection of predefined [BrandColors] presets.
///
/// Add new presets here when introducing additional skins.
const BrandColors brandColorsLight = BrandColors(
  gradientStart: FlexColor.dellGenoaGreenLightPrimary,
  gradientEnd: FlexColor.dellGenoaGreenLightSecondary,
  google: Color(0xFFDB4437),
  apple: Color(0xFF000000),
  facebook: Color(0xFF1877F3),
);

const BrandColors brandColorsDark = BrandColors(
  gradientStart: FlexColor.dellGenoaGreenDarkPrimary,
  gradientEnd: FlexColor.dellGenoaGreenDarkSecondary,
  google: Color(0xFFDB4437),
  apple: Color(0xFF000000),
  facebook: Color(0xFF1877F3),
);
