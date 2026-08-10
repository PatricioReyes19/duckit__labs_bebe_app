import 'package:core/core.dart';

import 'register_form_cubit.dart';

class MedicationRegisterCubit extends RegisterFormCubit {
  MedicationRegisterCubit({
    required super.saveRegisterEvent,
    required super.babyId,
    DateTime? initialDateTime,
  }) : super(
          initialValues: {
            'subtype': 'medication',
            'name': '',
            'dose': '',
            'unit': 'mL',
            'occurredAt': initialDateTime ?? DateTime.now(),
            'frequency': RegisterCatalog.medicationFrequencies[3],
            'endDate': null,
            'scheduleNextDoses': true,
            'notes': '',
            'caregiver': 'mother',
          },
        );

  String get subtype => state.value<String>('subtype');
  String get name => state.value<String>('name');
  String get dose => state.value<String>('dose');
  String get unit => state.value<String>('unit');
  DateTime get occurredAt => state.value<DateTime>('occurredAt');
  String get frequency => state.value<String>('frequency');
  DateTime? get endDate => state.optionalValue<DateTime>('endDate');
  bool get scheduleNextDoses => state.value<bool>('scheduleNextDoses');
  String get notes => state.value<String>('notes');
  String get caregiver => state.value<String>('caregiver');

  void subtypeChanged(String value) => setValue('subtype', value);
  void nameChanged(String value) => setValue('name', value);
  void doseChanged(String value) => setValue('dose', value);
  void unitChanged(String value) => setValue('unit', value);
  void timeChanged(int hour, int minute) =>
      setValue('occurredAt', replaceTime(occurredAt, hour, minute));
  void frequencyChanged(String value) => setValue('frequency', value);
  void endDateChanged(DateTime? value) => setValue('endDate', value);
  void scheduleChanged(bool value) => setValue('scheduleNextDoses', value);
  void notesChanged(String value) => setValue('notes', value);
  void caregiverChanged(String value) => setValue('caregiver', value);

  @override
  RegisterEventDraft buildDraft() {
    final normalizedName = name.trim();
    final numericDose = double.tryParse(dose.trim().replaceAll(',', '.'));
    if (normalizedName.isEmpty) {
      final itemLabel = switch (subtype) {
        'supplement' => 'suplemento',
        'vitamin' => 'vitamina',
        _ => 'medicamento',
      };
      throw RegisterValidationException(
        'Ingresa el nombre del $itemLabel.',
      );
    }
    if (numericDose == null || numericDose <= 0) {
      throw const RegisterValidationException('Ingresa una dosis válida.');
    }
    return RegisterEventDraft(
      babyId: babyId,
      type: RegisterEventType.medication,
      occurredAt: occurredAt,
      caregiverId: caregiver,
      notes: notes,
      details: {
        'subtype': subtype,
        'name': normalizedName,
        'dose': numericDose,
        'unit': unit,
        'frequency': frequency,
        'end_date': endDate?.toUtc().toIso8601String(),
        'schedule_next_doses': scheduleNextDoses,
      },
    );
  }
}
