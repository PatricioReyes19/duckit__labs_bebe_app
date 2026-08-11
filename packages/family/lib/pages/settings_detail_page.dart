import 'package:design_system/design_system.dart';
import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum SettingsSectionKind {
  account,
  appearance,
  language,
  timeFormat,
  textSize,
  security,
  privacy,
  downloadData,
  storage,
  helpCenter,
  reportProblem,
}

extension SettingsSectionKindPresentation on SettingsSectionKind {
  String get routeValue => switch (this) {
    SettingsSectionKind.account => 'account',
    SettingsSectionKind.appearance => 'appearance',
    SettingsSectionKind.language => 'language',
    SettingsSectionKind.timeFormat => 'time-format',
    SettingsSectionKind.textSize => 'text-size',
    SettingsSectionKind.security => 'security',
    SettingsSectionKind.privacy => 'privacy',
    SettingsSectionKind.downloadData => 'download-data',
    SettingsSectionKind.storage => 'storage',
    SettingsSectionKind.helpCenter => 'help',
    SettingsSectionKind.reportProblem => 'report-problem',
  };

  String get title => switch (this) {
    SettingsSectionKind.account => 'Mi cuenta',
    SettingsSectionKind.appearance => 'Apariencia',
    SettingsSectionKind.language => 'Idioma',
    SettingsSectionKind.timeFormat => 'Formato horario',
    SettingsSectionKind.textSize => 'Tamaño del texto',
    SettingsSectionKind.security => 'Seguridad',
    SettingsSectionKind.privacy => 'Privacidad',
    SettingsSectionKind.downloadData => 'Descargar mis datos',
    SettingsSectionKind.storage => 'Almacenamiento',
    SettingsSectionKind.helpCenter => 'Centro de ayuda',
    SettingsSectionKind.reportProblem => 'Reportar un problema',
  };

  static SettingsSectionKind? fromRouteValue(String? value) {
    for (final section in SettingsSectionKind.values) {
      if (section.routeValue == value) return section;
    }
    return null;
  }
}

class SettingsDetailPage extends GoRoute {
  SettingsDetailPage({
    required SettingsBlocFactory settingsBloc,
    required SettingsThemeAction changeTheme,
  }) : super(
         path: ':section',
         redirect: (context, state) {
           final section = SettingsSectionKindPresentation.fromRouteValue(
             state.pathParameters['section'],
           );
           return section == null ? '/family/settings' : null;
         },
         pageBuilder: (context, state) {
           final section = SettingsSectionKindPresentation.fromRouteValue(
             state.pathParameters['section'],
           )!;
           return MaterialPage<void>(
             key: ValueKey('settings-${section.routeValue}'),
             name: 'Settings${section.name}',
             child: BlocProvider(
               create: (providerContext) =>
                   settingsBloc(providerContext)
                     ..add(const SettingsEvent.started()),
               child: _SettingsDetailView(
                 section: section,
                 onThemeChanged: (value) => changeTheme(context, value),
               ),
             ),
           );
         },
       );

  static String locationFor(SettingsSectionKind section) =>
      '/family/settings/${section.routeValue}';
}

class _SettingsDetailView extends StatelessWidget {
  const _SettingsDetailView({
    required this.section,
    required this.onThemeChanged,
  });

  final SettingsSectionKind section;
  final ValueChanged<BebeThemeModeOption> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage != null) {
          return _DetailPage(
            description: state.errorMessage!,
            children: const [
              Icon(Icons.settings_backup_restore_outlined, size: 56),
            ],
          );
        }
        return switch (section) {
          SettingsSectionKind.account => _AccountEditor(state: state),
          SettingsSectionKind.appearance => _AppearanceEditor(
            state: state,
            onThemeChanged: onThemeChanged,
          ),
          SettingsSectionKind.language => _ChoiceEditor(
            description: 'Elige el idioma de menús y mensajes de la app.',
            title: 'Idioma de la aplicación',
            value: state.language,
            options: const ['Español', 'English'],
            onChanged: (value) => context.read<SettingsBloc>().add(
              SettingsLanguageChanged(value),
            ),
          ),
          SettingsSectionKind.timeFormat => _ChoiceEditor(
            description:
                'Define cómo se muestran horas, registros y recordatorios.',
            title: 'Formato de hora',
            value: state.timeFormat,
            options: const ['24 horas', '12 horas'],
            onChanged: (value) => context.read<SettingsBloc>().add(
              SettingsTimeFormatChanged(value),
            ),
          ),
          SettingsSectionKind.textSize => _ChoiceEditor(
            description: 'Ajusta la lectura sin perder contenido ni controles.',
            title: 'Tamaño de texto',
            value: state.textSize,
            options: const ['Pequeño', 'Predeterminado', 'Grande'],
            onChanged: (value) => context.read<SettingsBloc>().add(
              SettingsTextSizeChanged(value),
            ),
          ),
          SettingsSectionKind.security => const _SecurityEditor(),
          SettingsSectionKind.privacy => const _PrivacyEditor(),
          SettingsSectionKind.downloadData => const _DownloadDataView(),
          SettingsSectionKind.storage => _StorageEditor(state: state),
          SettingsSectionKind.helpCenter => const _HelpCenterView(),
          SettingsSectionKind.reportProblem => const _ProblemReportView(),
        };
      },
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.description, required this.children});

  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ColoredBox(
      color: theme.colors.background.neutralsPage,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          theme.spacing.spacingL,
          theme.spacing.spacingL,
          theme.spacing.spacingL,
          theme.spacing.spacing5xl,
        ),
        child: BebeResponsiveContent(
          maxWidth: BebeLayout.formContentMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                description,
                style: theme.typography.styles.body.md.regular.copyWith(
                  color: theme.colors.text.neutralBody,
                ),
              ),
              SizedBox(height: theme.spacing.spacingXl),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountEditor extends StatefulWidget {
  const _AccountEditor({required this.state});

  final SettingsState state;

  @override
  State<_AccountEditor> createState() => _AccountEditorState();
}

class _AccountEditorState extends State<_AccountEditor> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.name);
  }

  @override
  void didUpdateWidget(covariant _AccountEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.name != widget.state.name &&
        _nameController.text != widget.state.name) {
      _nameController.text = widget.state.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return _DetailPage(
      description:
          'Administra tu identidad personal. Estos datos no cambian los perfiles de los bebés.',
      children: [
        Align(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: theme.colors.background.brandSurface,
                child: Text(
                  _initials(widget.state.name),
                  style: theme.typography.styles.title.lg.bold.copyWith(
                    color: theme.colors.text.brandDefault,
                  ),
                ),
              ),
              Material(
                color: theme.colors.background.brandDefault,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Cambiar foto',
                  onPressed: () =>
                      _message(context, 'Selector de fotografía preparado.'),
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: theme.colors.onPrimary.neutralDefault,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: theme.spacing.spacingXl),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nombre visible',
            prefixIcon: Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: theme.spacing.spacingL),
        TextFormField(
          initialValue: widget.state.email,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Correo de acceso',
            prefixIcon: Icon(Icons.verified_user_outlined),
            suffixText: 'Verificado',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: theme.spacing.spacingS),
        Text(
          'Para cambiar el correo te enviaremos una verificación a ambas direcciones.',
          style: theme.typography.styles.body.sm.regular.copyWith(
            color: theme.colors.text.neutralBody,
          ),
        ),
        SizedBox(height: theme.spacing.spacingXl),
        BebeButton(
          label: 'Guardar datos personales',
          leading: const Icon(Icons.check_rounded),
          onPressed: _save,
        ),
      ],
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      _message(context, 'Escribe un nombre válido.');
      return;
    }
    context.read<SettingsBloc>().add(SettingsAccountNameChanged(name));
    _message(context, 'Datos personales guardados.');
  }
}

class _AppearanceEditor extends StatelessWidget {
  const _AppearanceEditor({required this.state, required this.onThemeChanged});

  final SettingsState state;
  final ValueChanged<BebeThemeModeOption> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final isDark =
        state.themeMode == BebeThemeModeOption.dark ||
        (state.themeMode == BebeThemeModeOption.system &&
            Theme.of(context).brightness == Brightness.dark);
    return _DetailPage(
      description:
          'Una interfaz clara durante el día y más suave cuando el bebé duerme.',
      children: [
        BebeSettingsSection(
          title: 'Tema',
          children: [
            BabyDayNightThemeSwitch(
              isDark: isDark,
              onChanged: (value) => _change(
                bloc,
                value ? BebeThemeModeOption.dark : BebeThemeModeOption.light,
              ),
            ),
          ],
        ),
        SizedBox(height: context.theme.spacing.spacingXl),
        BebeSettingsSection(
          title: 'Legibilidad',
          children: [
            BebeSettingsSwitchTile(
              title: 'Contraste aumentado',
              description: 'Refuerza bordes, textos y estados seleccionados.',
              value: state.highContrast,
              onChanged: (value) =>
                  bloc.add(SettingsEvent.highContrastChanged(value)),
            ),
            BebeSettingsSwitchTile(
              title: 'Reducir animaciones',
              description: 'Suaviza transiciones y movimientos decorativos.',
              value: state.reduceMotion,
              onChanged: (value) =>
                  bloc.add(SettingsEvent.reduceMotionChanged(value)),
            ),
          ],
        ),
      ],
    );
  }

  void _change(SettingsBloc bloc, BebeThemeModeOption value) {
    bloc.add(SettingsEvent.themeChanged(value));
    onThemeChanged(value);
  }
}

class _ChoiceEditor extends StatelessWidget {
  const _ChoiceEditor({
    required this.description,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String description;
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => _DetailPage(
    description: description,
    children: [
      BebeSettingsSection(
        title: title,
        children: [
          RadioGroup<String>(
            groupValue: options.contains(value) ? value : options.first,
            onChanged: (next) {
              if (next != null) {
                onChanged(next);
                _message(context, 'Preferencia guardada.');
              }
            },
            child: Column(
              children: [
                for (final option in options)
                  RadioListTile<String>(value: option, title: Text(option)),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

class _SecurityEditor extends StatefulWidget {
  const _SecurityEditor();

  @override
  State<_SecurityEditor> createState() => _SecurityEditorState();
}

class _SecurityEditorState extends State<_SecurityEditor> {
  bool _biometrics = true;

  @override
  Widget build(BuildContext context) => _DetailPage(
    description:
        'Protege el acceso a información familiar y revisa los dispositivos conectados.',
    children: [
      BebeSettingsSection(
        title: 'Acceso',
        children: [
          BebeSettingsActionTile(
            title: 'Cambiar contraseña',
            description: 'Último cambio hace 3 meses',
            icon: const Icon(Icons.password_rounded),
            onPressed: () => _message(
              context,
              'Te enviaremos un enlace seguro a tu correo.',
            ),
          ),
          BebeSettingsSwitchTile(
            title: 'Desbloqueo biométrico',
            description: 'Usa Face ID o la huella de este dispositivo.',
            value: _biometrics,
            onChanged: (value) => setState(() => _biometrics = value),
          ),
          BebeSettingsActionTile(
            title: 'Sesiones activas',
            description: '2 dispositivos',
            icon: const Icon(Icons.devices_rounded),
            onPressed: () => _message(context, 'Este iPhone · Activo ahora'),
          ),
        ],
      ),
    ],
  );
}

class _PrivacyEditor extends StatefulWidget {
  const _PrivacyEditor();

  @override
  State<_PrivacyEditor> createState() => _PrivacyEditorState();
}

class _PrivacyEditorState extends State<_PrivacyEditor> {
  bool _analytics = false;
  bool _clinical = true;

  @override
  Widget build(BuildContext context) => _DetailPage(
    description:
        'Controla tus consentimientos personales. Los permisos familiares se administran por separado.',
    children: [
      BebeSettingsSection(
        title: 'Consentimientos',
        children: [
          BebeSettingsSwitchTile(
            title: 'Compartir datos de diagnóstico',
            description: 'Ayuda a mejorar estabilidad sin incluir registros.',
            value: _analytics,
            onChanged: (value) => setState(() => _analytics = value),
          ),
          BebeSettingsSwitchTile(
            title: 'Alertas sobre información clínica',
            description: 'Avisa cuando otro cuidador consulta Salud.',
            value: _clinical,
            onChanged: (value) => setState(() => _clinical = value),
          ),
          BebeSettingsActionTile(
            title: 'Política de privacidad',
            icon: const Icon(Icons.policy_outlined),
            onPressed: () =>
                _message(context, 'Política disponible sin conexión.'),
          ),
        ],
      ),
    ],
  );
}

class _DownloadDataView extends StatelessWidget {
  const _DownloadDataView();

  @override
  Widget build(BuildContext context) => _DetailPage(
    description:
        'Prepara una copia portable de tu cuenta, bebés, registros y actividad familiar.',
    children: [
      const BebeInfoBanner(
        title: 'Archivo protegido',
        description:
            'Generaremos un ZIP cifrado y te avisaremos cuando esté disponible.',
        icon: Icon(Icons.lock_outline_rounded),
        variant: BebeInfoBannerVariant.information,
      ),
      SizedBox(height: context.theme.spacing.spacingXl),
      BebeSettingsSection(
        title: 'Incluye',
        children: const [
          BebeSettingsActionTile(
            title: 'Perfiles y registros',
            icon: Icon(Icons.folder_copy_outlined),
          ),
          BebeSettingsActionTile(
            title: 'Salud y agenda',
            icon: Icon(Icons.health_and_safety_outlined),
          ),
          BebeSettingsActionTile(
            title: 'Historial de accesos',
            icon: Icon(Icons.manage_history_rounded),
          ),
        ],
      ),
      SizedBox(height: context.theme.spacing.spacingXl),
      BebeButton(
        label: 'Solicitar mi archivo',
        leading: const Icon(Icons.download_rounded),
        onPressed: () => _message(
          context,
          'Solicitud creada. Te avisaremos cuando esté lista.',
        ),
      ),
    ],
  );
}

class _StorageEditor extends StatelessWidget {
  const _StorageEditor({required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context) => _DetailPage(
    description:
        'Gestiona la información disponible sin conexión y el uso de datos móviles.',
    children: [
      BebeSettingsSection(
        title: 'Uso local',
        children: [
          const BebeSettingsValueTile(
            title: 'Registros y caché',
            value: '18,4 MB',
          ),
          BebeSettingsSwitchTile(
            title: 'Sincronizar solo con Wi-Fi',
            value: state.wifiOnly,
            onChanged: (value) => context.read<SettingsBloc>().add(
              SettingsEvent.wifiOnlyChanged(value),
            ),
          ),
          BebeSettingsActionTile(
            title: 'Limpiar archivos temporales',
            description: 'No elimina registros ni fotografías guardadas.',
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: () =>
                _message(context, 'Archivos temporales eliminados.'),
          ),
        ],
      ),
    ],
  );
}

class _HelpCenterView extends StatelessWidget {
  const _HelpCenterView();

  @override
  Widget build(BuildContext context) => _DetailPage(
    description: 'Respuestas rápidas para las tareas más frecuentes.',
    children: [
      BebeSettingsSection(
        title: 'Temas',
        children: const [
          ExpansionTile(
            title: Text('Primeros pasos'),
            children: [
              ListTile(
                title: Text('Crear un perfil y hacer el primer registro.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Familia y permisos'),
            children: [
              ListTile(title: Text('Invitar, editar o revocar a un cuidador.')),
            ],
          ),
          ExpansionTile(
            title: Text('Privacidad y sincronización'),
            children: [
              ListTile(
                title: Text('Cómo protegemos y sincronizamos tus datos.'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _ProblemReportView extends StatefulWidget {
  const _ProblemReportView();

  @override
  State<_ProblemReportView> createState() => _ProblemReportViewState();
}

class _ProblemReportViewState extends State<_ProblemReportView> {
  final _controller = TextEditingController();
  bool _includeDiagnostics = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DetailPage(
    description:
        'Cuéntanos qué ocurrió. Nunca adjuntamos información clínica sin tu permiso.',
    children: [
      TextField(
        controller: _controller,
        minLines: 5,
        maxLines: 8,
        decoration: const InputDecoration(
          labelText: 'Describe el problema',
          hintText: 'Qué intentabas hacer y qué ocurrió…',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(height: context.theme.spacing.spacingL),
      BebeSettingsSection(
        title: 'Información técnica',
        children: [
          BebeSettingsSwitchTile(
            title: 'Adjuntar diagnóstico',
            description: 'Incluye versión, dispositivo y errores técnicos.',
            value: _includeDiagnostics,
            onChanged: (value) => setState(() => _includeDiagnostics = value),
          ),
        ],
      ),
      SizedBox(height: context.theme.spacing.spacingXl),
      BebeButton(
        label: 'Enviar reporte',
        leading: const Icon(Icons.send_rounded),
        onPressed: _send,
      ),
    ],
  );

  void _send() {
    if (_controller.text.trim().length < 10) {
      _message(context, 'Agrega un poco más de detalle para poder ayudarte.');
      return;
    }
    _controller.clear();
    _message(context, 'Reporte enviado. Gracias por ayudarnos a mejorar.');
  }
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2);
  final result = parts.map((part) => part[0].toUpperCase()).join();
  return result.isEmpty ? 'CU' : result;
}

void _message(BuildContext context, String value) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(value)));
}
