import 'package:flutter/material.dart';

@immutable
class AppLayoutTheme extends ThemeExtension<AppLayoutTheme> {
  const AppLayoutTheme({
    required this.backgroundColor,
    required this.surfaceColor,
    required this.selectedColor,
    required this.selectedContainerColor,
    required this.unselectedColor,
    required this.primaryActionColor,
    required this.primaryActionForegroundColor,
    required this.primaryActionShadowColor,
    required this.borderColor,
    required this.shadowColor,
    required this.errorColor,
  });

  factory AppLayoutTheme.fromColorScheme(ColorScheme scheme) {
    return AppLayoutTheme(
      // surfaceContainerLowest representa el fondo general de la app.
      backgroundColor: scheme.surfaceContainerLowest,
      // surface representa barras, headers y elementos elevados.
      surfaceColor: scheme.surface,
      selectedColor: scheme.primary,
      selectedContainerColor: scheme.primaryContainer,
      unselectedColor: scheme.onSurfaceVariant,
      primaryActionColor: scheme.primary,
      primaryActionForegroundColor: scheme.onPrimary,
      primaryActionShadowColor: scheme.primary.withValues(alpha: 0.24),
      borderColor: scheme.outlineVariant,
      shadowColor: scheme.shadow.withValues(alpha: 0.10),
      errorColor: scheme.error,
    );
  }

  final Color backgroundColor;
  final Color surfaceColor;

  final Color selectedColor;
  final Color selectedContainerColor;
  final Color unselectedColor;

  final Color primaryActionColor;
  final Color primaryActionForegroundColor;
  final Color primaryActionShadowColor;

  final Color borderColor;
  final Color shadowColor;
  final Color errorColor;

  static AppLayoutTheme of(BuildContext context) {
    return Theme.of(context).extension<AppLayoutTheme>() ??
        AppLayoutTheme.fromColorScheme(Theme.of(context).colorScheme);
  }

  @override
  AppLayoutTheme copyWith({
    Color? backgroundColor,
    Color? surfaceColor,
    Color? selectedColor,
    Color? selectedContainerColor,
    Color? unselectedColor,
    Color? primaryActionColor,
    Color? primaryActionForegroundColor,
    Color? primaryActionShadowColor,
    Color? borderColor,
    Color? shadowColor,
    Color? errorColor,
  }) {
    return AppLayoutTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedContainerColor:
          selectedContainerColor ?? this.selectedContainerColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      primaryActionColor: primaryActionColor ?? this.primaryActionColor,
      primaryActionForegroundColor:
          primaryActionForegroundColor ?? this.primaryActionForegroundColor,
      primaryActionShadowColor:
          primaryActionShadowColor ?? this.primaryActionShadowColor,
      borderColor: borderColor ?? this.borderColor,
      shadowColor: shadowColor ?? this.shadowColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  AppLayoutTheme lerp(
    covariant ThemeExtension<AppLayoutTheme>? other,
    double t,
  ) {
    if (other is! AppLayoutTheme) {
      return this;
    }

    return AppLayoutTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t)!,
      selectedContainerColor: Color.lerp(
        selectedContainerColor,
        other.selectedContainerColor,
        t,
      )!,
      unselectedColor: Color.lerp(unselectedColor, other.unselectedColor, t)!,
      primaryActionColor: Color.lerp(
        primaryActionColor,
        other.primaryActionColor,
        t,
      )!,
      primaryActionForegroundColor: Color.lerp(
        primaryActionForegroundColor,
        other.primaryActionForegroundColor,
        t,
      )!,
      primaryActionShadowColor: Color.lerp(
        primaryActionShadowColor,
        other.primaryActionShadowColor,
        t,
      )!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
    );
  }
}
