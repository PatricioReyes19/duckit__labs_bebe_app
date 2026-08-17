import 'package:core/core.dart';

import 'register_form_cubit.dart';

class MeasurementRegisterCubit extends RegisterFormCubit {
  MeasurementRegisterCubit({
    required super.saveRegisterEvent,
    required super.babyId,
    super.persistRegisterEvent,
    RegisteredEvent? initialEvent,
    DateTime? initialDateTime,
  }) : super(
          initialValues: _initialValues(initialEvent, initialDateTime),
        );

  String get measurementType => state.value<String>('measurementType');
  String get value => state.value<String>('value');
  String get unit => measurementType == 'weight' ? 'kg' : 'cm';
  DateTime get occurredAt => state.value<DateTime>('occurredAt');
  String get source => state.value<String>('source');
  String get notes => state.value<String>('notes');

  void measurementTypeChanged(String value) =>
      setValue('measurementType', value);
  void valueChanged(String value) => setValue('value', value);
  void dateChanged(DateTime value) =>
      setValue('occurredAt', replaceDate(occurredAt, value));
  void timeChanged(int hour, int minute) =>
      setValue('occurredAt', replaceTime(occurredAt, hour, minute));
  void sourceChanged(String value) => setValue('source', value);
  void notesChanged(String value) => setValue('notes', value);

  @override
  RegisterEventDraft buildDraft() {
    final numericValue = double.tryParse(value.trim().replaceAll(',', '.'));
    if (numericValue == null || numericValue <= 0) {
      throw const RegisterValidationException(
        'Ingresa una medición válida.',
      );
    }
    return RegisterEventDraft(
      babyId: babyId,
      type: RegisterEventType.measurement,
      occurredAt: occurredAt,
      notes: notes,
      details: {
        'measurement_type': measurementType,
        'value': numericValue,
        'unit': unit,
        'source': source,
      },
    );
  }
}

Map<String, Object?> _initialValues(
  RegisteredEvent? event,
  DateTime? initialDateTime,
) {
  final details = event?.details ?? const <String, Object?>{};
  return {
    'measurementType': details['measurement_type'] as String? ?? 'weight',
    'value': details['value']?.toString() ?? '',
    'occurredAt':
        event?.occurredAt.toLocal() ?? initialDateTime ?? DateTime.now(),
    'source': details['source'] as String? ?? 'home',
    'notes': event?.notes ?? '',
  };
}
