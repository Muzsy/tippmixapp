import 'package:flutter/material.dart';

/// Theme extension that defines brand specific colors used across the app.
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  final Color google;
  final Color apple;
  final Color facebook;
  const BrandColors({
    required this.gradientStart,
    required this.gradientEnd,
    required this.google,
    required this.apple,
    required this.facebook,
  });

  /// Gradient start color.
  final Color gradientStart;

  /// Gradient end color.
  final Color gradientEnd;

  @override
  BrandColors copyWith({
    Color? google,
    Color? apple,
    Color? facebook,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return BrandColors(
      google: google ?? this.google,
      apple: apple ?? this.apple,
      facebook: facebook ?? this.facebook,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      google: Color.lerp(google, other.google, t)!,
      apple: Color.lerp(apple, other.apple, t)!,
      facebook: Color.lerp(facebook, other.facebook, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }
}
