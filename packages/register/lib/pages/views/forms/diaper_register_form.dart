import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Controlled visual form for diaper records.
class DiaperRegisterForm extends StatelessWidget {
  const DiaperRegisterForm({
    this.date = '12 may 2024',
    this.time = '09:30 AM',
    this.appearance = 'normal',
    this.color = 'yellow',
    this.amount = 'normal',
    this.notesController,
    this.symptomsController,
    this.onDatePressed,
    this.onTimePressed,
    this.onAppearanceChanged,
    this.onColorChanged,
    this.onAmountChanged,
    this.onNotesChanged,
    this.onSymptomsChanged,
    super.key,
  });

  final String date;
  final String time;
  final String appearance;
  final String color;
  final String amount;
  final TextEditingController? notesController;
  final TextEditingController? symptomsController;
  final VoidCallback? onDatePressed;
  final VoidCallback? onTimePressed;
  final ValueChanged<String>? onAppearanceChanged;
  final ValueChanged<String>? onColorChanged;
  final ValueChanged<String>? onAmountChanged;
  final ValueChanged<String>? onNotesChanged;
  final ValueChanged<String>? onSymptomsChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BebeResponsiveFormGrid(
          maximumColumnCount: 2,
          semanticLabel: 'Fecha y hora del cambio',
          children: [
            BebePickerField(
              label: 'Fecha',
              value: date,
              kind: BebePickerFieldKind.date,
              onPressed: onDatePressed,
            ),
            BebePickerField(
              label: 'Hora',
              value: time,
              kind: BebePickerFieldKind.time,
              onPressed: onTimePressed,
            ),
          ],
        ),
        SizedBox(height: spacing.spacingXl),
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
            BebeSegmentedItem(value: 'yellow', label: 'Amarillo'),
            BebeSegmentedItem(value: 'green', label: 'Verde'),
            BebeSegmentedItem(value: 'brown', label: 'Marrón'),
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
