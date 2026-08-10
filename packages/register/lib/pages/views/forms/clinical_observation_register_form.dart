import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class ClinicalObservationRegisterForm extends StatelessWidget {
  const ClinicalObservationRegisterForm({
    this.observationType = 'stool',
    this.date = '16 de mayo de 2025',
    this.time = '10:35 AM',
    this.descriptionController,
    this.photos = const [],
    this.severity = 'mild',
    this.shareWithPediatrician = true,
    this.caregiver = 'father',
    this.onObservationTypeChanged,
    this.onDatePressed,
    this.onTimePressed,
    this.onDescriptionChanged,
    this.onAddPhotoPressed,
    this.onRemovePhotoPressed,
    this.onSeverityChanged,
    this.onShareChanged,
    this.onCaregiverChanged,
    super.key,
  });

  final String observationType;
  final String date;
  final String time;
  final TextEditingController? descriptionController;
  final List<BebePhotoItem> photos;
  final String severity;
  final bool shareWithPediatrician;
  final String caregiver;
  final ValueChanged<String>? onObservationTypeChanged;
  final VoidCallback? onDatePressed;
  final VoidCallback? onTimePressed;
  final ValueChanged<String>? onDescriptionChanged;
  final VoidCallback? onAddPhotoPressed;
  final ValueChanged<String>? onRemovePhotoPressed;
  final ValueChanged<String>? onSeverityChanged;
  final ValueChanged<bool>? onShareChanged;
  final ValueChanged<String>? onCaregiverChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BebeFormLabel(label: 'Tipo de observación'),
        SizedBox(height: spacing.spacingM),
        FeatureActionGrid(
          minimumItemWidth: 100,
          maximumColumnCount: 3,
          semanticLabel: 'Tipos de observación clínica',
          children: [
            _ObservationType(
              value: 'stool',
              label: 'Heces',
              icon: Icons.water_drop_outlined,
              selectedValue: observationType,
              onChanged: onObservationTypeChanged,
            ),
            _ObservationType(
              value: 'skin',
              label: 'Alergia / piel',
              icon: Icons.back_hand_outlined,
              selectedValue: observationType,
              onChanged: onObservationTypeChanged,
            ),
            _ObservationType(
              value: 'reflux',
              label: 'Vómito / reflujo',
              icon: Icons.sick_outlined,
              selectedValue: observationType,
              onChanged: onObservationTypeChanged,
            ),
            _ObservationType(
              value: 'fever',
              label: 'Fiebre / síntomas',
              icon: Icons.thermostat_outlined,
              selectedValue: observationType,
              onChanged: onObservationTypeChanged,
            ),
            _ObservationType(
              value: 'respiratory',
              label: 'Respiratorio',
              icon: Icons.air_rounded,
              selectedValue: observationType,
              onChanged: onObservationTypeChanged,
            ),
            _ObservationType(
              value: 'other',
              label: 'Otro',
              icon: Icons.more_horiz_rounded,
              selectedValue: observationType,
              onChanged: onObservationTypeChanged,
            ),
          ],
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
        BebeNotesField(
          label: 'Descripción de la observación',
          controller: descriptionController,
          optional: false,
          maxLength: 500,
          onChanged: onDescriptionChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        BebePhotoPicker(
          label: 'Fotos',
          items: photos,
          onAddPressed: onAddPhotoPressed,
          onRemovePressed: onRemovePhotoPressed,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeSegmentedFormField<String>(
          label: 'Gravedad',
          items: const [
            BebeSegmentedItem(value: 'mild', label: 'Leve'),
            BebeSegmentedItem(value: 'moderate', label: 'Moderada'),
            BebeSegmentedItem(value: 'high', label: 'Alta'),
          ],
          selectedValue: severity,
          onChanged: onSeverityChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeSettingsSwitchTile(
          title: 'Compartir con pediatra',
          value: shareWithPediatrician,
          onChanged: onShareChanged,
        ),
        SizedBox(height: spacing.spacingXl),
        BebeSegmentedFormField<String>(
          label: 'Registrado por',
          items: const [
            BebeSegmentedItem(value: 'father', label: 'Papá'),
            BebeSegmentedItem(value: 'mother', label: 'Mamá'),
          ],
          selectedValue: caregiver,
          onChanged: onCaregiverChanged,
        ),
      ],
    );
  }
}

class _ObservationType extends StatelessWidget {
  const _ObservationType({
    required this.value,
    required this.label,
    required this.icon,
    required this.selectedValue,
    required this.onChanged,
  });

  final String value;
  final String label;
  final IconData icon;
  final String selectedValue;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return BebeCategoryActionTile(
      variant: BebeCategoryActionTileVariant.observation,
      label: label,
      icon: Icon(icon),
      compact: true,
      isSelected: selectedValue == value,
      onPressed: onChanged == null ? null : () => onChanged!(value),
    );
  }
}
