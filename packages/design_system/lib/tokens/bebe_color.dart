import 'package:flutter/material.dart';
import 'tokens.dart';

class BebeColor extends ThemeExtension<BebeColor> {
  const BebeColor._({
    required Map<String, Color> textColors,
    required Map<String, Color> backgroundColors,
    required Map<String, Color> iconColors,
    required Map<String, Color> borderColors,
    required Map<String, Color> onPrimaryColors,
  }) : _textColors = textColors,
       _backgroundColors = backgroundColors,
       _iconColors = iconColors,
       _borderColors = borderColors,
       _onPrimaryColors = onPrimaryColors;

  factory BebeColor.fromJson(Map<String, dynamic> json) {
    return BebeColor._(
      textColors: _parseColorGroup(
        json['Text'] as Map<String, dynamic>? ?? const {},
      ),
      backgroundColors: _parseColorGroup(
        json['Background'] as Map<String, dynamic>? ?? const {},
      ),
      iconColors: _parseColorGroup(
        json['icons'] as Map<String, dynamic>? ?? const {},
      ),
      borderColors: _parseColorGroup(
        json['Border'] as Map<String, dynamic>? ?? const {},
      ),
      onPrimaryColors: _parseColorGroup(
        json['OnPrimary'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  factory BebeColor.empty() {
    return const BebeColor._(
      textColors: {},
      backgroundColors: {},
      iconColors: {},
      borderColors: {},
      onPrimaryColors: {},
    );
  }

  final Map<String, Color> _textColors;
  final Map<String, Color> _backgroundColors;
  final Map<String, Color> _iconColors;
  final Map<String, Color> _borderColors;
  final Map<String, Color> _onPrimaryColors;

  TextColors get text => TextColors(_textColors);

  BackgroundColors get background => BackgroundColors(_backgroundColors);

  IconColors get icons => IconColors(_iconColors);

  BorderColors get border => BorderColors(_borderColors);

  OnPrimaryColors get onPrimary => OnPrimaryColors(_onPrimaryColors);

  static Map<String, Color> _parseColorGroup(Map<String, dynamic> json) {
    final colors = <String, Color>{};
    const converter = ColorConverter();

    void parseNode(Map<String, dynamic> node) {
      node.forEach((key, value) {
        if (value is String) {
          colors[key] = converter.fromJson(value);
        } else if (value is Map<String, dynamic>) {
          parseNode(value);
        }
      });
    }

    parseNode(json);

    return Map.unmodifiable(colors);
  }

  Color? findColor(String key) {
    return _textColors[key] ??
        _backgroundColors[key] ??
        _iconColors[key] ??
        _borderColors[key] ??
        _onPrimaryColors[key];
  }

  @override
  BebeColor copyWith({
    Map<String, Color>? textColors,
    Map<String, Color>? backgroundColors,
    Map<String, Color>? iconColors,
    Map<String, Color>? borderColors,
    Map<String, Color>? onPrimaryColors,
  }) {
    return BebeColor._(
      textColors: textColors ?? _textColors,
      backgroundColors: backgroundColors ?? _backgroundColors,
      iconColors: iconColors ?? _iconColors,
      borderColors: borderColors ?? _borderColors,
      onPrimaryColors: onPrimaryColors ?? _onPrimaryColors,
    );
  }

  @override
  BebeColor lerp(covariant ThemeExtension<BebeColor>? other, double t) {
    if (other is! BebeColor) {
      return this;
    }

    return BebeColor._(
      textColors: _lerpColors(_textColors, other._textColors, t),
      backgroundColors: _lerpColors(
        _backgroundColors,
        other._backgroundColors,
        t,
      ),
      iconColors: _lerpColors(_iconColors, other._iconColors, t),
      borderColors: _lerpColors(_borderColors, other._borderColors, t),
      onPrimaryColors: _lerpColors(_onPrimaryColors, other._onPrimaryColors, t),
    );
  }

  static Map<String, Color> _lerpColors(
    Map<String, Color> first,
    Map<String, Color> second,
    double t,
  ) {
    final keys = {...first.keys, ...second.keys};

    return Map.unmodifiable({
      for (final key in keys)
        key:
            Color.lerp(
              first[key] ?? Colors.transparent,
              second[key] ?? Colors.transparent,
              t,
            ) ??
            Colors.transparent,
    });
  }
}
