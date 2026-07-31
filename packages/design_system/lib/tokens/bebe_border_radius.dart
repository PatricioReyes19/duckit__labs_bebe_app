import 'dart:ui';

import 'package:flutter/material.dart';

class BebeBorderRadius extends ThemeExtension<BebeBorderRadius> {
  const BebeBorderRadius._(this._values);

  factory BebeBorderRadius.fromJson(Map<String, dynamic> json) {
    final values = <String, double>{};

    for (final entry in json.entries) {
      final value = entry.value;

      if (value is num) {
        values[entry.key] = value.toDouble();
      } else if (value is String) {
        values[entry.key] = _parseRadius(value);
      }
    }

    return BebeBorderRadius._(Map.unmodifiable(values));
  }

  factory BebeBorderRadius.fallback() {
    return const BebeBorderRadius._({
      'radius-none': 0,
      'radius-xs': 2,
      'radius-s': 4,
      'radius-m': 8,
      'radius-l': 12,
      'radius-xl': 16,
      'radius-2xl': 20,
      'radius-3xl': 24,
      'radius-4xl': 32,
      'radius-full': 9999,
    });
  }

  final Map<String, double> _values;

  double get radiusNone => _get('radius-none', 0);
  double get radiusXs => _get('radius-xs', 2);
  double get radiusS => _get('radius-s', 4);
  double get radiusM => _get('radius-m', 8);
  double get radiusL => _get('radius-l', 12);
  double get radiusXl => _get('radius-xl', 16);
  double get radius2xl => _get('radius-2xl', 20);
  double get radius3xl => _get('radius-3xl', 24);
  double get radius4xl => _get('radius-4xl', 32);
  double get radiusFull => _get('radius-full', 9999);

  BorderRadius get none => BorderRadius.circular(radiusNone);
  BorderRadius get xs => BorderRadius.circular(radiusXs);
  BorderRadius get s => BorderRadius.circular(radiusS);
  BorderRadius get m => BorderRadius.circular(radiusM);
  BorderRadius get l => BorderRadius.circular(radiusL);
  BorderRadius get xl => BorderRadius.circular(radiusXl);
  BorderRadius get x2l => BorderRadius.circular(radius2xl);
  BorderRadius get x3l => BorderRadius.circular(radius3xl);
  BorderRadius get x4l => BorderRadius.circular(radius4xl);
  BorderRadius get full => BorderRadius.circular(radiusFull);

  static double _parseRadius(String value) {
    return double.parse(value.trim().replaceAll('px', ''));
  }

  double _get(String key, double fallback) {
    assert(_values.containsKey(key), 'BebeBorderRadius token not found: $key');

    return _values[key] ?? fallback;
  }

  @override
  BebeBorderRadius copyWith({Map<String, double>? values}) {
    return BebeBorderRadius._({..._values, ...?values});
  }

  @override
  BebeBorderRadius lerp(
    covariant ThemeExtension<BebeBorderRadius>? other,
    double t,
  ) {
    if (other is! BebeBorderRadius) {
      return this;
    }

    final keys = {..._values.keys, ...other._values.keys};

    return BebeBorderRadius._({
      for (final key in keys)
        key: lerpDouble(_values[key] ?? 0, other._values[key] ?? 0, t) ?? 0,
    });
  }
}
