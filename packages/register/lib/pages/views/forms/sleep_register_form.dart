import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Controlled visual form for sleep records.
class SleepRegisterForm extends StatelessWidget {
  const SleepRegisterForm({
    this.startTime = '01:30 PM',
    this.duration = '1 h 05 min',
    this.endTime = '02:35 PM',
    this.place = 'crib',
    this.mood = 'calm',
    this.notesController,
    this.symptomsController,
    this.onStartTimePressed,
    this.onDurationPressed,
    this.onEndTimePressed,
    this.onPlaceChanged,
    this.onMoodChanged,
    this.onNotesChanged,
    this.onSymptomsChanged,
    super.key,
  });

  final String startTime;
  final String duration;
  final String endTime;
  final String place;
  final String mood;
  final TextEditingController? notesController;
  final TextEditingController? symptomsController;
  final VoidCallback? onStartTimePressed;
  final VoidCallback? onDurationPressed;
  final VoidCallback? onEndTimePressed;
  final ValueChanged<String>? onPlaceChanged;
  final ValueChanged<String>? onMoodChanged;
  final ValueChanged<String>? onNotesChanged;
  final ValueChanged<String>? onSymptomsChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            BebePickerField(
              compact: true,
              label: 'Duración',
              value: duration,
              kind: BebePickerFieldKind.duration,
              onPressed: onDurationPressed,
            ),
            BebePickerField(
              compact: true,
              label: 'Hora de término',
              value: endTime,
              optional: true,
              kind: BebePickerFieldKind.time,
              onPressed: onEndTimePressed,
            ),
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
        BebeSegmentedFormField<String>(
          label: 'Estado de ánimo al despertar',
          items: const [
            BebeSegmentedItem(value: 'calm', label: 'Tranquilo'),
            BebeSegmentedItem(value: 'sleepy', label: 'Dormido'),
            BebeSegmentedItem(value: 'irritable', label: 'Irritable'),
          ],
          selectedValue: mood,
          onChanged: onMoodChanged,
        ),
        SizedBox(height: spacing.spacingXl),
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
