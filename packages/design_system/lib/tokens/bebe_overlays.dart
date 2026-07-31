import 'package:flutter/material.dart';

class BebeOverlays extends ThemeExtension<BebeOverlays> {
  const BebeOverlays._(this._values);

  factory BebeOverlays.fromJson(Map<String, dynamic> json) {
    final values = <String, Color>{};

    void parseNode(Map<String, dynamic> node) {
      for (final entry in node.entries) {
        final value = entry.value;

        if (value is String) {
          values[entry.key] = _parseColor(value);
        } else if (value is Map<String, dynamic>) {
          parseNode(value);
        }
      }
    }

    parseNode(json);

    return BebeOverlays._(Map.unmodifiable(values));
  }

  factory BebeOverlays.fallbackLight() {
    return const BebeOverlays._({
      'overlay-hover': Color(0x0A087F91),
      'overlay-pressed': Color(0x1F087F91),
      'overlay-focus': Color(0x29087F91),
      'overlay-selected': Color(0x14087F91),
      'overlay-scrim-soft': Color(0x33102A43),
      'overlay-scrim-default': Color(0x7A102A43),
      'overlay-scrim-strong': Color(0xA3102A43),
      'overlay-shadow-soft': Color(0x14102A43),
      'overlay-shadow-default': Color(0x29102A43),
      'overlay-shadow-strong': Color(0x40102A43),
      'overlay-highlight-soft': Color(0x52FFFFFF),
      'overlay-highlight-default': Color(0x7AFFFFFF),
      'overlay-disabled-surface': Color(0x99FFFFFF),
      'overlay-disabled-content': Color(0x61102A43),
    });
  }

  factory BebeOverlays.fallbackDark() {
    return const BebeOverlays._({
      'overlay-hover': Color(0x147ED2D6),
      'overlay-pressed': Color(0x297ED2D6),
      'overlay-focus': Color(0x3D7ED2D6),
      'overlay-selected': Color(0x1F7ED2D6),
      'overlay-scrim-soft': Color(0x52000000),
      'overlay-scrim-default': Color(0x99000000),
      'overlay-scrim-strong': Color(0xC2000000),
      'overlay-shadow-soft': Color(0x3D000000),
      'overlay-shadow-default': Color(0x66000000),
      'overlay-shadow-strong': Color(0x8F000000),
      'overlay-highlight-soft': Color(0x14FFFFFF),
      'overlay-highlight-default': Color(0x29FFFFFF),
      'overlay-disabled-surface': Color(0x7A0E171C),
      'overlay-disabled-content': Color(0x61E4EBEF),
    });
  }

  final Map<String, Color> _values;

  Color get interactionHover => _get('overlay-hover', Colors.transparent);

  Color get interactionPressed => _get('overlay-pressed', Colors.transparent);

  Color get interactionFocus => _get('overlay-focus', Colors.transparent);

  Color get interactionSelected => _get('overlay-selected', Colors.transparent);

  Color get scrimSoft => _get('overlay-scrim-soft', Colors.black26);

  Color get scrimDefault => _get('overlay-scrim-default', Colors.black54);

  Color get scrimStrong => _get('overlay-scrim-strong', Colors.black87);

  Color get shadowSoft => _get('overlay-shadow-soft', Colors.black12);

  Color get shadowDefault => _get('overlay-shadow-default', Colors.black26);

  Color get shadowStrong => _get('overlay-shadow-strong', Colors.black38);

  Color get highlightSoft => _get('overlay-highlight-soft', Colors.white24);

  Color get highlightDefault =>
      _get('overlay-highlight-default', Colors.white38);

  Color get disabledSurface =>
      _get('overlay-disabled-surface', Colors.transparent);

  Color get disabledContent => _get('overlay-disabled-content', Colors.grey);

  Color _get(String key, Color fallback) {
    assert(_values.containsKey(key), 'BebeOverlays token not found: $key');

    return _values[key] ?? fallback;
  }

  static Color _parseColor(String value) {
    final normalized = value.trim().replaceFirst('#', '');

    if (normalized.length == 6) {
      return Color(int.parse('FF$normalized', radix: 16));
    }

    if (normalized.length == 8) {
      final red = normalized.substring(0, 2);
      final green = normalized.substring(2, 4);
      final blue = normalized.substring(4, 6);
      final alpha = normalized.substring(6, 8);

      return Color(int.parse('$alpha$red$green$blue', radix: 16));
    }

    throw FormatException('Invalid overlay color: $value');
  }

  @override
  BebeOverlays copyWith({Map<String, Color>? values}) {
    return BebeOverlays._({..._values, ...?values});
  }

  @override
  BebeOverlays lerp(covariant ThemeExtension<BebeOverlays>? other, double t) {
    if (other is! BebeOverlays) {
      return this;
    }

    final keys = {..._values.keys, ...other._values.keys};

    return BebeOverlays._({
      for (final key in keys)
        key:
            Color.lerp(
              _values[key] ?? Colors.transparent,
              other._values[key] ?? Colors.transparent,
              t,
            ) ??
            Colors.transparent,
    });
  }
}
