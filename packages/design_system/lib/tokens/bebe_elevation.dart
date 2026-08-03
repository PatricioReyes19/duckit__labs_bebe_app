import 'package:flutter/material.dart';

import 'bebe_overlays.dart';

class BebeElevation extends ThemeExtension<BebeElevation> {
  const BebeElevation._(this._values);

  factory BebeElevation.fromJson(
    Map<String, dynamic> json, {
    required BebeOverlays overlays,
  }) {
    final values = <String, List<BoxShadow>>{};

    for (final entry in json.entries) {
      final rawValue = entry.value;

      if (rawValue is List<dynamic>) {
        values[entry.key] = rawValue
            .whereType<Map<String, dynamic>>()
            .map((shadowJson) => _parseShadow(shadowJson, overlays: overlays))
            .toList(growable: false);
      } else if (rawValue is Map<String, dynamic>) {
        values[entry.key] = [_parseShadow(rawValue, overlays: overlays)];
      }
    }

    return BebeElevation._(Map.unmodifiable(values));
  }

  factory BebeElevation.fallback({required BebeOverlays overlays}) {
    return BebeElevation._({
      'elevation-none': const [],
      'elevation-low': [
        BoxShadow(
          color: overlays.shadowSoft,
          offset: const Offset(0, 1),
          blurRadius: 4,
        ),
      ],
      'elevation-medium': [
        BoxShadow(
          color: overlays.shadowDefault,
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: -2,
        ),
      ],
      'elevation-high': [
        BoxShadow(
          color: overlays.shadowStrong,
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: -4,
        ),
      ],
      'elevation-floating': [
        BoxShadow(
          color: overlays.shadowStrong,
          offset: const Offset(0, 10),
          blurRadius: 28,
          spreadRadius: -6,
        ),
      ],
    });
  }

  final Map<String, List<BoxShadow>> _values;

  List<BoxShadow> get none => _get('elevation-none', const []);

  List<BoxShadow> get low => _get('elevation-low', const []);

  List<BoxShadow> get medium => _get('elevation-medium', const []);

  List<BoxShadow> get high => _get('elevation-high', const []);

  List<BoxShadow> get floating => _get('elevation-floating', const []);

  List<BoxShadow> _get(String key, List<BoxShadow> fallback) {
    assert(_values.containsKey(key), 'BebeElevation token not found: $key');

    return _values[key] ?? fallback;
  }

  static BoxShadow _parseShadow(
    Map<String, dynamic> json, {
    required BebeOverlays overlays,
  }) {
    final offsetValues = json['offset'] as List<dynamic>? ?? const [0, 0];

    final colorRef = json['colorRef'] as String?;

    final baseColor = switch (colorRef) {
      'overlay-shadow-soft' => overlays.shadowSoft,
      'overlay-shadow-default' => overlays.shadowDefault,
      'overlay-shadow-strong' => overlays.shadowStrong,
      _ => Colors.black,
    };

    final opacityValue = _parseOpacity(json['opacity']);

    return BoxShadow(
      color: baseColor.withValues(alpha: opacityValue ?? baseColor.a),
      offset: Offset(
        (offsetValues[0] as num).toDouble(),
        (offsetValues[1] as num).toDouble(),
      ),
      blurRadius: (json['blurRadius'] as num?)?.toDouble() ?? 0,
      spreadRadius: (json['spreadRadius'] as num?)?.toDouble() ?? 0,
    );
  }

  static double? _parseOpacity(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble().clamp(0, 1);
    }

    if (value is String) {
      final normalized = value.trim();

      if (normalized.endsWith('%')) {
        final percentage = double.parse(normalized.replaceAll('%', ''));

        return (percentage / 100).clamp(0, 1);
      }

      return double.parse(normalized).clamp(0, 1);
    }

    return null;
  }

  @override
  BebeElevation copyWith({Map<String, List<BoxShadow>>? values}) {
    return BebeElevation._({..._values, ...?values});
  }

  @override
  BebeElevation lerp(covariant ThemeExtension<BebeElevation>? other, double t) {
    if (other is! BebeElevation) {
      return this;
    }

    final keys = {..._values.keys, ...other._values.keys};

    return BebeElevation._({
      for (final key in keys)
        key:
            BoxShadow.lerpList(
              _values[key] ?? const [],
              other._values[key] ?? const [],
              t,
            ) ??
            const [],
    });
  }
}
