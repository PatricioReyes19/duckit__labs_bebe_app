import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Controlled visual form for feeding records.
class FeedingRegisterForm extends StatelessWidget {
  const FeedingRegisterForm({
    this.side = 'both',
    this.startTime = '09:30 AM',
    this.duration = '15 min',
    this.endTime = '',
    this.mood = 'calm',
    this.notesController,
    this.symptomsController,
    this.onSideChanged,
    this.onStartTimePressed,
    this.onDurationPressed,
    this.onEndTimePressed,
    this.onMoodChanged,
    this.onNotesChanged,
    this.onSymptomsChanged,
    super.key,
  });

  final String side;
  final String startTime;
  final String duration;
  final String endTime;
  final String mood;
  final TextEditingController? notesController;
  final TextEditingController? symptomsController;
  final ValueChanged<String>? onSideChanged;
  final VoidCallback? onStartTimePressed;
  final VoidCallback? onDurationPressed;
  final VoidCallback? onEndTimePressed;
  final ValueChanged<String>? onMoodChanged;
  final ValueChanged<String>? onNotesChanged;
  final ValueChanged<String>? onSymptomsChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BebeSegmentedFormField<String>(
          label: 'Lado',
          items: const [
            BebeSegmentedItem(value: 'left', label: 'Izquierdo'),
            BebeSegmentedItem(value: 'right', label: 'Derecho'),
            BebeSegmentedItem(value: 'both', label: 'Ambos'),
          ],
          selectedValue: side,
          onChanged: onSideChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeResponsiveFormGrid(
          semanticLabel: 'Horario de la alimentación',
          children: [
            BebePickerField(
              label: 'Hora de inicio',
              value: startTime,
              kind: BebePickerFieldKind.time,
              onPressed: onStartTimePressed,
            ),
            BebePickerField(
              label: 'Duración',
              value: duration,
              kind: BebePickerFieldKind.duration,
              onPressed: onDurationPressed,
            ),
            BebePickerField(
              label: 'Hora de término',
              value: endTime,
              placeholder: '--:-- --',
              optional: true,
              kind: BebePickerFieldKind.time,
              onPressed: onEndTimePressed,
            ),
          ],
        ),
        SizedBox(height: spacing.spacingXl),
        BebeSegmentedFormField<String>(
          label: 'Estado de ánimo del bebé',
          items: const [
            BebeSegmentedItem(
              value: 'calm',
              label: 'Tranquilo',
              icon: Icon(Icons.sentiment_satisfied_alt_outlined),
            ),
            BebeSegmentedItem(
              value: 'sleepy',
              label: 'Dormido',
              icon: Icon(Icons.bedtime_outlined),
            ),
            BebeSegmentedItem(
              value: 'irritable',
              label: 'Irritable',
              icon: Icon(Icons.sentiment_dissatisfied_outlined),
            ),
          ],
          selectedValue: mood,
          onChanged: onMoodChanged,
          allowWrap: true,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeNotesField(
          label: 'Notas',
          controller: notesController,
          onChanged: onNotesChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeNotesField(
          label: 'Síntomas / observaciones',
          controller: symptomsController,
          onChanged: onSymptomsChanged,
        ),
      ],
    );
  }
}
