import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home/home.dart';

class HomeDailyHistoryView extends StatelessWidget {
  const HomeDailyHistoryView({
    required this.babyName,
    required this.onRegisterPressed,
    this.onEditEvent,
    super.key,
  });

  final String babyName;
  final VoidCallback onRegisterPressed;
  final ValueChanged<RegisteredEvent>? onEditEvent;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return BlocBuilder<HomeDailyHistoryCubit, HomeDailyHistoryState>(
      builder: (context, state) {
        final filtered = state.filteredEvents;
        return ColoredBox(
          color: context.theme.colors.background.neutralsSurface,
          child: BebeResponsiveContent(
            maxWidth: BebeLayout.formContentMaxWidth,
            child: RefreshIndicator(
              onRefresh: context.read<HomeDailyHistoryCubit>().reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  spacing.spacingXl,
                  spacing.spacingL,
                  spacing.spacingXl,
                  spacing.spacing2xl,
                ),
                children: [
                  BebeTitleSection(
                    title: babyName,
                    description: _dateLabel(state.referenceDate),
                    trailing: BebeStatusBadge(
                      label: state.events.length == 1
                          ? '1 registro'
                          : '${state.events.length} registros',
                      variant: BebeStatusBadgeVariant.information,
                    ),
                  ),
                  SizedBox(height: spacing.spacingL),
                  _HistoryFilters(
                    selectedType: state.selectedType,
                    onSelected:
                        context.read<HomeDailyHistoryCubit>().typeSelected,
                  ),
                  SizedBox(height: spacing.spacing2xl),
                  if (state.status == DailyHistoryStatus.loading ||
                      state.status == DailyHistoryStatus.initial)
                    const Center(child: CircularProgressIndicator())
                  else if (state.status == DailyHistoryStatus.failure)
                    BebeStatePanel(
                      title: 'No pudimos cargar el historial',
                      description:
                          'Revisa el almacenamiento local e inténtalo nuevamente.',
                      variant: BebeStatePanelVariant.error,
                      primaryActionLabel: 'Reintentar',
                      onPrimaryActionPressed:
                          context.read<HomeDailyHistoryCubit>().reload,
                    )
                  else if (filtered.isEmpty)
                    BebeStatePanel(
                      title: state.selectedType == null
                          ? 'Aún no hay registros hoy'
                          : 'No hay registros de este tipo',
                      description: state.selectedType == null
                          ? 'Registra una actividad para comenzar el historial del día.'
                          : 'Selecciona otra categoría o agrega un nuevo registro.',
                      variant: BebeStatePanelVariant.empty,
                      primaryActionLabel: 'Registrar ahora',
                      onPrimaryActionPressed: onRegisterPressed,
                    )
                  else
                    BebeTimeline(
                      semanticLabel: 'Historial de actividades de hoy',
                      entries: filtered
                          .map((event) => _timelineEntry(context, event))
                          .toList(growable: false),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BebeTimelineEntry _timelineEntry(
    BuildContext context,
    RegisteredEvent event,
  ) {
    final presentation = _EventPresentation.from(event);
    return BebeTimelineEntry(
      timeLabel: _timeLabel(event.occurredAt),
      title: presentation.title,
      description: presentation.description,
      icon: Icon(presentation.icon),
      variant: presentation.variant,
      status: onEditEvent == null
          ? null
          : const BebeStatusBadge(
              label: 'Gestionar',
              variant: BebeStatusBadgeVariant.information,
              icon: Icon(Icons.edit_outlined),
            ),
      metadata: event.caregiverId == null
          ? null
          : BebeMetadataItem(
              icon: const Icon(Icons.person_outline_rounded),
              label: event.caregiverId!,
            ),
      onPressed: () => _showDetails(context, event, presentation),
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    RegisteredEvent event,
    _EventPresentation presentation,
  ) {
    final historyCubit = context.read<HomeDailyHistoryCubit>();
    return showBebeBottomSheet<void>(
      context: context,
      variant: BebeBottomSheetVariant.dynamic,
      maximumHeightFactor: .68,
      semanticLabel: 'Información del evento ${presentation.title}',
      headerBuilder: (_) => BebeTitleSection(
        title: presentation.title,
        description:
            '${_dateLabel(event.occurredAt)} · ${_timeLabel(event.occurredAt)}',
      ),
      bodyBuilder: (sheetContext) {
        final spacing = sheetContext.theme.spacing;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BebeDetailSummaryCard(
              semanticLabel: 'Detalle del registro',
              items: [
                for (final detail in event.details.entries)
                  if (_hasDetailValue(detail.value))
                    BebeDetailSummaryItem(
                      icon: const Icon(Icons.info_outline_rounded),
                      label: _detailLabel(detail.key),
                      value: _detailValue(detail.key, detail.value),
                    ),
              ],
            ),
            if (event.notes?.trim().isNotEmpty ?? false) ...[
              SizedBox(height: spacing.spacingL),
              BebeInfoBanner(
                icon: const Icon(Icons.notes_rounded),
                title: 'Notas',
                description: event.notes!,
              ),
            ],
          ],
        );
      },
      footerBuilder: (sheetContext) {
        final spacing = sheetContext.theme.spacing;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isOngoingSleep(event)) ...[
              BebeButton(
                key: ValueKey('finish-sleep-${event.id}'),
                label: 'Registrar despertar',
                onPressed: () =>
                    _finishSleep(sheetContext, historyCubit, event),
                leading: const Icon(Icons.wb_sunny_outlined),
              ),
              SizedBox(height: spacing.spacingM),
            ],
            if (onEditEvent != null) ...[
              BebeButton(
                key: ValueKey('edit-register-${event.id}'),
                label: 'Editar registro',
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  onEditEvent!(event);
                },
                variant: BebeButtonVariant.secondary,
                leading: const Icon(Icons.edit_outlined),
              ),
              SizedBox(height: spacing.spacingM),
            ],
            BebeButton(
              key: ValueKey('delete-register-${event.id}'),
              label: 'Eliminar registro',
              onPressed: () =>
                  _confirmDelete(sheetContext, historyCubit, event),
              variant: BebeButtonVariant.destructive,
              leading: const Icon(Icons.delete_outline_rounded),
            ),
            SizedBox(height: spacing.spacingM),
            BebeButton(
              label: 'Cerrar',
              onPressed: () => Navigator.of(sheetContext).pop(),
              variant: BebeButtonVariant.secondary,
            ),
          ],
        );
      },
    );
  }

  Future<void> _finishSleep(
    BuildContext context,
    HomeDailyHistoryCubit historyCubit,
    RegisteredEvent event,
  ) async {
    final now = DateTime.now();
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
      helpText: 'Hora de despertar',
      cancelText: 'Cancelar',
      confirmText: 'Registrar',
    );
    if (selected == null || !context.mounted) return;
    final endedAt = DateTime(
      now.year,
      now.month,
      now.day,
      selected.hour,
      selected.minute,
    );
    if (!endedAt.isAfter(event.occurredAt.toLocal())) {
      BebeInAppSnackbar.show(
        context,
        title: 'Hora no válida',
        message: 'El despertar debe ser posterior al inicio del sueño.',
        variant: BebeInAppSnackbarVariant.error,
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      final completed = await historyCubit.finishSleep(event, endedAt);
      if (!context.mounted) return;
      if (!completed) {
        BebeInAppSnackbar.show(
          context,
          title: 'No se pudo finalizar',
          message: 'Este registro ya no está marcado como sueño en curso.',
          variant: BebeInAppSnackbarVariant.warning,
        );
        return;
      }
      Navigator.of(context).pop();
      BebeInAppSnackbar.showOn(
        messenger,
        title: 'Sueño finalizado',
        message: 'La hora de despertar y la duración quedaron registradas.',
        variant: BebeInAppSnackbarVariant.success,
      );
    } on Object {
      if (!context.mounted) return;
      BebeInAppSnackbar.show(
        context,
        title: 'No se pudo guardar',
        message: 'Inténtalo nuevamente. El sueño continúa marcado en curso.',
        variant: BebeInAppSnackbarVariant.error,
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HomeDailyHistoryCubit historyCubit,
    RegisteredEvent event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: const Text(
          'Se eliminará este registro del historial en todos tus dispositivos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final deleted = await historyCubit.deleteEvent(event.id);
      if (!context.mounted) return;
      if (!deleted) {
        BebeInAppSnackbar.show(
          context,
          title: 'No se pudo eliminar',
          message: 'El registro ya no está disponible o no puede eliminarse.',
          variant: BebeInAppSnackbarVariant.error,
        );
        return;
      }
      Navigator.of(context).pop();
      BebeInAppSnackbar.showOn(
        messenger,
        title: 'Registro eliminado',
        message: 'Se quitó del historial.',
        variant: BebeInAppSnackbarVariant.success,
      );
    } on Object {
      if (!context.mounted) return;
      BebeInAppSnackbar.show(
        context,
        title: 'No se pudo eliminar',
        message: 'Inténtalo nuevamente.',
        variant: BebeInAppSnackbarVariant.error,
      );
    }
  }

  static String _detailLabel(String key) {
    const labels = <String, String>{
      'subtype': 'Tipo',
      'side': 'Lado',
      'duration_minutes': 'Duración',
      'end_at': 'Hora de despertar',
      'sleep_status': 'Estado del sueño',
      'mood': 'Estado',
      'symptoms': 'Síntomas',
      'place': 'Lugar',
      'appearance': 'Apariencia',
      'color': 'Color',
      'amount': 'Cantidad',
      'observation_type': 'Observación',
      'description': 'Descripción',
      'photo_paths': 'Fotos',
      'severity': 'Gravedad',
      'share_with_pediatrician': 'Compartir con pediatra',
      'name': 'Medicamento',
      'dose': 'Dosis',
      'unit': 'Unidad',
      'frequency': 'Frecuencia',
      'end_date': 'Fecha de término',
      'schedule_next_doses': 'Próximas dosis',
      'measurement_type': 'Medición',
      'value': 'Valor',
      'source': 'Fuente',
    };
    return labels[key] ??
        key
            .split('_')
            .map((part) => part.isEmpty
                ? part
                : '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' ');
  }

  static bool _hasDetailValue(Object? value) =>
      value != null && value != '' && (value is! List || value.isNotEmpty);

  static String _detailValue(String key, Object? value) {
    if (value == null || value == '') return 'Sin información';
    if (key == 'sleep_status') {
      return value == 'ongoing' ? 'En curso' : 'Finalizado';
    }
    if (key == 'subtype') {
      return switch (value) {
        'nap' => 'Siesta',
        'night' => 'Sueño nocturno',
        _ => '$value',
      };
    }
    if (key == 'duration_minutes') return '$value min';
    if (key == 'end_at') {
      final parsed = DateTime.tryParse('$value');
      if (parsed != null) return _timeLabel(parsed);
    }
    if (value is bool) return value ? 'Sí' : 'No';
    if (value is List<Object?>) {
      return value.isEmpty ? 'Sin información' : value.join(', ');
    }
    return '$value';
  }

  static String _timeLabel(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  static String _dateLabel(DateTime value) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final local = value.toLocal();
    return '${local.day} de ${months[local.month - 1]} de ${local.year}';
  }

  static bool _isOngoingSleep(RegisteredEvent event) => event.isActive;
}

class _HistoryFilters extends StatelessWidget {
  const _HistoryFilters({required this.selectedType, required this.onSelected});

  final RegisterEventType? selectedType;
  final ValueChanged<RegisterEventType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final options = <(RegisterEventType?, String, IconData)>[
      (null, 'Todos', Icons.apps_rounded),
      (RegisterEventType.feeding, 'Alimentación', Icons.local_drink_outlined),
      (RegisterEventType.sleep, 'Sueño', Icons.bedtime_outlined),
      (RegisterEventType.diaper, 'Pañal', Icons.baby_changing_station_outlined),
      (
        RegisterEventType.clinicalObservation,
        'Observación',
        Icons.edit_note_rounded
      ),
      (RegisterEventType.medication, 'Medicación', Icons.medication_outlined),
      (
        RegisterEventType.measurement,
        'Medición',
        Icons.monitor_weight_outlined
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < options.length; index++) ...[
            BebeFilterChip(
              label: options[index].$2,
              icon: Icon(options[index].$3),
              size: BebeFilterChipSize.small,
              isSelected: selectedType == options[index].$1,
              onPressed: () => onSelected(options[index].$1),
            ),
            if (index != options.length - 1) SizedBox(width: spacing.spacingS),
          ],
        ],
      ),
    );
  }
}

class _EventPresentation {
  const _EventPresentation({
    required this.title,
    required this.description,
    required this.icon,
    required this.variant,
  });

  final String title;
  final String description;
  final IconData icon;
  final BebeLeadingIconVariant variant;

  factory _EventPresentation.from(RegisteredEvent event) {
    final details = event.details;
    return switch (event.type) {
      RegisterEventType.feeding => _EventPresentation(
          title: 'Alimentación',
          description:
              '${_text(details['subtype'], 'Registro de alimentación')} · ${_minutes(details['duration_minutes'])}',
          icon: Icons.local_drink_outlined,
          variant: BebeLeadingIconVariant.brand,
        ),
      RegisterEventType.sleep => _EventPresentation(
          title: 'Sueño',
          description: event.isActive
              ? '${_sleepSubtype(details['subtype'])} · En curso'
              : '${_sleepSubtype(details['subtype'])} · ${_minutes(details['duration_minutes'])}',
          icon: Icons.bedtime_outlined,
          variant: BebeLeadingIconVariant.accent,
        ),
      RegisterEventType.diaper => _EventPresentation(
          title: 'Pañal',
          description:
              '${_text(details['subtype'], 'Cambio')} · ${_text(details['appearance'], 'Sin detalle')}',
          icon: Icons.baby_changing_station_outlined,
          variant: BebeLeadingIconVariant.warning,
        ),
      RegisterEventType.clinicalObservation => _EventPresentation(
          title: 'Observación clínica',
          description: _text(details['description'], 'Observación registrada'),
          icon: Icons.edit_note_rounded,
          variant: BebeLeadingIconVariant.information,
        ),
      RegisterEventType.medication => _EventPresentation(
          title: 'Medicación',
          description:
              '${_text(details['name'], 'Medicamento')} · ${_text(details['dose'], '')} ${_text(details['unit'], '')}'
                  .trim(),
          icon: Icons.medication_outlined,
          variant: BebeLeadingIconVariant.error,
        ),
      RegisterEventType.measurement => _EventPresentation(
          title: 'Medición',
          description:
              '${_text(details['measurement_type'], 'Medición')} · ${_text(details['value'], '')} ${_text(details['unit'], '')}'
                  .trim(),
          icon: Icons.monitor_weight_outlined,
          variant: BebeLeadingIconVariant.success,
        ),
    };
  }

  static String _text(Object? value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String _sleepSubtype(Object? value) => switch (value) {
        'nap' => 'Siesta',
        'night' => 'Sueño nocturno',
        _ => _text(value, 'Descanso'),
      };

  static String _minutes(Object? value) {
    final minutes = value is num ? value.toInt() : int.tryParse('$value');
    if (minutes == null) return 'Duración sin informar';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder == 0 ? '$hours h' : '$hours h $remainder min';
  }
}
