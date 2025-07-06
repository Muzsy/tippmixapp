import 'package:flutter/material.dart';

/// Theme extension that defines brand specific colors used across the app.
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.gradientStart,
    required this.gradientEnd,
  });

  /// Gradient start color.
  final Color gradientStart;

  /// Gradient end color.
  final Color gradientEnd;

  @override
  BrandColors copyWith({
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return BrandColors(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }
}
