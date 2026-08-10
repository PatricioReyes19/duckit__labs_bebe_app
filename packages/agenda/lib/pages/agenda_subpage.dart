import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AgendaSubpageKind { reminderSettings, createReminder, eventDetail }

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
    this.babyId = 'local-active-baby',
    super.routes,
  }) : super(
         path: kind.relativePath,
         pageBuilder: (context, state) => CupertinoPage<void>(
           key: ValueKey(
             'agenda-${kind.name}-${state.pathParameters['eventId']}',
           ),
           name: 'Agenda${kind.name}',
           child: _AgendaSubpageView(
             kind: kind,
             babyId: babyId,
             eventId: state.pathParameters['eventId'],
             createAgendaEvent: createAgendaEvent,
             agendaRepository: agendaRepository,
             onCompleted: () => context.pop(),
           ),
         ),
       );

  final String babyId;

  static const reminderSettingsPath = '/agenda/reminders/settings';
  static const createReminderPath = '/agenda/reminders/new';

  static String eventDetailPath(String eventId) =>
      '/agenda/events/${Uri.encodeComponent(eventId)}';
}

class _AgendaSubpageView extends StatefulWidget {
  const _AgendaSubpageView({
    required this.kind,
    required this.babyId,
    required this.createAgendaEvent,
    required this.agendaRepository,
    required this.onCompleted,
    this.eventId,
  });

  final AgendaSubpageKind kind;
  final String babyId;
  final String? eventId;
  final CreateAgendaEvent createAgendaEvent;
  final AgendaRepository agendaRepository;
  final VoidCallback onCompleted;

  @override
  State<_AgendaSubpageView> createState() => _AgendaSubpageViewState();
}

class _AgendaSubpageViewState extends State<_AgendaSubpageView> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  bool _personalReminders = true;
  bool _familyReminders = true;
  bool _saving = false;
  String? _error;
  AgendaCategory _category = AgendaCategory.controls;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

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
    Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Mis recordatorios'),
            subtitle: const Text('Avisos asignados a tu cuenta'),
            value: _personalReminders,
            onChanged: (value) => setState(() => _personalReminders = value),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Actividad familiar'),
            subtitle: const Text('Eventos creados por otros cuidadores'),
            value: _familyReminders,
            onChanged: (value) => setState(() => _familyReminders = value),
          ),
        ],
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
              ],
            ],
          ),
        );
      },
    ),
  ];

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
      await widget.createAgendaEvent(
        AgendaEventDraft(
          babyId: widget.babyId,
          category: _category,
          title: title,
          description: _notesController.text.trim(),
          startsAt: startsAt,
        ),
      );
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
