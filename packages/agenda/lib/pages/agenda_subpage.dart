import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AgendaSubpageKind { reminderSettings, createReminder, eventDetail }

typedef AgendaReminderChanged =
    Future<void> Function(BuildContext context, AgendaEventEntity event);
typedef AgendaReminderDeleted =
    Future<void> Function(BuildContext context, String eventId);

extension AgendaSubpageKindPresentation on AgendaSubpageKind {
  String get relativePath => switch (this) {
    AgendaSubpageKind.reminderSettings => 'reminders/settings',
    AgendaSubpageKind.createReminder => 'reminders/new',
    AgendaSubpageKind.eventDetail => 'events/:eventId',
  };

  String get title => switch (this) {
    AgendaSubpageKind.reminderSettings => 'Configurar recordatorios',
    AgendaSubpageKind.createReminder => 'Nuevo recordatorio',
    AgendaSubpageKind.eventDetail => 'Detalle del evento',
  };
}

class AgendaSubpage extends GoRoute {
  AgendaSubpage({
    required AgendaSubpageKind kind,
    required CreateAgendaEvent createAgendaEvent,
    required AgendaRepository agendaRepository,
    required AppSettingsRepository appSettingsRepository,
    GetFamilyOverview? getFamilyOverview,
    AgendaReminderChanged? onReminderChanged,
    AgendaReminderDeleted? onReminderDeleted,
    this.babyId,
    super.routes,
  }) : super(
         path: kind.relativePath,
         pageBuilder: (context, state) => MaterialPage<void>(
           key: ValueKey(
             'agenda-${kind.name}-${state.pathParameters['eventId']}',
           ),
           name: 'Agenda${kind.name}',
           child: _AgendaSubpageView(
             kind: kind,
             babyId: babyId,
             getFamilyOverview: getFamilyOverview,
             eventId: state.pathParameters['eventId'],
             createAgendaEvent: createAgendaEvent,
             agendaRepository: agendaRepository,
             appSettingsRepository: appSettingsRepository,
             onReminderChanged: onReminderChanged,
             onReminderDeleted: onReminderDeleted,
             onCompleted: () => context.pop(),
           ),
         ),
       );

  final String? babyId;

  static const reminderSettingsPath = '/agenda/reminders/settings';
  static const createReminderPath = '/agenda/reminders/new';

  static String eventDetailPath(String eventId) =>
      '/agenda/events/${Uri.encodeComponent(eventId)}';
}

class _AgendaSubpageView extends StatefulWidget {
  const _AgendaSubpageView({
    required this.kind,
    required this.babyId,
    required this.getFamilyOverview,
    required this.createAgendaEvent,
    required this.agendaRepository,
    required this.appSettingsRepository,
    required this.onCompleted,
    required this.onReminderChanged,
    required this.onReminderDeleted,
    this.eventId,
  });

  final AgendaSubpageKind kind;
  final String? babyId;
  final GetFamilyOverview? getFamilyOverview;
  final String? eventId;
  final CreateAgendaEvent createAgendaEvent;
  final AgendaRepository agendaRepository;
  final AppSettingsRepository appSettingsRepository;
  final VoidCallback onCompleted;
  final AgendaReminderChanged? onReminderChanged;
  final AgendaReminderDeleted? onReminderDeleted;

  @override
  State<_AgendaSubpageView> createState() => _AgendaSubpageViewState();
}

class _AgendaSubpageViewState extends State<_AgendaSubpageView> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  bool _personalReminders = true;
  bool _familyReminders = true;
  bool _dailySummary = false;
  bool _settingsLoading = true;
  bool _settingsSaving = false;
  bool _saving = false;
  String? _error;
  AgendaCategory _category = AgendaCategory.controls;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    unawaited(_loadReminderSettings());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kind.title),
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: widget.onCompleted,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: switch (widget.kind) {
            AgendaSubpageKind.reminderSettings => _reminderSettings(),
            AgendaSubpageKind.createReminder => _createReminder(),
            AgendaSubpageKind.eventDetail => _eventDetail(),
          },
        ),
      ),
    );
  }

  List<Widget> _reminderSettings() => [
    const Text(
      'Elige qué avisos quieres recibir. Los eventos siguen disponibles aunque desactives una notificación.',
    ),
    const SizedBox(height: 16),
    if (_settingsLoading)
      const Center(child: CircularProgressIndicator())
    else
      Card(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Mis recordatorios'),
              subtitle: const Text('Avisos asignados a tu cuenta'),
              value: _personalReminders,
              onChanged: _settingsSaving
                  ? null
                  : (value) => _saveReminderSettings(personalReminders: value),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Actividad familiar'),
              subtitle: const Text('Eventos creados por otros cuidadores'),
              value: _familyReminders,
              onChanged: _settingsSaving
                  ? null
                  : (value) => _saveReminderSettings(familyActivity: value),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Resumen diario'),
              subtitle: const Text(
                'Un resumen compacto de la actividad del día',
              ),
              value: _dailySummary,
              onChanged: _settingsSaving
                  ? null
                  : (value) => _saveReminderSettings(dailySummary: value),
            ),
          ],
        ),
      ),
    if (_settingsSaving) ...[
      const SizedBox(height: 12),
      const LinearProgressIndicator(),
    ],
    if (_error != null) ...[
      const SizedBox(height: 12),
      Text(
        _error!,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ],
    const SizedBox(height: 16),
    const Card(
      child: ListTile(
        leading: Icon(Icons.info_outline_rounded),
        title: Text('Los cambios se guardan automáticamente'),
        subtitle: Text(
          'Desactivar avisos no elimina los recordatorios de la agenda.',
        ),
      ),
    ),
  ];

  List<Widget> _createReminder() => [
    const Text(
      'Programa una acción futura. Para guardar algo que ya ocurrió, usa Registrar.',
    ),
    const SizedBox(height: 20),
    Text('Tipo', style: Theme.of(context).textTheme.titleSmall),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AgendaCategory.values
          .map(
            (category) => ChoiceChip(
              selected: _category == category,
              label: Text(_categoryLabel(category)),
              avatar: Icon(_categoryIcon(category), size: 18),
              onSelected: (_) => setState(() => _category = category),
            ),
          )
          .toList(growable: false),
    ),
    const SizedBox(height: 20),
    TextField(
      controller: _titleController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Título',
        hintText: 'Ej. Control pediátrico',
        border: OutlineInputBorder(),
      ),
    ),
    const SizedBox(height: 16),
    Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(_formatDate(_date)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.schedule_outlined),
            label: Text(_time.format(context)),
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),
    TextField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notas (opcional)',
        hintText: 'Indicaciones, dirección o preparación',
        border: OutlineInputBorder(),
      ),
      maxLength: 500,
      maxLines: 4,
    ),
    if (_error != null) ...[
      const SizedBox(height: 8),
      Text(
        _error!,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ],
    const SizedBox(height: 20),
    FilledButton.icon(
      onPressed: _saving ? null : _saveReminder,
      icon: _saving
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.check_rounded),
      label: Text(_saving ? 'Guardando…' : 'Guardar recordatorio'),
    ),
    const SizedBox(height: 8),
    const Text(
      'Se guarda primero en este dispositivo y se sincroniza automáticamente.',
      textAlign: TextAlign.center,
    ),
  ];

  List<Widget> _eventDetail() => [
    FutureBuilder<AgendaEventEntity?>(
      future: widget.eventId == null
          ? Future<AgendaEventEntity?>.value()
          : widget.agendaRepository.findById(widget.eventId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final event = snapshot.data;
        if (event == null) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.event_busy_outlined),
              title: Text('Este evento ya no está disponible'),
            ),
          );
        }
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(_categoryIcon(event.category)),
                title: Text(event.title),
                subtitle: Text(event.description),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: Text(
                  '${_formatDate(event.startsAt.toLocal())} · ${TimeOfDay.fromDateTime(event.startsAt.toLocal()).format(context)}',
                ),
                subtitle: Text(_syncLabel(event.syncStatus)),
              ),
              if (event.isDerivedFromRegister) ...[
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.link_rounded),
                  title: Text('Creado desde un registro de medicamento'),
                  subtitle: Text(
                    'La pauta se actualiza desde el registro original.',
                  ),
                ),
              ] else ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saving
                              ? null
                              : () => _editReminder(event),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _saving
                              ? null
                              : () => _deleteReminder(event),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Eliminar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    ),
  ];

  Future<void> _loadReminderSettings() async {
    try {
      final settings = await widget.appSettingsRepository.get();
      if (!mounted) return;
      setState(() {
        _personalReminders = settings.personalReminders;
        _familyReminders = settings.familyActivity;
        _dailySummary = settings.dailySummary;
        _settingsLoading = false;
        _error = null;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _settingsLoading = false;
        _error = 'No pudimos cargar tus preferencias de recordatorios.';
      });
    }
  }

  Future<void> _saveReminderSettings({
    bool? personalReminders,
    bool? familyActivity,
    bool? dailySummary,
  }) async {
    final previousPersonal = _personalReminders;
    final previousFamily = _familyReminders;
    final previousSummary = _dailySummary;
    setState(() {
      _personalReminders = personalReminders ?? _personalReminders;
      _familyReminders = familyActivity ?? _familyReminders;
      _dailySummary = dailySummary ?? _dailySummary;
      _settingsSaving = true;
      _error = null;
    });
    try {
      await widget.appSettingsRepository.update(
        AppSettingsPatch(
          personalReminders: personalReminders,
          familyActivity: familyActivity,
          dailySummary: dailySummary,
        ),
      );
    } on Object {
      if (!mounted) return;
      setState(() {
        _personalReminders = previousPersonal;
        _familyReminders = previousFamily;
        _dailySummary = previousSummary;
        _error = 'No pudimos guardar el cambio. Inténtalo nuevamente.';
      });
    } finally {
      if (mounted) setState(() => _settingsSaving = false);
    }
  }

  Future<void> _editReminder(AgendaEventEntity event) async {
    final titleController = TextEditingController(text: event.title);
    final notesController = TextEditingController(text: event.description);
    var category = event.category;
    var date = event.startsAt.toLocal();
    var time = TimeOfDay.fromDateTime(date);
    var saving = false;
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Editar recordatorio'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AgendaCategory>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final value in AgendaCategory.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(_categoryLabel(value)),
                        ),
                    ],
                    onChanged: saving
                        ? null
                        : (value) {
                            if (value != null) {
                              setDialogState(() => category = value);
                            }
                          },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: saving
                              ? null
                              : () async {
                                  final picked = await showDatePicker(
                                    context: dialogContext,
                                    initialDate: date,
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 730),
                                    ),
                                  );
                                  if (picked != null) {
                                    setDialogState(() => date = picked);
                                  }
                                },
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(_formatDate(date)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: saving
                              ? null
                              : () async {
                                  final picked = await showTimePicker(
                                    context: dialogContext,
                                    initialTime: time,
                                  );
                                  if (picked != null) {
                                    setDialogState(() => time = picked);
                                  }
                                },
                          icon: const Icon(Icons.schedule_outlined),
                          label: Text(time.format(dialogContext)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (dialogError != null)
                    Text(
                      dialogError!,
                      style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final title = titleController.text.trim();
                      final startsAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      if (title.isEmpty || !startsAt.isAfter(DateTime.now())) {
                        setDialogState(() {
                          dialogError = title.isEmpty
                              ? 'Escribe un título.'
                              : 'El recordatorio debe quedar en el futuro.';
                        });
                        return;
                      }
                      setDialogState(() {
                        saving = true;
                        dialogError = null;
                      });
                      try {
                        final updated = await widget.agendaRepository.update(
                          event.id,
                          AgendaEventPatch(
                            category: category,
                            title: title,
                            description: notesController.text.trim(),
                            startsAt: startsAt,
                          ),
                        );
                        if (updated != null) {
                          await _notifyReminderChanged(updated);
                        }
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (mounted) {
                          setState(() {});
                          BebeInAppSnackbar.show(
                            context,
                            message: 'Recordatorio actualizado.',
                            variant: BebeInAppSnackbarVariant.success,
                          );
                        }
                      } on Object {
                        if (dialogContext.mounted) {
                          setDialogState(() {
                            saving = false;
                            dialogError = 'No pudimos guardar los cambios.';
                          });
                        }
                      }
                    },
              child: saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    titleController.dispose();
    notesController.dispose();
  }

  Future<void> _deleteReminder(AgendaEventEntity event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar recordatorio?'),
        content: Text(
          '“${event.title}” desaparecerá de la agenda del círculo de cuidado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await widget.agendaRepository.delete(event.id);
      await _notifyReminderDeleted(event.id);
      if (mounted) widget.onCompleted();
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'No pudimos eliminar el recordatorio.';
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (value != null && mounted) setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(context: context, initialTime: _time);
    if (value != null && mounted) setState(() => _time = value);
  }

  Future<void> _saveReminder() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Escribe un título para identificar el evento.');
      return;
    }
    final startsAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    if (!startsAt.isAfter(DateTime.now())) {
      setState(() => _error = 'El recordatorio debe quedar en el futuro.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final resolvedBabyId =
          widget.babyId ??
          (await widget.getFamilyOverview?.call())?.activeBabyId;
      if (resolvedBabyId == null || resolvedBabyId.isEmpty) {
        throw StateError('No active baby is available for Agenda.');
      }
      final created = await widget.createAgendaEvent(
        AgendaEventDraft(
          babyId: resolvedBabyId,
          category: _category,
          title: title,
          description: _notesController.text.trim(),
          startsAt: startsAt,
        ),
      );
      await _notifyReminderChanged(created);
      if (mounted) widget.onCompleted();
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'No pudimos guardar el recordatorio. Inténtalo nuevamente.';
        });
      }
    }
  }

  static String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

  Future<void> _notifyReminderChanged(AgendaEventEntity event) async {
    try {
      await widget.onReminderChanged?.call(context, event);
    } on Object catch (error, stackTrace) {
      debugPrint('No se pudo programar el recordatorio local: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _notifyReminderDeleted(String eventId) async {
    try {
      await widget.onReminderDeleted?.call(context, eventId);
    } on Object catch (error, stackTrace) {
      debugPrint('No se pudo cancelar el recordatorio local: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static String _categoryLabel(AgendaCategory category) => switch (category) {
    AgendaCategory.vaccines => 'Vacuna',
    AgendaCategory.controls => 'Control',
    AgendaCategory.medication => 'Medicamento',
    AgendaCategory.exams => 'Examen',
  };

  static IconData _categoryIcon(AgendaCategory category) => switch (category) {
    AgendaCategory.vaccines => Icons.vaccines_outlined,
    AgendaCategory.controls => Icons.medical_services_outlined,
    AgendaCategory.medication => Icons.medication_outlined,
    AgendaCategory.exams => Icons.science_outlined,
  };

  static String _syncLabel(AgendaSyncStatus status) => switch (status) {
    AgendaSyncStatus.synced => 'Sincronizado',
    AgendaSyncStatus.pending => 'Guardado local · pendiente de sincronizar',
    AgendaSyncStatus.syncing => 'Sincronizando…',
    AgendaSyncStatus.failed => 'Guardado local · se reintentará',
  };
}
