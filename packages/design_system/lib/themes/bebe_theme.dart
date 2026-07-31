import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeTheme {
  const BebeTheme({
    this.lightColors,
    this.darkColors,
    this.spacing,
    this.typography,
    this.borderRadius,
    this.lightOverlays,
    this.darkOverlays,
    this.lightElevation,
    this.darkElevation,
  });

  factory BebeTheme.fromJson(Map<String, dynamic> json) {
    final colorsJson = json['Colors'] as Map<String, dynamic>? ?? const {};

    final overlaysJson = json['overlays'] as Map<String, dynamic>? ?? const {};

    final lightOverlaysJson =
        overlaysJson['Light'] as Map<String, dynamic>? ?? const {};

    final darkOverlaysJson =
        overlaysJson['Dark'] as Map<String, dynamic>? ?? const {};

    final lightOverlays = BebeOverlays.fromJson(lightOverlaysJson);

    final darkOverlays = BebeOverlays.fromJson(darkOverlaysJson);

    final elevationJson =
        json['elevation'] as Map<String, dynamic>? ?? const {};

    return BebeTheme(
      lightColors: colorsJson['Light'] != null
          ? BebeColor.fromJson(colorsJson['Light'] as Map<String, dynamic>)
          : null,
      darkColors: colorsJson['Dark'] != null
          ? BebeColor.fromJson(colorsJson['Dark'] as Map<String, dynamic>)
          : null,
      spacing: json['spacing'] != null
          ? BebeSpacing.fromJson(json['spacing'] as Map<String, dynamic>)
          : null,
      typography: json['Typography'] != null
          ? BebeTypography.fromJson(json['Typography'] as Map<String, dynamic>)
          : null,
      borderRadius: json['border-radius'] != null
          ? BebeBorderRadius.fromJson(
              json['border-radius'] as Map<String, dynamic>,
            )
          : null,
      lightOverlays: lightOverlays,
      darkOverlays: darkOverlays,
      lightElevation: elevationJson.isNotEmpty
          ? BebeElevation.fromJson(elevationJson, overlays: lightOverlays)
          : null,
      darkElevation: elevationJson.isNotEmpty
          ? BebeElevation.fromJson(elevationJson, overlays: darkOverlays)
          : null,
    );
  }

  final BebeColor? lightColors;
  final BebeColor? darkColors;

  final BebeSpacing? spacing;
  final BebeTypography? typography;
  final BebeBorderRadius? borderRadius;

  final BebeOverlays? lightOverlays;
  final BebeOverlays? darkOverlays;

  final BebeElevation? lightElevation;
  final BebeElevation? darkElevation;

  ThemeData lightTheme() {
    return _buildTheme(
      brightness: Brightness.light,
      colors: lightColors,
      overlays: lightOverlays,
      elevation: lightElevation,
    );
  }

  ThemeData darkTheme() {
    return _buildTheme(
      brightness: Brightness.dark,
      colors: darkColors,
      overlays: darkOverlays,
      elevation: darkElevation,
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
    required BebeColor? colors,
    required BebeOverlays? overlays,
    required BebeElevation? elevation,
  }) {
    final effectiveColors = colors ?? BebeColor.empty();

    final effectiveSpacing = spacing ?? BebeSpacing.fallback();

    final effectiveTypography = typography ?? BebeTypography.empty();

    final effectiveBorderRadius = borderRadius ?? BebeBorderRadius.fallback();

    final effectiveOverlays =
        overlays ??
        (brightness == Brightness.light
            ? BebeOverlays.fallbackLight()
            : BebeOverlays.fallbackDark());

    final effectiveElevation =
        elevation ?? BebeElevation.fallback(overlays: effectiveOverlays);

    final theme = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: effectiveTypography.fontFamily,

      extensions: <ThemeExtension<dynamic>>[
        effectiveColors,
        effectiveSpacing,
        effectiveTypography,
        effectiveBorderRadius,
        effectiveElevation,
        effectiveOverlays,
      ],

      scaffoldBackgroundColor: effectiveColors.background.neutralsSurface,

      colorScheme: brightness == Brightness.light
          ? const ColorScheme.light()
          : const ColorScheme.dark(),

      textSelectionTheme: TextSelectionThemeData(
        selectionColor: effectiveColors.background.accentDefault,
        selectionHandleColor: effectiveColors.text.accentDefault,
      ),
    );

    return theme.copyWith(textTheme: effectiveTypography.toTextTheme());
  }
}
