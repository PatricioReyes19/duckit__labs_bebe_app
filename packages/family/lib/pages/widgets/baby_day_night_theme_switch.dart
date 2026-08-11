import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Selector Material controlado para las tres preferencias de tema.
///
/// No mantiene un estado visual paralelo ni espera una animación local: la
/// selección siempre representa el valor persistido por SettingsBloc.
class BabyDayNightThemeSwitch extends StatelessWidget {
  const BabyDayNightThemeSwitch({
    required this.isDark,
    required this.followsSystem,
    required this.onChanged,
    required this.onUseSystem,
    super.key,
  });

  final bool isDark;
  final bool followsSystem;
  final ValueChanged<bool> onChanged;
  final VoidCallback onUseSystem;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final selected = followsSystem
        ? BebeThemeModeOption.system
        : isDark
        ? BebeThemeModeOption.dark
        : BebeThemeModeOption.light;

    return Semantics(
      container: true,
      label: 'Tema visual',
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tema de la aplicación',
              style: theme.typography.styles.title.sm.semibold.copyWith(
                color: theme.colors.text.neutralTitle,
              ),
            ),
            SizedBox(height: theme.spacing.spacingS),
            Text(
              'Elige claro, oscuro o sigue la preferencia del sistema.',
              style: theme.typography.styles.body.sm.regular.copyWith(
                color: theme.colors.text.neutralBody,
              ),
            ),
            SizedBox(height: theme.spacing.spacingL),
            SegmentedButton<BebeThemeModeOption>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: BebeThemeModeOption.system,
                  icon: Icon(Icons.settings_suggest_outlined),
                  label: Text('Sistema'),
                ),
                ButtonSegment(
                  value: BebeThemeModeOption.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Claro'),
                ),
                ButtonSegment(
                  value: BebeThemeModeOption.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Oscuro'),
                ),
              ],
              selected: {selected},
              onSelectionChanged: (values) {
                switch (values.first) {
                  case BebeThemeModeOption.system:
                    onUseSystem();
                    return;
                  case BebeThemeModeOption.light:
                    onChanged(false);
                    return;
                  case BebeThemeModeOption.dark:
                    onChanged(true);
                    return;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
