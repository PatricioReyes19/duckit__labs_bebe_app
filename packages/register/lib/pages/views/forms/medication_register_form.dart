import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Controlled visual form for medication records.
class MedicationRegisterForm extends StatelessWidget {
  const MedicationRegisterForm({
    this.nameController,
    this.doseController,
    this.unit = 'mL',
    this.time = '12:00 PM',
    this.frequency = 'Cada 8 horas',
    this.endDate = '',
    this.scheduleNextDoses = true,
    this.notesController,
    this.caregiver = 'mother',
    this.onNameChanged,
    this.onDoseChanged,
    this.onUnitPressed,
    this.onTimePressed,
    this.onFrequencyPressed,
    this.onEndDatePressed,
    this.onScheduleChanged,
    this.onNotesChanged,
    this.onCaregiverChanged,
    super.key,
  });

  final TextEditingController? nameController;
  final TextEditingController? doseController;
  final String unit;
  final String time;
  final String frequency;
  final String endDate;
  final bool scheduleNextDoses;
  final TextEditingController? notesController;
  final String caregiver;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onDoseChanged;
  final VoidCallback? onUnitPressed;
  final VoidCallback? onTimePressed;
  final VoidCallback? onFrequencyPressed;
  final VoidCallback? onEndDatePressed;
  final ValueChanged<bool>? onScheduleChanged;
  final ValueChanged<String>? onNotesChanged;
  final ValueChanged<String>? onCaregiverChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BebeFormField(
          label: 'Nombre del medicamento',
          child: BebeTextField(
            controller: nameController,
            hintText: 'Ej. Paracetamol',
            onChanged: onNameChanged,
            textCapitalization: TextCapitalization.sentences,
            semanticLabel: 'Nombre del medicamento',
          ),
        ),
        SizedBox(height: spacing.spacingXl),
        BebeResponsiveFormGrid(
          children: [
            BebeFormField(
              label: 'Dosis',
              child: BebeTextField(
                controller: doseController,
                hintText: 'Ej. 2,5',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: onDoseChanged,
                semanticLabel: 'Dosis',
              ),
            ),
            BebePickerField(
              label: 'Unidad',
              value: unit,
              kind: BebePickerFieldKind.selection,
              onPressed: onUnitPressed,
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
        BebePickerField(
          label: 'Frecuencia',
          value: frequency,
          kind: BebePickerFieldKind.selection,
          onPressed: onFrequencyPressed,
        ),
        SizedBox(height: spacing.spacingXl),
        BebePickerField(
          label: 'Duración o fecha de término',
          value: endDate,
          placeholder: 'Selecciona una fecha',
          optional: true,
          kind: BebePickerFieldKind.date,
          onPressed: onEndDatePressed,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeSettingsSwitchTile(
          title: 'Programar próximas dosis',
          description:
              'Te recordaremos las próximas dosis según la frecuencia seleccionada.',
          value: scheduleNextDoses,
          onChanged: onScheduleChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeNotesField(
          label: 'Notas',
          controller: notesController,
          onChanged: onNotesChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeSegmentedFormField<String>(
          label: 'Registrado por',
          items: const [
            BebeSegmentedItem(value: 'mother', label: 'Mamá'),
            BebeSegmentedItem(value: 'father', label: 'Papá'),
            BebeSegmentedItem(value: 'other', label: 'Otro cuidador'),
          ],
          selectedValue: caregiver,
          onChanged: onCaregiverChanged,
          allowWrap: true,
        ),
      ],
    );
  }
}
