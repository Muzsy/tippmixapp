import 'package:flutter/material.dart';

/// Theme extension that defines brand specific colors used across the app.
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
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

  /// Google brand color used for social login buttons.
  final Color google;

  /// Apple brand color used for social login buttons.
  final Color apple;

  /// Facebook brand color used for social login buttons.
  final Color facebook;

  @override
  BrandColors copyWith({
    Color? gradientStart,
    Color? gradientEnd,
    Color? google,
    Color? apple,
    Color? facebook,
  }) {
    return BrandColors(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      google: google ?? this.google,
      apple: apple ?? this.apple,
      facebook: facebook ?? this.facebook,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      google: Color.lerp(google, other.google, t)!,
      apple: Color.lerp(apple, other.apple, t)!,
      facebook: Color.lerp(facebook, other.facebook, t)!,
    );
  }
}
