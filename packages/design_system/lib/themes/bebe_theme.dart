import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

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

  // ThemeData arma una colección grande de subtemas y extensiones. El tema
  // cambia de brillo, no de tokens, por lo que reconstruir ambos árboles en
  // cada cambio global provoca frames largos en pantallas densas como Familia.
  static final _lightThemeCache = Expando<ThemeData>('bebe.lightTheme');
  static final _darkThemeCache = Expando<ThemeData>('bebe.darkTheme');

  ThemeData lightTheme() {
    final cached = _lightThemeCache[this];
    if (cached != null) return cached;
    final theme = _buildTheme(
      brightness: Brightness.light,
      colors: lightColors,
      overlays: lightOverlays,
      elevation: lightElevation,
    );
    _lightThemeCache[this] = theme;
    return theme;
  }

  ThemeData darkTheme() {
    final cached = _darkThemeCache[this];
    if (cached != null) return cached;
    final theme = _buildTheme(
      brightness: Brightness.dark,
      colors: darkColors,
      overlays: darkOverlays,
      elevation: darkElevation,
    );
    _darkThemeCache[this] = theme;
    return theme;
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

    final colorScheme = _buildColorScheme(
      brightness: brightness,
      colors: effectiveColors,
      overlays: effectiveOverlays,
    );

    final textTheme = effectiveTypography.toTextTheme().apply(
      bodyColor: effectiveColors.text.neutralBody,
      displayColor: effectiveColors.text.neutralTitle,
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: effectiveTypography.fontFamily,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      scaffoldBackgroundColor: effectiveColors.background.neutralsPage,
      canvasColor: effectiveColors.background.neutralsPage,
      cardColor: effectiveColors.background.neutralsSurface,
      dividerColor: effectiveColors.border.neutralDefault,
      disabledColor: effectiveColors.text.neutralDisabled,
      shadowColor: effectiveOverlays.shadowDefault,
      splashColor: effectiveOverlays.interactionPressed,
      highlightColor: effectiveOverlays.interactionHover,
      hoverColor: effectiveOverlays.interactionHover,
      focusColor: effectiveOverlays.interactionFocus,

      extensions: <ThemeExtension<dynamic>>[
        effectiveColors,
        effectiveSpacing,
        effectiveTypography,
        effectiveBorderRadius,
        effectiveElevation,
        effectiveOverlays,
      ],

      iconTheme: IconThemeData(color: effectiveColors.icons.neutralDefault),

      appBarTheme: AppBarTheme(
        backgroundColor: effectiveColors.background.neutralsSurface,
        foregroundColor: effectiveColors.text.neutralTitle,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: effectiveColors.icons.neutralDefault),
        actionsIconTheme: IconThemeData(
          color: effectiveColors.icons.neutralDefault,
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: effectiveColors.text.neutralTitle,
          fontWeight: FontWeight.w700,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: effectiveColors.background.brandDefault,
        foregroundColor: effectiveColors.onPrimary.neutralDefault,
        focusColor: effectiveOverlays.interactionFocus,
        hoverColor: effectiveOverlays.interactionHover,
        splashColor: effectiveOverlays.interactionPressed,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 4,
        shape: const CircleBorder(),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: effectiveColors.background.neutralsSurface,
        selectedItemColor: effectiveColors.text.brandDefault,
        unselectedItemColor: effectiveColors.icons.neutralDefault,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: effectiveColors.background.neutralsSurface,
        indicatorColor: effectiveColors.background.brandSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
      ),

      dividerTheme: DividerThemeData(
        color: effectiveColors.border.neutralDefault,
        thickness: 1,
        space: 1,
      ),

      textSelectionTheme: TextSelectionThemeData(
        selectionColor: effectiveColors.background.brandSurface,
        selectionHandleColor: effectiveColors.background.brandDefault,
        cursorColor: effectiveColors.background.brandDefault,
      ),
    );
  }

  ColorScheme _buildColorScheme({
    required Brightness brightness,
    required BebeColor colors,
    required BebeOverlays overlays,
  }) {
    final base = brightness == Brightness.light
        ? const ColorScheme.light()
        : const ColorScheme.dark();

    return base.copyWith(
      primary: colors.background.brandDefault,
      onPrimary: colors.onPrimary.neutralDefault,
      primaryContainer: colors.background.brandSurface,
      onPrimaryContainer: colors.text.brandDefault,

      secondary: colors.background.accentDefault,
      // El lavanda claro requiere contenido oscuro para mantener contraste.
      onSecondary: colors.text.neutralDisplay,
      secondaryContainer: colors.background.accentSurface,
      onSecondaryContainer: colors.text.accentDefault,

      tertiary: colors.background.warningDefault,
      onTertiary: colors.text.neutralDisplay,
      tertiaryContainer: colors.background.warningSurface,
      onTertiaryContainer: colors.text.warningDefault,

      error: colors.background.errorDefault,
      onError: colors.onPrimary.neutralDefault,
      errorContainer: colors.background.errorSurface,
      onErrorContainer: colors.text.errorDefault,

      surface: colors.background.neutralsSurface,
      onSurface: colors.text.neutralBody,
      surfaceContainerLowest: colors.background.neutralsPage,
      surfaceContainer: colors.background.neutralsSurface,
      surfaceContainerHighest: colors.background.neutralsActive,
      onSurfaceVariant: colors.text.neutralLabel,

      outline: colors.border.neutralFocus,
      outlineVariant: colors.border.neutralDefault,

      shadow: overlays.shadowDefault,
      scrim: overlays.scrimDefault,

      inverseSurface: colors.background.neutralsFeedback,
      onInverseSurface: colors.onPrimary.neutralDefault,
      inversePrimary: colors.text.brandAlternative,

      surfaceTint: Colors.transparent,
    );
  }
}
