import 'package:flutter/material.dart';

class BackgroundColors {
  const BackgroundColors(this._colors);

  final Map<String, Color> _colors;

  // Brand
  Color get brandSurface => _get('bg-brand-surface');

  Color get brandDefault => _get('bg-brand-default');

  Color get brandPressed => _get('bg-brand-pressed');

  // Accent
  Color get accentSurface => _get('bg-accent-surface');

  Color get accentDefault => _get('bg-accent-default');

  Color get accentPressed => _get('bg-accent-pressed');

  // Neutrals
  Color get neutralsPage => _get('bg-neutral-page');

  Color get neutralsSurface => _get('bg-neutral-surface');

  Color get neutralsDisabled => _get('bg-neutral-disabled');

  Color get neutralsActive => _get('bg-neutral-active');

  Color get neutralsDefault => _get('bg-neutral-default');

  Color get neutralsSkeleton => _get('bg-neutral-skeleton');

  Color get neutralsFeedback => _get('bg-neutral-feedback');

  // Warning
  Color get warningSurface => _get('bg-warning-surface');

  Color get warningDefault => _get('bg-warning-default');

  Color get warningPressed => _get('bg-warning-pressed');

  // Information
  Color get infoSurface => _get('bg-info-surface');

  Color get infoDefault => _get('bg-info-default');

  // Success
  Color get successSurface => _get('bg-success-surface');

  Color get successDefault => _get('bg-success-default');

  // Error
  Color get errorSurface => _get('bg-error-surface');

  Color get errorDefault => _get('bg-error-default');

  Color get errorPressed => _get('bg-error-pressed');

  // Basics
  Color get basicsWhite => _get('bg-basics-white');

  Color get splash => _get('bg-splash');

  Color _get(String key) {
    return _colors[key] ?? Colors.transparent;
  }
}
