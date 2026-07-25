import 'package:flutter/material.dart';

class BorderColors {
  const BorderColors(this._colors);

  final Map<String, Color> _colors;

  Color get brandDefault => _get('border-brand-default');

  Color get brandFocus => _get('border-brand-focus');

  Color get brandAlternative => _get('border-brand-alternative');

  Color get accentDefault => _get('border-accent-default');

  Color get accentFocus => _get('border-accent-focus');

  Color get accentAlternative => _get('border-accent-alternative');

  Color get neutralDisabled => _get('border-neutral-disabled');

  Color get neutralFocus => _get('border-neutral-focus');

  Color get neutralDefault => _get('border-neutral-default');

  Color get errorDefault => _get('border-error-default');

  Color get warningDefault => _get('border-warning-default');

  Color get infoDefault => _get('border-info-default');

  Color get successDefault => _get('border-success-default');

  Color get basicsWhite => _get('border-basics-white');

  Color _get(String key) {
    return _colors[key] ?? Colors.transparent;
  }
}
