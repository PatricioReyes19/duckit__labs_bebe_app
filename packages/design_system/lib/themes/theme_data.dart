import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeThemeData extends ThemeExtension<BebeThemeData> {
  const BebeThemeData({
    required this.colors,
    required this.spacing,
    required this.typography,
    required this.borderRadius,
    required this.elevation,
    required this.overlays,
  });

  final BebeColor colors;
  final BebeSpacing spacing;
  final BebeTypography typography;
  final BebeBorderRadius borderRadius;
  final BebeElevation elevation;
  final BebeOverlays overlays;

  @override
  BebeThemeData copyWith({
    BebeColor? colors,
    BebeSpacing? spacing,
    BebeTypography? typography,
    BebeBorderRadius? borderRadius,
    BebeElevation? elevation,
    BebeOverlays? overlays,
  }) {
    return BebeThemeData(
      colors: colors ?? this.colors,
      spacing: spacing ?? this.spacing,
      typography: typography ?? this.typography,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      overlays: overlays ?? this.overlays,
    );
  }

  @override
  BebeThemeData lerp(covariant ThemeExtension<BebeThemeData>? other, double t) {
    if (other is! BebeThemeData) {
      return this;
    }

    return BebeThemeData(
      colors: colors.lerp(other.colors, t),
      spacing: spacing.lerp(other.spacing, t),
      typography: typography.lerp(other.typography, t),
      borderRadius: borderRadius.lerp(other.borderRadius, t),
      elevation: elevation.lerp(other.elevation, t),
      overlays: overlays.lerp(other.overlays, t),
    );
  }
}
