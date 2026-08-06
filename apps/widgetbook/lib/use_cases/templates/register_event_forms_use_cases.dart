import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:register/register.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Alimentación',
  type: FeedingRegisterForm,
  path: '[Templates]/Registro',
)
Widget feedingRegisterUseCase(BuildContext context) {
  return _preview(
    kind: RegisterEventKind.feeding,
    subcategories: const [
      BebeSegmentedItem(value: 'breast', label: 'Pecho'),
      BebeSegmentedItem(value: 'bottle', label: 'Mamadera'),
      BebeSegmentedItem(value: 'expressed', label: 'Leche extraída'),
      BebeSegmentedItem(value: 'formula', label: 'Fórmula'),
    ],
    selectedSubcategory: 'breast',
    contextTitle: 'Última toma hace 2 h 10 min',
    contextDescription: 'Sugerido cada 2–3 horas',
    form: FeedingRegisterForm(
      onSideChanged: (_) {},
      onStartTimePressed: () {},
      onDurationPressed: () {},
      onEndTimePressed: () {},
      onMoodChanged: (_) {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Sueño',
  type: SleepRegisterForm,
  path: '[Templates]/Registro',
)
Widget sleepRegisterUseCase(BuildContext context) {
  return _preview(
    kind: RegisterEventKind.sleep,
    subcategories: const [
      BebeSegmentedItem(value: 'nap', label: 'Siesta'),
      BebeSegmentedItem(value: 'night', label: 'Sueño nocturno'),
      BebeSegmentedItem(value: 'timer', label: 'Temporizador'),
    ],
    selectedSubcategory: 'nap',
    contextTitle: 'Último sueño hace 3 h 20 min',
    contextDescription: 'Promedio de siesta: 1 h 10 min',
    form: SleepRegisterForm(
      onStartTimePressed: () {},
      onDurationPressed: () {},
      onEndTimePressed: () {},
      onPlaceChanged: (_) {},
      onMoodChanged: (_) {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Pañal',
  type: DiaperRegisterForm,
  path: '[Templates]/Registro',
)
Widget diaperRegisterUseCase(BuildContext context) {
  return _preview(
    kind: RegisterEventKind.diaper,
    subcategories: const [
      BebeSegmentedItem(value: 'wet', label: 'Mojado'),
      BebeSegmentedItem(value: 'dirty', label: 'Sucio'),
      BebeSegmentedItem(value: 'mixed', label: 'Mixto'),
    ],
    selectedSubcategory: 'dirty',
    contextTitle: 'Último cambio hace 45 min',
    contextDescription: 'Promedio de cambios hoy: 6',
    form: DiaperRegisterForm(
      onDatePressed: () {},
      onTimePressed: () {},
      onAppearanceChanged: (_) {},
      onColorChanged: (_) {},
      onAmountChanged: (_) {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Observación clínica',
  type: ClinicalObservationRegisterForm,
  path: '[Templates]/Registro',
)
Widget clinicalObservationRegisterUseCase(BuildContext context) {
  return RegisterEventView(
    title: 'Nueva observación clínica',
    selectedKind: RegisterEventKind.observation,
    onKindChanged: (_) {},
    showEventContext: false,
    form: ClinicalObservationRegisterForm(
      onObservationTypeChanged: (_) {},
      onDatePressed: () {},
      onTimePressed: () {},
      onAddPhotoPressed: () {},
      onSeverityChanged: (_) {},
      onShareChanged: (_) {},
      onCaregiverChanged: (_) {},
    ),
    onBackPressed: () {},
    onSavePressed: () {},
    onCancelPressed: () {},
  );
}

@widgetbook.UseCase(
  name: 'Medicamento',
  type: MedicationRegisterForm,
  path: '[Templates]/Registro',
)
Widget medicationRegisterUseCase(BuildContext context) {
  return _preview(
    kind: RegisterEventKind.medication,
    subcategories: const [
      BebeSegmentedItem(value: 'medicine', label: 'Medicamento'),
      BebeSegmentedItem(value: 'supplement', label: 'Suplemento'),
      BebeSegmentedItem(value: 'vitamin', label: 'Vitamina'),
    ],
    selectedSubcategory: 'medicine',
    contextTitle: 'Próxima dosis en 3 h',
    contextDescription: 'Última administración hoy 08:00',
    form: MedicationRegisterForm(
      onUnitPressed: () {},
      onTimePressed: () {},
      onFrequencyPressed: () {},
      onEndDatePressed: () {},
      onScheduleChanged: (_) {},
      onCaregiverChanged: (_) {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Medición',
  type: MeasurementRegisterForm,
  path: '[Templates]/Registro',
)
Widget measurementRegisterUseCase(BuildContext context) {
  return _preview(
    kind: RegisterEventKind.measurement,
    subcategories: const [
      BebeSegmentedItem(value: 'weight', label: 'Peso'),
      BebeSegmentedItem(value: 'height', label: 'Talla'),
      BebeSegmentedItem(value: 'head', label: 'Perímetro cefálico'),
    ],
    selectedSubcategory: 'weight',
    contextTitle: 'Último peso registrado: 5,8 kg',
    contextDescription: 'Hace 7 días',
    form: MeasurementRegisterForm(
      onDatePressed: () {},
      onTimePressed: () {},
      onSourceChanged: (_) {},
      onGrowthPressed: () {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Template responsive',
  type: BebeRegisterEventTemplate,
  path: '[Templates]/Registro',
)
Widget registerEventTemplateUseCase(BuildContext context) =>
    feedingRegisterUseCase(context);

@widgetbook.UseCase(
  name: 'Shell controlado',
  type: RegisterEventView,
  path: '[Templates]/Registro',
)
Widget registerEventViewUseCase(BuildContext context) =>
    measurementRegisterUseCase(context);

RegisterEventView _preview({
  required RegisterEventKind kind,
  required List<BebeSegmentedItem<String>> subcategories,
  required String selectedSubcategory,
  required String contextTitle,
  required String contextDescription,
  required Widget form,
}) {
  return RegisterEventView(
    title: 'Registrar evento',
    selectedKind: kind,
    onKindChanged: (_) {},
    subcategories: subcategories,
    selectedSubcategory: selectedSubcategory,
    onSubcategoryChanged: (_) {},
    contextTitle: contextTitle,
    contextDescription: contextDescription,
    contextTrailing: const Icon(Icons.info_outline_rounded),
    form: form,
    onBackPressed: () {},
    onNotificationsPressed: () {},
    onBabyPressed: () {},
    onSavePressed: () {},
    onCancelPressed: () {},
  );
}
