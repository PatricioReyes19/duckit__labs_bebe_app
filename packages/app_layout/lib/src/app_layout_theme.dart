import 'package:flutter/material.dart';

@immutable
class AppLayoutTheme extends ThemeExtension<AppLayoutTheme> {
  const AppLayoutTheme({
    required this.backgroundColor,
    required this.surfaceColor,
    required this.selectedColor,
    required this.unselectedColor,
    required this.primaryActionColor,
    required this.primaryActionForegroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.errorColor,
  });

  factory AppLayoutTheme.fromColorScheme(ColorScheme scheme) {
    return AppLayoutTheme(
      backgroundColor: scheme.surface,
      surfaceColor: scheme.surface,
      selectedColor: scheme.primary,
      unselectedColor: scheme.onSurfaceVariant,
      primaryActionColor: scheme.primary,
      primaryActionForegroundColor: scheme.onPrimary,
      borderColor: scheme.outlineVariant,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      errorColor: scheme.error,
    );
  }

  final Color backgroundColor;
  final Color surfaceColor;
  final Color selectedColor;
  final Color unselectedColor;
  final Color primaryActionColor;
  final Color primaryActionForegroundColor;
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
    Color? unselectedColor,
    Color? primaryActionColor,
    Color? primaryActionForegroundColor,
    Color? borderColor,
    Color? shadowColor,
    Color? errorColor,
  }) {
    return AppLayoutTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      primaryActionColor: primaryActionColor ?? this.primaryActionColor,
      primaryActionForegroundColor:
          primaryActionForegroundColor ?? this.primaryActionForegroundColor,
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
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
    );
  }
}
