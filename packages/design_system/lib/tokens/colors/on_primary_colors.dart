import 'package:flutter/material.dart';

class OnPrimaryColors {
  const OnPrimaryColors(this._colors);

  final Map<String, Color> _colors;

  Color get neutralBody => _get('on-primary-neutral-body');

  Color get neutralDefault => _get('on-primary-neutral-default');

  Color _get(String key) {
    return _colors[key] ?? Colors.transparent;
  }
}
