import 'package:design_system/design_system.dart';
import 'package:design_system/themes/theme_data.dart';
import 'package:flutter/material.dart';

extension BebeThemeContext on BuildContext {
  BebeThemeData get theme {
    final materialTheme = Theme.of(this);

    final colors = materialTheme.extension<BebeColor>();

    final spacing = materialTheme.extension<BebeSpacing>();

    final typography = materialTheme.extension<BebeTypography>();

    final borderRadius = materialTheme.extension<BebeBorderRadius>();

    final elevation = materialTheme.extension<BebeElevation>();

    final overlays = materialTheme.extension<BebeOverlays>();

    assert(colors != null, 'BebeColor was not found in ThemeData.extensions.');

    assert(
      spacing != null,
      'BebeSpacing was not found in ThemeData.extensions.',
    );

    assert(
      typography != null,
      'BebeTypography was not found in ThemeData.extensions.',
    );

    assert(
      borderRadius != null,
      'BebeBorderRadius was not found in ThemeData.extensions.',
    );

    assert(
      elevation != null,
      'BebeElevation was not found in ThemeData.extensions.',
    );

    assert(
      overlays != null,
      'BebeOverlays was not found in ThemeData.extensions.',
    );

    return BebeThemeData(
      colors: colors!,
      spacing: spacing!,
      typography: typography!,
      borderRadius: borderRadius!,
      elevation: elevation!,
      overlays: overlays!,
    );
  }
}
