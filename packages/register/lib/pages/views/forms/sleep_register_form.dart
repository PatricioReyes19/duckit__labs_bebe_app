import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Controlled visual form for an ongoing or completed sleep record.
class SleepRegisterForm extends StatelessWidget {
  const SleepRegisterForm({
    this.mode = 'ongoing',
    this.startTime = '13:30',
    this.duration = '1 h 05 min',
    this.endTime = '14:35',
    this.place = 'crib',
    this.mood = 'calm',
    this.notesController,
    this.symptomsController,
    this.onModeChanged,
    this.onStartTimePressed,
    this.onDurationPressed,
    this.onEndTimePressed,
    this.onPlaceChanged,
    this.onMoodChanged,
    this.onNotesChanged,
    this.onSymptomsChanged,
    super.key,
  });

  final String mode;
  final String startTime;
  final String duration;
  final String endTime;
  final String place;
  final String mood;
  final TextEditingController? notesController;
  final TextEditingController? symptomsController;
  final ValueChanged<String>? onModeChanged;
  final VoidCallback? onStartTimePressed;
  final VoidCallback? onDurationPressed;
  final VoidCallback? onEndTimePressed;
  final ValueChanged<String>? onPlaceChanged;
  final ValueChanged<String>? onMoodChanged;
  final ValueChanged<String>? onNotesChanged;
  final ValueChanged<String>? onSymptomsChanged;

  bool get isOngoing => mode == 'ongoing';

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BebeSegmentedFormField<String>(
          label: '¿Qué quieres registrar?',
          items: const [
            BebeSegmentedItem(
              value: 'ongoing',
              label: 'Se durmió ahora',
              icon: Icon(Icons.bedtime_outlined),
            ),
            BebeSegmentedItem(
              value: 'completed',
              label: 'Sueño pasado',
              icon: Icon(Icons.history_rounded),
            ),
          ],
          selectedValue: mode,
          onChanged: onModeChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        if (isOngoing) ...[
          const BebeInfoBanner(
            key: ValueKey('sleep-ongoing-guidance'),
            title: 'Sin hora de despertar',
            description:
                'Guardaremos la hora de inicio. Cuando despierte podrás finalizar el sueño desde Home o desde el historial.',
            icon: Icon(Icons.timer_outlined),
            variant: BebeInfoBannerVariant.information,
          ),
          SizedBox(height: spacing.spacingXl),
        ],
        BebeResponsiveFormGrid(
          minimumItemWidth: 96,
          semanticLabel: 'Horario del sueño',
          children: [
            BebePickerField(
              compact: true,
              label: 'Hora de inicio',
              value: startTime,
              kind: BebePickerFieldKind.time,
              onPressed: onStartTimePressed,
            ),
            if (!isOngoing) ...[
              BebePickerField(
                compact: true,
                label: 'Duración',
                value: duration,
                kind: BebePickerFieldKind.duration,
                onPressed: onDurationPressed,
              ),
              BebePickerField(
                compact: true,
                label: 'Hora de despertar',
                value: endTime,
                kind: BebePickerFieldKind.time,
                onPressed: onEndTimePressed,
              ),
            ],
          ],
        ),
        SizedBox(height: spacing.spacingXl),
        BebeSegmentedFormField<String>(
          label: 'Lugar',
          items: const [
            BebeSegmentedItem(
              value: 'crib',
              label: 'Cuna',
              icon: Icon(Icons.bed_outlined),
            ),
            BebeSegmentedItem(
              value: 'car',
              label: 'Coche',
              icon: Icon(Icons.directions_car_outlined),
            ),
            BebeSegmentedItem(
              value: 'arms',
              label: 'Brazos',
              icon: Icon(Icons.volunteer_activism_outlined),
            ),
          ],
          selectedValue: place,
          onChanged: onPlaceChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        if (!isOngoing) ...[
          BebeSegmentedFormField<String>(
            label: 'Estado de ánimo al despertar',
            items: const [
              BebeSegmentedItem(value: 'calm', label: 'Tranquilo'),
              BebeSegmentedItem(value: 'sleepy', label: 'Somnoliento'),
              BebeSegmentedItem(value: 'irritable', label: 'Irritable'),
            ],
            selectedValue: mood,
            onChanged: onMoodChanged,
          ),
          SizedBox(height: spacing.spacingXl),
        ],
        BebeNotesField(
          compact: true,
          label: 'Notas',
          controller: notesController,
          onChanged: onNotesChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeNotesField(
          compact: true,
          label: 'Síntomas / observaciones',
          controller: symptomsController,
          onChanged: onSymptomsChanged,
        ),
      ],
    );
  }
}
