import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Controlled visual form for feeding records.
class FeedingRegisterForm extends StatelessWidget {
  const FeedingRegisterForm({
    this.subtype = 'breast',
    this.side = 'both',
    this.amountController,
    this.startTime = '09:30 AM',
    this.duration = '15 min',
    this.endTime = '',
    this.scheduleNextFeeding = false,
    this.reminderLabel = 'En 4 horas',
    this.mood = 'calm',
    this.notesController,
    this.symptomsController,
    this.onSideChanged,
    this.onAmountChanged,
    this.onStartTimePressed,
    this.onDurationPressed,
    this.onEndTimePressed,
    this.onScheduleNextFeedingChanged,
    this.onReminderPressed,
    this.onMoodChanged,
    this.onNotesChanged,
    this.onSymptomsChanged,
    super.key,
  });

  final String subtype;
  final String side;
  final TextEditingController? amountController;
  final String startTime;
  final String duration;
  final String endTime;
  final bool scheduleNextFeeding;
  final String reminderLabel;
  final String mood;
  final TextEditingController? notesController;
  final TextEditingController? symptomsController;
  final ValueChanged<String>? onSideChanged;
  final ValueChanged<String>? onAmountChanged;
  final VoidCallback? onStartTimePressed;
  final VoidCallback? onDurationPressed;
  final VoidCallback? onEndTimePressed;
  final ValueChanged<bool>? onScheduleNextFeedingChanged;
  final VoidCallback? onReminderPressed;
  final ValueChanged<String>? onMoodChanged;
  final ValueChanged<String>? onNotesChanged;
  final ValueChanged<String>? onSymptomsChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final isBreastfeeding = subtype == 'breast';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isBreastfeeding)
          BebeSegmentedFormField<String>(
            label: 'Lado',
            items: const [
              BebeSegmentedItem(value: 'left', label: 'Izquierdo'),
              BebeSegmentedItem(value: 'right', label: 'Derecho'),
              BebeSegmentedItem(value: 'both', label: 'Ambos'),
            ],
            selectedValue: side,
            onChanged: onSideChanged,
          )
        else
          BebeFormField(
            label: 'Cantidad (mL)',
            child: BebeTextField(
              controller: amountController,
              hintText: 'Ej. 90',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              trailing: const _MillilitersLabel(),
              onChanged: onAmountChanged,
              semanticLabel: 'Cantidad tomada en mililitros',
            ),
          ),
        SizedBox(height: spacing.spacingXl),
        BebeResponsiveFormGrid(
          minimumItemWidth: 96,
          semanticLabel: 'Horario de la alimentación',
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
              placeholder: '--:-- --',
              optional: true,
              kind: BebePickerFieldKind.time,
              onPressed: onEndTimePressed,
            ),
          ],
        ),
        if (!isBreastfeeding) ...[
          SizedBox(height: spacing.spacingXl),
          BebeSettingsSwitchTile(
            title: 'Programar próxima toma',
            description:
                'Activa una alarma para la próxima mamadera o fórmula.',
            value: scheduleNextFeeding,
            onChanged: onScheduleNextFeedingChanged,
          ),
          if (scheduleNextFeeding) ...[
            SizedBox(height: spacing.spacingL),
            BebePickerField(
              compact: true,
              label: 'Recordar próxima toma',
              value: reminderLabel,
              kind: BebePickerFieldKind.selection,
              onPressed: onReminderPressed,
            ),
          ],
        ],
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

class _MillilitersLabel extends StatelessWidget {
  const _MillilitersLabel();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      widthFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(right: theme.spacing.spacingXl),
        child: Text(
          'mL',
          style: theme.typography.styles.title.sm.semibold.copyWith(
            color: theme.colors.text.neutralTitle,
          ),
        ),
      ),
    );
  }
}
