import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class MeasurementRegisterForm extends StatelessWidget {
  const MeasurementRegisterForm({
    this.measurementType = 'weight',
    this.valueController,
    this.unit = 'kg',
    this.date = '20 may 2024',
    this.time = '09:30 AM',
    this.source = 'home',
    this.notesController,
    this.onValueChanged,
    this.onDatePressed,
    this.onTimePressed,
    this.onSourceChanged,
    this.onNotesChanged,
    this.onGrowthPressed,
    super.key,
  });

  final String measurementType;
  final TextEditingController? valueController;
  final String unit;
  final String date;
  final String time;
  final String source;
  final TextEditingController? notesController;
  final ValueChanged<String>? onValueChanged;
  final VoidCallback? onDatePressed;
  final VoidCallback? onTimePressed;
  final ValueChanged<String>? onSourceChanged;
  final ValueChanged<String>? onNotesChanged;
  final VoidCallback? onGrowthPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final measurementLabel = switch (measurementType) {
      'height' => 'Talla',
      'head' => 'Perímetro cefálico',
      _ => 'Peso',
    };
    final example = measurementType == 'weight' ? 'Ej. 5,9' : 'Ej. 58,5';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BebeFormField(
          label: '$measurementLabel ($unit)',
          child: BebeTextField(
            controller: valueController,
            hintText: example,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            trailing: _UnitLabel(unit: unit),
            onChanged: onValueChanged,
            semanticLabel: 'Valor de la medición en $unit',
          ),
        ),
        SizedBox(height: spacing.spacingXl),
        BebeResponsiveFormGrid(
          minimumItemWidth: 140,
          maximumColumnCount: 2,
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
        SizedBox(height: spacing.spacingXl),
        BebeSegmentedFormField<String>(
          label: 'Fuente',
          optional: true,
          items: const [
            BebeSegmentedItem(
              value: 'home',
              label: 'En casa',
              icon: Icon(Icons.home_outlined),
            ),
            BebeSegmentedItem(
              value: 'clinic',
              label: 'Consulta',
              icon: Icon(Icons.medical_services_outlined),
            ),
          ],
          selectedValue: source,
          onChanged: onSourceChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeNotesField(
          compact: true,
          label: 'Notas',
          controller: notesController,
          onChanged: onNotesChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeStatusBanner(
          title: 'Se añadirá al módulo de Crecimiento',
          type: BebeStatusBannerType.information,
          leading: const Icon(Icons.show_chart_rounded),
          trailing: const Icon(Icons.chevron_right_rounded),
          compact: true,
          onPressed: onGrowthPressed,
        ),
      ],
    );
  }
}

class _UnitLabel extends StatelessWidget {
  const _UnitLabel({required this.unit});

  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      widthFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(right: theme.spacing.spacingXl),
        child: Text(
          unit,
          style: theme.typography.styles.title.sm.semibold.copyWith(
            color: theme.colors.text.neutralTitle,
          ),
        ),
      ),
    );
  }
}
