import 'dart:ui';

import 'package:flutter/material.dart';

class BebeSpacing extends ThemeExtension<BebeSpacing> {
  const BebeSpacing._(this._values);

  factory BebeSpacing.fromJson(Map<String, dynamic> json) {
    final values = <String, double>{};

    for (final entry in json.entries) {
      final value = entry.value;

      if (value is num) {
        values[entry.key] = value.toDouble();
      }
    }

    return BebeSpacing._(Map.unmodifiable(values));
  }

  factory BebeSpacing.fallback() {
    return const BebeSpacing._({
      'spacing-none': 0,
      'spacing-xs': 2,
      'spacing-s': 4,
      'spacing-m': 8,
      'spacing-l': 12,
      'spacing-xl': 16,
      'spacing-2xl': 20,
      'spacing-3xl': 24,
      'spacing-4xl': 32,
      'spacing-5xl': 40,
      'spacing-6xl': 48,
      'spacing-7xl': 56,
      'spacing-8xl': 64,
    });
  }

  final Map<String, double> _values;

  double get spacingNone => _get('spacing-none', 0);
  double get spacingXs => _get('spacing-xs', 2);
  double get spacingS => _get('spacing-s', 4);
  double get spacingM => _get('spacing-m', 8);
  double get spacingL => _get('spacing-l', 12);
  double get spacingXl => _get('spacing-xl', 16);
  double get spacing2xl => _get('spacing-2xl', 20);
  double get spacing3xl => _get('spacing-3xl', 24);
  double get spacing4xl => _get('spacing-4xl', 32);
  double get spacing5xl => _get('spacing-5xl', 40);
  double get spacing6xl => _get('spacing-6xl', 48);
  double get spacing7xl => _get('spacing-7xl', 56);
  double get spacing8xl => _get('spacing-8xl', 64);

  double _get(String key, double fallback) {
    assert(_values.containsKey(key), 'BebeSpacing token not found: $key');

    return _values[key] ?? fallback;
  }

  @override
  BebeSpacing copyWith({Map<String, double>? values}) {
    return BebeSpacing._({..._values, ...?values});
  }

  @override
  BebeSpacing lerp(covariant ThemeExtension<BebeSpacing>? other, double t) {
    if (other is! BebeSpacing) {
      return this;
    }

    final keys = {..._values.keys, ...other._values.keys};

    return BebeSpacing._({
      for (final key in keys)
        key: lerpDouble(_values[key] ?? 0, other._values[key] ?? 0, t) ?? 0,
    });
  }
}
