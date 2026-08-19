import 'package:core/core.dart';

import 'register_form_cubit.dart';

class FeedingRegisterCubit extends RegisterFormCubit {
  FeedingRegisterCubit({
    required super.saveRegisterEvent,
    required super.babyId,
    super.persistRegisterEvent,
    RegisteredEvent? initialEvent,
    DateTime? initialDateTime,
  }) : super(
          initialValues: _initialValues(initialEvent, initialDateTime),
        );

  String get subtype => state.value<String>('subtype');
  String get side => state.value<String>('side');
  String get amountMl => state.value<String>('amountMl');
  DateTime get startedAt => state.value<DateTime>('startedAt');
  int get durationMinutes => state.value<int>('durationMinutes');
  DateTime? get endAt => state.optionalValue<DateTime>('endAt');
  String get mood => state.value<String>('mood');
  String get notes => state.value<String>('notes');
  String get symptoms => state.value<String>('symptoms');
  bool get scheduleNextFeeding => state.value<bool>('scheduleNextFeeding');
  int get reminderHours => state.value<int>('reminderHours');

  void subtypeChanged(String value) => setValue('subtype', value);

  void sideChanged(String value) => setValue('side', value);
  void amountMlChanged(String value) => setValue('amountMl', value);
  void dateChanged(DateTime value) =>
      setValue('startedAt', replaceDate(startedAt, value));
  void timeChanged(int hour, int minute) =>
      setValue('startedAt', replaceTime(startedAt, hour, minute));
  void durationChanged(int value) => setValue('durationMinutes', value);
  void endTimeChanged(int hour, int minute) => setValue(
        'endAt',
        replaceTime(endAt ?? startedAt.add(Duration(minutes: durationMinutes)),
            hour, minute),
      );
  void moodChanged(String value) => setValue('mood', value);
  void notesChanged(String value) => setValue('notes', value);
  void symptomsChanged(String value) => setValue('symptoms', value);
  void scheduleNextFeedingChanged(bool value) =>
      setValue('scheduleNextFeeding', value);
  void reminderHoursChanged(int value) => setValue('reminderHours', value);

  @override
  RegisterEventDraft buildDraft() {
    final numericAmount = subtype == 'breast'
        ? null
        : double.tryParse(amountMl.trim().replaceAll(',', '.'));
    if (subtype != 'breast' && (numericAmount == null || numericAmount <= 0)) {
      throw const RegisterValidationException(
        'Ingresa la cantidad tomada en mL.',
      );
    }

    return RegisterEventDraft(
      babyId: babyId,
      type: RegisterEventType.feeding,
      occurredAt: startedAt,
      notes: notes,
      details: {
        'subtype': subtype,
        if (subtype == 'breast') 'side': side,
        if (numericAmount != null) 'amount_ml': numericAmount,
        'duration_minutes': durationMinutes,
        'end_at': endAt?.toUtc().toIso8601String(),
        'mood': mood,
        'symptoms': symptoms.trim(),
        'schedule_next_feeding': scheduleNextFeeding,
        if (scheduleNextFeeding) 'reminder_interval_hours': reminderHours,
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
    'subtype': details['subtype'] as String? ?? 'breast',
    'side': details['side'] as String? ?? 'both',
    'amountMl': details['amount_ml']?.toString() ?? '',
    'startedAt':
        event?.occurredAt.toLocal() ?? initialDateTime ?? DateTime.now(),
    'durationMinutes': _intValue(details['duration_minutes'], 15),
    'endAt': event?.endedAt?.toLocal(),
    'mood': details['mood'] as String? ?? 'calm',
    'notes': event?.notes ?? '',
    'symptoms': details['symptoms'] as String? ?? '',
    'scheduleNextFeeding': details['schedule_next_feeding'] as bool? ?? false,
    'reminderHours': _intValue(details['reminder_interval_hours'], 4),
  };
}

int _intValue(Object? value, int fallback) => switch (value) {
      final int number => number,
      final num number => number.toInt(),
      _ => int.tryParse('$value') ?? fallback,
    };
