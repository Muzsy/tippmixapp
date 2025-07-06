import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'brand_colors.dart';

/// Collection of predefined [BrandColors] presets.
///
/// Add new presets here when introducing additional skins.
const BrandColors brandColorsLight = BrandColors(
  gradientStart: FlexColor.dellGenoaGreenLightPrimary,
  gradientEnd: FlexColor.dellGenoaGreenLightSecondary,
);

const BrandColors brandColorsDark = BrandColors(
  gradientStart: FlexColor.dellGenoaGreenDarkPrimary,
  gradientEnd: FlexColor.dellGenoaGreenDarkSecondary,
);
