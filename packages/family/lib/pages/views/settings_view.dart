import 'package:design_system/design_system.dart';
import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    this.onAccountPressed,
    this.onAppearancePressed,
    this.onLanguagePressed,
    this.onTimeFormatPressed,
    this.onTextSizePressed,
    this.onSecurityPressed,
    this.onPrivacyPressed,
    this.onDownloadDataPressed,
    this.onStoragePressed,
    this.onHelpCenterPressed,
    this.onReportProblemPressed,
    this.onSignOutPressed,
    this.onThemeChanged,
    super.key,
  });

  final VoidCallback? onAccountPressed;
  final VoidCallback? onAppearancePressed;
  final VoidCallback? onLanguagePressed;
  final VoidCallback? onTimeFormatPressed;
  final VoidCallback? onTextSizePressed;
  final VoidCallback? onSecurityPressed;
  final VoidCallback? onPrivacyPressed;
  final VoidCallback? onDownloadDataPressed;
  final VoidCallback? onStoragePressed;
  final VoidCallback? onHelpCenterPressed;
  final VoidCallback? onReportProblemPressed;
  final VoidCallback? onSignOutPressed;
  final ValueChanged<BebeThemeModeOption>? onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const _SettingsLoading();
        }

        if (state.errorMessage != null) {
          return _SettingsError(message: state.errorMessage!);
        }

        return _SettingsContent(
          state: state,
          onAccountPressed: onAccountPressed,
          onAppearancePressed: onAppearancePressed,
          onLanguagePressed: onLanguagePressed,
          onTimeFormatPressed: onTimeFormatPressed,
          onTextSizePressed: onTextSizePressed,
          onSecurityPressed: onSecurityPressed,
          onPrivacyPressed: onPrivacyPressed,
          onDownloadDataPressed: onDownloadDataPressed,
          onStoragePressed: onStoragePressed,
          onHelpCenterPressed: onHelpCenterPressed,
          onReportProblemPressed: onReportProblemPressed,
          onSignOutPressed: onSignOutPressed,
          onThemeChanged: onThemeChanged,
        );
      },
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.state,
    this.onAccountPressed,
    this.onAppearancePressed,
    this.onLanguagePressed,
    this.onTimeFormatPressed,
    this.onTextSizePressed,
    this.onSecurityPressed,
    this.onPrivacyPressed,
    this.onDownloadDataPressed,
    this.onStoragePressed,
    this.onHelpCenterPressed,
    this.onReportProblemPressed,
    this.onSignOutPressed,
    this.onThemeChanged,
  });

  final SettingsState state;
  final VoidCallback? onAccountPressed;
  final VoidCallback? onAppearancePressed;
  final VoidCallback? onLanguagePressed;
  final VoidCallback? onTimeFormatPressed;
  final VoidCallback? onTextSizePressed;
  final VoidCallback? onSecurityPressed;
  final VoidCallback? onPrivacyPressed;
  final VoidCallback? onDownloadDataPressed;
  final VoidCallback? onStoragePressed;
  final VoidCallback? onHelpCenterPressed;
  final VoidCallback? onReportProblemPressed;
  final VoidCallback? onSignOutPressed;
  final ValueChanged<BebeThemeModeOption>? onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final spacing = context.theme.spacing;

    return BebeSettingsOverviewTemplate(
      accountSection: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BebeTitleSection(title: 'Mi cuenta'),
          SizedBox(height: spacing.spacingL),
          BebeAccountSummary(
            name: state.name,
            email: state.email,
            avatar: _SettingsAvatar(initials: _initialsFor(state.name)),
            status: const _VerifiedStatus(label: 'Cuenta protegida'),
            onPressed: onAccountPressed ?? _emptyCallback,
          ),
        ],
      ),
      preferencesSection: BebeSettingsSection(
        title: 'Preferencias',
        children: [
          BebeSettingsActionTile(
            title: 'Apariencia',
            description: 'Tema, contraste y visualización',
            icon: const Icon(Icons.palette_outlined),
            onPressed: onAppearancePressed ?? _emptyCallback,
          ),
          BabyDayNightThemeSwitch(
            isDark:
                state.themeMode == BebeThemeModeOption.dark ||
                (state.themeMode == BebeThemeModeOption.system &&
                    Theme.of(context).brightness == Brightness.dark),
            onChanged: (isDark) => _changeTheme(
              bloc,
              isDark ? BebeThemeModeOption.dark : BebeThemeModeOption.light,
            ),
          ),
          BebeSettingsSwitchTile(
            title: 'Contraste aumentado',
            description: 'Mejora la separación visual de los elementos',
            value: state.highContrast,
            onChanged: (value) =>
                bloc.add(SettingsEvent.highContrastChanged(value)),
          ),
          BebeSettingsValueTile(
            title: 'Idioma',
            value: state.language,
            onPressed: onLanguagePressed ?? _emptyCallback,
          ),
          BebeSettingsValueTile(
            title: 'Formato horario',
            value: state.timeFormat,
            onPressed: onTimeFormatPressed ?? _emptyCallback,
          ),
        ],
      ),
      notificationsSection: BebeSettingsSection(
        title: 'Notificaciones',
        children: [
          BebeSettingsSwitchTile(
            title: 'Recordatorios personales',
            description: 'Avisos asignados a tu cuenta',
            value: state.personalReminders,
            onChanged: (value) =>
                bloc.add(SettingsEvent.personalRemindersChanged(value)),
          ),
          BebeSettingsSwitchTile(
            title: 'Actividad del núcleo',
            description: 'Cambios realizados por otros cuidadores',
            value: state.familyActivity,
            onChanged: (value) =>
                bloc.add(SettingsEvent.familyActivityChanged(value)),
          ),
          BebeSettingsSwitchTile(
            title: 'Resumen diario',
            value: state.dailySummary,
            onChanged: (value) =>
                bloc.add(SettingsEvent.dailySummaryChanged(value)),
          ),
        ],
      ),
      accessibilitySection: BebeSettingsSection(
        title: 'Accesibilidad',
        children: [
          BebeSettingsValueTile(
            title: 'Tamaño del texto',
            value: state.textSize,
            onPressed: onTextSizePressed ?? _emptyCallback,
          ),
          BebeSettingsSwitchTile(
            title: 'Reducir animaciones',
            value: state.reduceMotion,
            onChanged: (value) =>
                bloc.add(SettingsEvent.reduceMotionChanged(value)),
          ),
        ],
      ),
      privacySection: BebeSettingsSection(
        title: 'Privacidad y seguridad',
        children: [
          BebeSettingsActionTile(
            title: 'Seguridad de la cuenta',
            description: 'Contraseña, biometría y sesiones activas',
            icon: const Icon(Icons.lock_outline_rounded),
            onPressed: onSecurityPressed ?? _emptyCallback,
          ),
          BebeSettingsActionTile(
            title: 'Privacidad',
            description: 'Consentimientos y uso de datos',
            icon: const Icon(Icons.privacy_tip_outlined),
            onPressed: onPrivacyPressed ?? _emptyCallback,
          ),
          BebeSettingsActionTile(
            title: 'Descargar mis datos',
            icon: const Icon(Icons.download_outlined),
            onPressed: onDownloadDataPressed ?? _emptyCallback,
          ),
        ],
      ),
      storageSection: BebeSettingsSection(
        title: 'Datos y almacenamiento',
        children: [
          BebeSettingsValueTile(
            title: 'Almacenamiento local',
            value: state.localStorage,
            onPressed: onStoragePressed ?? _emptyCallback,
          ),
          BebeSettingsSwitchTile(
            title: 'Sincronizar solo con Wi-Fi',
            value: state.wifiOnly,
            onChanged: (value) =>
                bloc.add(SettingsEvent.wifiOnlyChanged(value)),
          ),
        ],
      ),
      supportSection: BebeSettingsSection(
        title: 'Ayuda',
        children: [
          BebeSettingsActionTile(
            title: 'Centro de ayuda',
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: onHelpCenterPressed ?? _emptyCallback,
          ),
          BebeSettingsActionTile(
            title: 'Reportar un problema',
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: onReportProblemPressed ?? _emptyCallback,
          ),
          BebeSettingsValueTile(title: 'Versión', value: state.appVersion),
        ],
      ),
      sessionActions: BebeDetailActionCard(
        title: 'Cerrar sesión',
        description: 'Finaliza la sesión en este dispositivo',
        icon: const Icon(Icons.logout_rounded),
        variant: BebeDetailActionCardVariant.warning,
        onPressed: () => _confirmSignOut(context),
      ),
    );
  }

  void _changeTheme(SettingsBloc bloc, BebeThemeModeOption value) {
    bloc.add(SettingsEvent.themeChanged(value));
    onThemeChanged?.call(value);
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded),
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tus registros guardados permanecerán sincronizados. '
          'Necesitarás volver a ingresar para ver la información familiar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      (onSignOutPressed ?? _emptyCallback)();
    }
  }
}

class _SettingsAvatar extends StatelessWidget {
  const _SettingsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Semantics(
      image: true,
      label: 'Avatar $initials',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background.brandSurface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.colors.border.brandAlternative),
        ),
        child: Center(
          child: Text(
            initials,
            style: theme.typography.styles.title.md.semibold.copyWith(
              color: theme.colors.text.brandDefault,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifiedStatus extends StatelessWidget {
  const _VerifiedStatus({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: theme.colors.background.successSurface,
        shape: StadiumBorder(
          side: BorderSide(color: theme.colors.border.successDefault),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.spacingS,
          vertical: theme.spacing.spacingXs,
        ),
        child: Text(
          label,
          style: theme.typography.styles.label.sm.semibold.copyWith(
            color: theme.colors.text.successDefault,
          ),
        ),
      ),
    );
  }
}

class _SettingsLoading extends StatelessWidget {
  const _SettingsLoading();

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return BebeSettingsOverviewTemplate(
      accountSection: const _SettingsSkeleton(height: 112),
      preferencesSection: const _SettingsSkeleton(height: 310),
      notificationsSection: const _SettingsSkeleton(height: 220),
      accessibilitySection: const _SettingsSkeleton(height: 160),
      privacySection: const _SettingsSkeleton(height: 230),
      storageSection: const _SettingsSkeleton(height: 160),
      supportSection: const _SettingsSkeleton(height: 210),
      sessionActions: Padding(
        padding: EdgeInsets.only(top: spacing.spacingM),
        child: const _SettingsSkeleton(height: 96),
      ),
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SizedBox(
      height: 420,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.settings_backup_restore_outlined,
                size: 44,
                color: theme.colors.icons.errorDefault,
              ),
              SizedBox(height: theme.spacing.spacingL),
              Text(
                'No pudimos cargar Configuración',
                textAlign: TextAlign.center,
                style: theme.typography.styles.title.md.semibold.copyWith(
                  color: theme.colors.text.neutralTitle,
                ),
              ),
              SizedBox(height: theme.spacing.spacingS),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.typography.styles.body.md.regular.copyWith(
                  color: theme.colors.text.neutralBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return BebeSkeleton(height: height);
  }
}

void _emptyCallback() {}

String _initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'CU';
  }
  return parts.map((part) => part[0].toUpperCase()).join();
}
