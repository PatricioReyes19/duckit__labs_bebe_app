import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'typography_styles.dart';

class BebeTypography extends ThemeExtension<BebeTypography> {
  const BebeTypography._({
    required this.fontFamily,
    required Map<String, TextStyle> styles,
  }) : _styles = styles;

  factory BebeTypography.fromJson(Map<String, dynamic> json) {
    final fontFamily = json['fontFamily'] as String? ?? 'PlusJakartaSans';

    final styles = <String, TextStyle>{};

    final categories = json['styles'] as Map<String, dynamic>? ?? const {};

    for (final categoryEntry in categories.entries) {
      final category = _normalizeKey(categoryEntry.key);

      final categoryValue = categoryEntry.value;

      if (categoryValue is! Map<String, dynamic>) {
        continue;
      }

      for (final sizeEntry in categoryValue.entries) {
        final size = _normalizeKey(sizeEntry.key);

        final sizeValue = sizeEntry.value;

        if (sizeValue is! Map<String, dynamic>) {
          continue;
        }

        for (final weightEntry in sizeValue.entries) {
          final weight = _normalizeKey(weightEntry.key);

          final styleValue = weightEntry.value;

          if (styleValue is! Map<String, dynamic>) {
            continue;
          }

          final key = '$category-$size-$weight';

          styles[key] = _parseTextStyle(
            styleValue,
            fallbackFontFamily: fontFamily,
          );
        }
      }
    }

    return BebeTypography._(
      fontFamily: fontFamily,
      styles: Map.unmodifiable(styles),
    );
  }

  factory BebeTypography.empty() {
    return const BebeTypography._(fontFamily: 'PlusJakartaSans', styles: {});
  }

  final String fontFamily;
  final Map<String, TextStyle> _styles;

  BebeTypographyStyles get styles => BebeTypographyStyles(this);

  Map<String, TextStyle> get rawStyles => Map.unmodifiable(_styles);

  TextStyle? getStyleFromKey(String key) {
    return _styles[_normalizeKey(key)];
  }

  TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: styles.display.lg.regular,
      displayMedium: styles.display.md.regular,
      displaySmall: styles.display.sm.regular,

      headlineLarge: styles.headline.lg.bold,
      headlineMedium: styles.headline.md.bold,
      headlineSmall: styles.headline.sm.bold,

      titleLarge: styles.title.lg.semibold,
      titleMedium: styles.title.md.semibold,
      titleSmall: styles.title.sm.semibold,

      bodyLarge: styles.body.lg.regular,
      bodyMedium: styles.body.md.regular,
      bodySmall: styles.body.sm.regular,

      labelLarge: styles.label.lg.semibold,
      labelMedium: styles.label.md.regular,
      labelSmall: styles.label.sm.regular,
    );
  }

  TextStyle requireStyle(String key) {
    final normalizedKey = _normalizeKey(key);
    final style = _styles[normalizedKey];

    if (style != null) {
      return style;
    }

    throw FlutterError.fromParts([
      ErrorSummary(
        'BebeTypography token not found: '
        '$normalizedKey',
      ),
      ErrorDescription(
        'El token solicitado no está disponible '
        'en el tema activo de BebéApp.',
      ),
      DiagnosticsProperty<Iterable<String>>(
        'Available typography tokens',
        _styles.keys,
      ),
    ]);
  }

  static String _normalizeKey(String value) {
    return value.trim().toLowerCase().replaceAll('_', '-').replaceAll(' ', '-');
  }

  static TextStyle _parseTextStyle(
    Map<String, dynamic> json, {
    required String fallbackFontFamily,
  }) {
    final fontSize = _parsePixels(json['size']);

    final lineHeight = _parsePixels(json['lineHeight']);

    return TextStyle(
      fontFamily: json['fontFamily'] as String? ?? fallbackFontFamily,
      fontSize: fontSize,
      height: fontSize != null && lineHeight != null && fontSize > 0
          ? lineHeight / fontSize
          : null,
      fontWeight: _parseWeight(json['fontWeight']),
      fontStyle: _parseFontStyle(json['fontStyle']),
      letterSpacing: _parseLetterSpacing(
        json['letterSpacing'],
        fontSize: fontSize,
      ),
      decoration: _parseDecoration(json['decoration']),
    );
  }

  static double? _parsePixels(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final normalized = value.trim().toLowerCase().replaceAll('px', '');

      return double.tryParse(normalized);
    }

    return null;
  }

  static double? _parseLetterSpacing(
    dynamic value, {
    required double? fontSize,
  }) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is! String) {
      return null;
    }

    final normalized = value.trim().toLowerCase();

    if (normalized.endsWith('%')) {
      final percentage = double.tryParse(normalized.replaceAll('%', ''));

      if (percentage == null || fontSize == null) {
        return null;
      }

      return fontSize * percentage / 100;
    }

    return double.tryParse(normalized.replaceAll('px', ''));
  }

  static FontWeight _parseWeight(dynamic value) {
    final numericWeight = switch (value) {
      num number => number.toInt(),
      String text => int.tryParse(text.trim()) ?? 400,
      _ => 400,
    };

    return switch (numericWeight) {
      <= 100 => FontWeight.w100,
      <= 200 => FontWeight.w200,
      <= 300 => FontWeight.w300,
      <= 400 => FontWeight.w400,
      <= 500 => FontWeight.w500,
      <= 600 => FontWeight.w600,
      <= 700 => FontWeight.w700,
      <= 800 => FontWeight.w800,
      _ => FontWeight.w900,
    };
  }

  static FontStyle _parseFontStyle(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase();

    return normalized == 'italic' ? FontStyle.italic : FontStyle.normal;
  }

  static TextDecoration _parseDecoration(dynamic value) {
    final normalized = value
        ?.toString()
        .trim()
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll('_', '')
        .replaceAll(' ', '');

    return switch (normalized) {
      'underline' => TextDecoration.underline,
      'strikethrough' || 'linethrough' => TextDecoration.lineThrough,
      'overline' => TextDecoration.overline,
      _ => TextDecoration.none,
    };
  }

  @override
  BebeTypography copyWith({
    String? fontFamily,
    Map<String, TextStyle>? styles,
  }) {
    return BebeTypography._(
      fontFamily: fontFamily ?? this.fontFamily,
      styles: styles ?? _styles,
    );
  }

  @override
  BebeTypography lerp(
    covariant ThemeExtension<BebeTypography>? other,
    double t,
  ) {
    if (other is! BebeTypography) {
      return this;
    }

    final keys = {..._styles.keys, ...other._styles.keys};

    return BebeTypography._(
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      styles: {
        for (final key in keys)
          key:
              TextStyle.lerp(_styles[key], other._styles[key], t) ??
              const TextStyle(),
      },
    );
  }
}
