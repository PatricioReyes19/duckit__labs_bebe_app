import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Completo',
  type: BebeSettingsOverviewTemplate,
)
Widget bebeSettingsOverviewTemplateCompleteUseCase(
  BuildContext context,
) {
  return const _SettingsFrame(
    child: _CompleteSettingsPreview(),
  );
}

@widgetbook.UseCase(
  name: 'Contenido mínimo',
  type: BebeSettingsOverviewTemplate,
)
Widget bebeSettingsOverviewTemplateMinimumUseCase(
  BuildContext context,
) {
  return const _SettingsFrame(
    child: _MinimumSettingsPreview(),
  );
}

@widgetbook.UseCase(
  name: 'Modo oscuro seleccionado',
  type: BebeSettingsOverviewTemplate,
)
Widget bebeSettingsOverviewTemplateDarkModeUseCase(
  BuildContext context,
) {
  return const _SettingsFrame(
    child: _DarkModeSettingsPreview(),
  );
}

@widgetbook.UseCase(
  name: 'Ancho reducido',
  type: BebeSettingsOverviewTemplate,
)
Widget bebeSettingsOverviewTemplateCompactUseCase(
  BuildContext context,
) {
  return const _SettingsFrame(
    maximumWidth: 390,
    child: _CompleteSettingsPreview(),
  );
}

class _SettingsFrame extends StatelessWidget {
  const _SettingsFrame({
    required this.child,
    this.maximumWidth = 720,
  });

  final Widget child;
  final double maximumWidth;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;

    return ColoredBox(
      color: colors.background.neutralsDefault,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: spacing.spacingL,
          bottom: spacing.spacing3xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maximumWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _CompleteSettingsPreview extends StatelessWidget {
  const _CompleteSettingsPreview();

  @override
  Widget build(BuildContext context) {
    return const BebeSettingsOverviewTemplate(
      accountSection: _AccountSectionPreview(),
      preferencesSection: _PreferencesSectionPreview(),
      notificationsSection: _NotificationsSectionPreview(),
      accessibilitySection: _AccessibilitySectionPreview(),
      privacySection: _PrivacySectionPreview(),
      storageSection: _StorageSectionPreview(),
      supportSection: _SupportSectionPreview(),
      sessionActions: _SessionActionsPreview(),
    );
  }
}

class _MinimumSettingsPreview extends StatelessWidget {
  const _MinimumSettingsPreview();

  @override
  Widget build(BuildContext context) {
    return const BebeSettingsOverviewTemplate(
      accountSection: _AccountSectionPreview(),
      preferencesSection: _PreferencesSectionPreview(),
      privacySection: _PrivacySectionPreview(),
    );
  }
}

class _DarkModeSettingsPreview extends StatelessWidget {
  const _DarkModeSettingsPreview();

  @override
  Widget build(BuildContext context) {
    return const BebeSettingsOverviewTemplate(
      accountSection: _AccountSectionPreview(),
      preferencesSection: _DarkPreferencesSectionPreview(),
      privacySection: _PrivacySectionPreview(),
    );
  }
}

class _AccountSectionPreview extends StatelessWidget {
  const _AccountSectionPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BebeTitleSection(title: 'Mi cuenta'),
        const SizedBox(height: 16),
        BebeAccountSummary(
          name: 'Patricio Reyes',
          email: 'patricio@example.com',
          avatar: const _AvatarPreview(initials: 'PR'),
          status: const _StatusChipPreview(label: 'Correo verificado'),
          onPressed: _emptyCallback,
        ),
      ],
    );
  }
}

class _PreferencesSectionPreview extends StatelessWidget {
  const _PreferencesSectionPreview();

  @override
  Widget build(BuildContext context) {
    return BebeSettingsSection(
      title: 'Preferencias',
      children: [
        BebeSettingsActionTile(
          title: 'Apariencia',
          description: 'Tema, contraste y visualización',
          icon: const Icon(Icons.palette_outlined),
          onPressed: _emptyCallback,
        ),
        BebeSettingsValueTile(
          title: 'Idioma',
          value: 'Español',
          onPressed: _emptyCallback,
        ),
        BebeSettingsValueTile(
          title: 'Formato horario',
          value: '24 horas',
          onPressed: _emptyCallback,
        ),
      ],
    );
  }
}

class _DarkPreferencesSectionPreview extends StatelessWidget {
  const _DarkPreferencesSectionPreview();

  @override
  Widget build(BuildContext context) {
    return BebeSettingsSection(
      title: 'Apariencia',
      children: [
        BebeThemeModeSelector(
          value: BebeThemeModeOption.dark,
          onChanged: _emptyThemeCallback,
          systemLabel: 'Usar configuración del sistema',
          lightLabel: 'Claro',
          darkLabel: 'Oscuro',
          semanticLabel: 'Selector de tema',
        ),
        BebeSettingsSwitchTile(
          title: 'Contraste aumentado',
          description: 'Mejora la separación visual de los elementos',
          value: false,
          onChanged: _emptyBoolCallback,
        ),
      ],
    );
  }
}

class _NotificationsSectionPreview extends StatelessWidget {
  const _NotificationsSectionPreview();

  @override
  Widget build(BuildContext context) {
    return BebeSettingsSection(
      title: 'Notificaciones',
      children: [
        BebeSettingsSwitchTile(
          title: 'Recordatorios personales',
          description: 'Avisos asignados a tu cuenta',
          value: true,
          onChanged: _emptyBoolCallback,
        ),
        BebeSettingsSwitchTile(
          title: 'Actividad del núcleo',
          description: 'Cambios realizados por otros cuidadores',
          value: true,
          onChanged: _emptyBoolCallback,
        ),
        BebeSettingsSwitchTile(
          title: 'Resumen diario',
          value: false,
          onChanged: _emptyBoolCallback,
        ),
      ],
    );
  }
}

class _AccessibilitySectionPreview extends StatelessWidget {
  const _AccessibilitySectionPreview();

  @override
  Widget build(BuildContext context) {
    return BebeSettingsSection(
      title: 'Accesibilidad',
      children: [
        BebeSettingsValueTile(
          title: 'Tamaño del texto',
          value: 'Predeterminado',
          onPressed: _emptyCallback,
        ),
        BebeSettingsSwitchTile(
          title: 'Reducir animaciones',
          value: false,
          onChanged: _emptyBoolCallback,
        ),
      ],
    );
  }
}

class _PrivacySectionPreview extends StatelessWidget {
  const _PrivacySectionPreview();

  @override
  Widget build(BuildContext context) {
    return BebeSettingsSection(
      title: 'Privacidad y seguridad',
      children: [
        BebeSettingsActionTile(
          title: 'Seguridad de la cuenta',
          description: 'Contraseña, biometría y sesiones activas',
          icon: const Icon(Icons.lock_outline_rounded),
          onPressed: _emptyCallback,
        ),
        BebeSettingsActionTile(
          title: 'Privacidad',
          description: 'Consentimientos y uso de datos',
          icon: const Icon(Icons.privacy_tip_outlined),
          onPressed: _emptyCallback,
        ),
        BebeSettingsActionTile(
          title: 'Descargar mis datos',
          icon: const Icon(Icons.download_outlined),
          onPressed: _emptyCallback,
        ),
      ],
    );
  }
}

class _StorageSectionPreview extends StatelessWidget {
  const _StorageSectionPreview();

  @override
  Widget build(BuildContext context) {
    return BebeSettingsSection(
      title: 'Datos y almacenamiento',
      children: [
        BebeSettingsValueTile(
          title: 'Almacenamiento local',
          value: '124 MB',
          onPressed: _emptyCallback,
        ),
        BebeSettingsSwitchTile(
          title: 'Sincronizar solo con Wi-Fi',
          value: false,
          onChanged: _emptyBoolCallback,
        ),
      ],
    );
  }
}

class _SupportSectionPreview extends StatelessWidget {
  const _SupportSectionPreview();

  @override
  Widget build(BuildContext context) {
    return BebeSettingsSection(
      title: 'Ayuda',
      children: [
        BebeSettingsActionTile(
          title: 'Centro de ayuda',
          icon: const Icon(Icons.help_outline_rounded),
          onPressed: _emptyCallback,
        ),
        BebeSettingsActionTile(
          title: 'Reportar un problema',
          icon: const Icon(Icons.bug_report_outlined),
          onPressed: _emptyCallback,
        ),
        BebeSettingsValueTile(
          title: 'Versión',
          value: '1.0.0',
        ),
      ],
    );
  }
}

class _SessionActionsPreview extends StatelessWidget {
  const _SessionActionsPreview();

  @override
  Widget build(BuildContext context) {
    return BebeDetailActionCard(
      title: 'Cerrar sesión',
      description: 'Finaliza la sesión en este dispositivo',
      icon: const Icon(Icons.logout_rounded),
      variant: BebeDetailActionCardVariant.warning,
      onPressed: _emptyCallback,
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.initials,
  });

  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final typography = theme.typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.brandSurface,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.border.brandAlternative,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: typography.styles.title.md.semibold.copyWith(
            color: colors.text.brandDefault,
          ),
        ),
      ),
    );
  }
}

class _StatusChipPreview extends StatelessWidget {
  const _StatusChipPreview({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.background.successSurface,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.spacingS,
          vertical: spacing.spacingXs,
        ),
        child: Text(
          label,
          style: typography.styles.label.sm.semibold.copyWith(
            color: colors.text.successDefault,
          ),
        ),
      ),
    );
  }
}

void _emptyCallback() {}
void _emptyBoolCallback(bool value) {}
void _emptyThemeCallback(BebeThemeModeOption value) {}
