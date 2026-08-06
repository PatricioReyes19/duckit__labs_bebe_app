import 'package:flutter/painting.dart';

import 'bebe_typography.dart';

class BebeTypographyStyles {
  const BebeTypographyStyles(this._typography);

  final BebeTypography _typography;

  BebeTextStyleCategory get display =>
      BebeTextStyleCategory._(_typography, 'display');

  BebeTextStyleCategory get headline =>
      BebeTextStyleCategory._(_typography, 'headline');

  BebeTextStyleCategory get title =>
      BebeTextStyleCategory._(_typography, 'title');

  BebeTextStyleCategory get body =>
      BebeTextStyleCategory._(_typography, 'body');

  BebeTextStyleCategory get caption =>
      BebeTextStyleCategory._(_typography, 'caption');

  BebeTextStyleCategory get label =>
      BebeTextStyleCategory._(_typography, 'label');

  BebeTextStyleCategory get bodyStrike =>
      BebeTextStyleCategory._(_typography, 'body-strike');

  BebeTextStyleCategory get bodyLink =>
      BebeTextStyleCategory._(_typography, 'body-link');
}

class BebeTextStyleCategory {
  const BebeTextStyleCategory._(this._typography, this._category);

  final BebeTypography _typography;
  final String _category;

  BebeTextStyleSize get lg => BebeTextStyleSize._(_typography, _category, 'lg');

  BebeTextStyleSize get md => BebeTextStyleSize._(_typography, _category, 'md');

  BebeTextStyleSize get sm => BebeTextStyleSize._(_typography, _category, 'sm');
}

class BebeTextStyleSize {
  const BebeTextStyleSize._(this._typography, this._category, this._size);

  final BebeTypography _typography;
  final String _category;
  final String _size;

  TextStyle get regular =>
      _typography.requireStyle('$_category-$_size-regular');

  TextStyle get semibold =>
      _typography.requireStyle('$_category-$_size-semibold');

  TextStyle get bold => _typography.requireStyle('$_category-$_size-bold');
}
