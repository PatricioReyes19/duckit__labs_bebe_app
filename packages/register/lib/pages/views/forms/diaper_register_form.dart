import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Controlled visual form for diaper records.
///
/// Urine and stool fields are rendered only when they apply to the selected
/// diaper subtype. This keeps the form clinically coherent and prevents
/// persisting stool characteristics for a wet-only diaper.
class DiaperRegisterForm extends StatelessWidget {
  const DiaperRegisterForm({
    this.subtype = 'dirty',
    this.date = '12 may 2024',
    this.time = '09:30 AM',
    this.appearance = 'normal',
    this.color = 'yellow',
    this.amount = 'normal',
    this.urineColor = 'clear',
    this.urineAmount = 'normal',
    this.scheduleReminder = false,
    this.reminderLabel = 'En 3 horas',
    this.notesController,
    this.symptomsController,
    this.onDatePressed,
    this.onTimePressed,
    this.onAppearanceChanged,
    this.onColorChanged,
    this.onAmountChanged,
    this.onUrineColorChanged,
    this.onUrineAmountChanged,
    this.onScheduleReminderChanged,
    this.onReminderPressed,
    this.onNotesChanged,
    this.onSymptomsChanged,
    super.key,
  });

  final String subtype;
  final String date;
  final String time;
  final String appearance;
  final String color;
  final String amount;
  final String urineColor;
  final String urineAmount;
  final bool scheduleReminder;
  final String reminderLabel;
  final TextEditingController? notesController;
  final TextEditingController? symptomsController;
  final VoidCallback? onDatePressed;
  final VoidCallback? onTimePressed;
  final ValueChanged<String>? onAppearanceChanged;
  final ValueChanged<String>? onColorChanged;
  final ValueChanged<String>? onAmountChanged;
  final ValueChanged<String>? onUrineColorChanged;
  final ValueChanged<String>? onUrineAmountChanged;
  final ValueChanged<bool>? onScheduleReminderChanged;
  final VoidCallback? onReminderPressed;
  final ValueChanged<String>? onNotesChanged;
  final ValueChanged<String>? onSymptomsChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final includesUrine = subtype == 'wet' || subtype == 'mixed';
    final includesStool = subtype == 'dirty' || subtype == 'mixed';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BebeResponsiveFormGrid(
          minimumItemWidth: 140,
          maximumColumnCount: 2,
          semanticLabel: 'Fecha y hora del cambio',
          children: [
            BebePickerField(
              compact: true,
              label: 'Fecha',
              value: date,
              kind: BebePickerFieldKind.date,
              onPressed: onDatePressed,
            ),
            BebePickerField(
              compact: true,
              label: 'Hora',
              value: time,
              kind: BebePickerFieldKind.time,
              onPressed: onTimePressed,
            ),
          ],
        ),
        if (includesUrine) ...[
          SizedBox(height: spacing.spacingXl),
          if (subtype == 'mixed') ...[
            const BebeFormLabel(label: 'Orina'),
            SizedBox(height: spacing.spacingL),
          ],
          BebeSegmentedFormField<String>(
            label: 'Cantidad de orina',
            items: const [
              BebeSegmentedItem(value: 'little', label: 'Poca'),
              BebeSegmentedItem(value: 'normal', label: 'Normal'),
              BebeSegmentedItem(value: 'much', label: 'Mucha'),
            ],
            selectedValue: urineAmount,
            onChanged: onUrineAmountChanged,
          ),
          SizedBox(height: spacing.spacingXl),
          BebeSegmentedFormField<String>(
            label: 'Color de la orina',
            items: const [
              BebeSegmentedItem(
                value: 'clear',
                label: 'Clara',
                icon: Icon(Icons.circle, size: 12, color: Color(0xFFFFE082)),
              ),
              BebeSegmentedItem(
                value: 'yellow',
                label: 'Amarilla',
                icon: Icon(Icons.circle, size: 12, color: Color(0xFFFFC928)),
              ),
              BebeSegmentedItem(
                value: 'dark',
                label: 'Oscura',
                icon: Icon(Icons.circle, size: 12, color: Color(0xFFD49524)),
              ),
            ],
            selectedValue: urineColor,
            onChanged: onUrineColorChanged,
          ),
        ],
        if (includesStool) ...[
          SizedBox(height: spacing.spacingXl),
          if (subtype == 'mixed') ...[
            const BebeFormLabel(label: 'Deposición'),
            SizedBox(height: spacing.spacingL),
          ],
          BebeSegmentedFormField<String>(
            label: 'Apariencia',
            items: const [
              BebeSegmentedItem(value: 'normal', label: 'Normal'),
              BebeSegmentedItem(value: 'soft', label: 'Blando'),
              BebeSegmentedItem(value: 'liquid', label: 'Líquido'),
            ],
            selectedValue: appearance,
            onChanged: onAppearanceChanged,
          ),
          SizedBox(height: spacing.spacingXl),
          BebeSegmentedFormField<String>(
            label: 'Color',
            items: const [
              BebeSegmentedItem(
                value: 'yellow',
                label: 'Amarillo',
                icon: Icon(Icons.circle, size: 12, color: Color(0xFFFFC928)),
              ),
              BebeSegmentedItem(
                value: 'green',
                label: 'Verde',
                icon: Icon(Icons.circle, size: 12, color: Color(0xFF56B936)),
              ),
              BebeSegmentedItem(
                value: 'brown',
                label: 'Marrón',
                icon: Icon(Icons.circle, size: 12, color: Color(0xFF8D6448)),
              ),
            ],
            selectedValue: color,
            onChanged: onColorChanged,
          ),
          SizedBox(height: spacing.spacingXl),
          BebeSegmentedFormField<String>(
            label: 'Cantidad',
            items: const [
              BebeSegmentedItem(value: 'little', label: 'Poco'),
              BebeSegmentedItem(value: 'normal', label: 'Normal'),
              BebeSegmentedItem(value: 'much', label: 'Mucho'),
            ],
            selectedValue: amount,
            onChanged: onAmountChanged,
          ),
        ],
        SizedBox(height: spacing.spacingXl),
        BebeSettingsSwitchTile(
          title: 'Recordar próximo cambio',
          description:
              'Programa una alarma para ayudarte a mantener los tiempos.',
          value: scheduleReminder,
          onChanged: onScheduleReminderChanged,
        ),
        if (scheduleReminder) ...[
          SizedBox(height: spacing.spacingL),
          BebePickerField(
            compact: true,
            label: 'Próximo recordatorio',
            value: reminderLabel,
            kind: BebePickerFieldKind.selection,
            onPressed: onReminderPressed,
          ),
        ],
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
