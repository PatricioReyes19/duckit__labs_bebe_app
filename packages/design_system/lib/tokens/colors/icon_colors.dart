import 'package:flutter/material.dart';

class IconColors {
  const IconColors(this._colors);

  final Map<String, Color> _colors;

  Color get brandDefault => _get('icon-brand-default');

  Color get brandSubtle => _get('icon-brand-subtle');

  Color get accentDefault => _get('icon-accent-default');

  Color get accentSubtle => _get('icon-accent-subtle');

  Color get neutralDefault => _get('icon-neutral-default');

  Color get neutralDisabled => _get('icon-neutral-disabled');

  Color get neutralAlternative => _get('icon-neutral-alternative');

  Color get neutralSubtle => _get('icon-neutral-subtle');

  Color get errorDefault => _get('icon-error-default');

  Color get warningDefault => _get('icon-warning-default');

  Color get infoDefault => _get('icon-info-default');

  Color get successDefault => _get('icon-success-default');

  Color _get(String key) {
    return _colors[key] ?? Colors.transparent;
  }
}
