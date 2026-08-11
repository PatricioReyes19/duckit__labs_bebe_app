import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Switch controlado para alternar entre tema claro y oscuro.
class BabyDayNightThemeSwitch extends StatelessWidget {
  const BabyDayNightThemeSwitch({
    required this.isDark,
    required this.onChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final spacing = theme.spacing;
    final modeLabel = isDark ? 'Oscuro' : 'Claro';

    return Semantics(
      container: true,
      label: 'Tema. $modeLabel',
      child: Padding(
        padding: EdgeInsets.all(spacing.spacingL),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Tema',
                style: theme.typography.styles.label.lg.semibold.copyWith(
                  color: colors.text.neutralTitle,
                ),
              ),
            ),
            Tooltip(
              message: 'Tema claro',
              child: Icon(
                Icons.light_mode_outlined,
                size: 20,
                color: isDark
                    ? colors.icons.neutralAlternative
                    : colors.icons.brandDefault,
              ),
            ),
            SizedBox(width: spacing.spacingS),
            Switch(
              key: const ValueKey('theme-mode-switch'),
              value: isDark,
              onChanged: onChanged,
            ),
            SizedBox(width: spacing.spacingS),
            Tooltip(
              message: 'Tema oscuro',
              child: Icon(
                Icons.dark_mode_outlined,
                size: 20,
                color: isDark
                    ? colors.icons.brandDefault
                    : colors.icons.neutralAlternative,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
