import 'package:flutter/material.dart';

class TextColors {
  const TextColors(this._colors);

  final Map<String, Color> _colors;

  Color get brandDefault => _get('brand-default');

  Color get brandAlternative => _get('brand-alternative');

  Color get brandSubtle => _get('brand-subtle');

  Color get accentDefault => _get('accent-default');

  Color get accentAlternative => _get('accent-alternative');

  Color get accentSubtle => _get('accent-subtle');

  Color get neutralDisplay => _get('neutral-display');

  Color get neutralHeadline => _get('neutral-headline');

  Color get neutralTitle => _get('neutral-title');

  Color get neutralBody => _get('neutral-body');

  Color get neutralLink => _get('neutral-link');

  Color get neutralLabel => _get('neutral-label');

  Color get neutralCaption => _get('neutral-caption');

  Color get neutralDisabled => _get('neutral-disabled');

  Color get neutralSubtle => _get('neutral-subtle');

  Color get warningDefault => _get('warning-default');

  Color get infoDefault => _get('info-default');

  Color get successDefault => _get('success-default');

  Color get errorDefault => _get('error-default');

  Color get white => _get('White');

  Color get black => _get('Black');

  Color _get(String key) {
    return _colors[key] ?? Colors.transparent;
  }
}
