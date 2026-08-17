import 'package:core/core.dart';

import 'register_form_cubit.dart';

class DiaperRegisterCubit extends RegisterFormCubit {
  DiaperRegisterCubit({
    required super.saveRegisterEvent,
    required super.babyId,
    super.persistRegisterEvent,
    RegisteredEvent? initialEvent,
    DateTime? initialDateTime,
  }) : super(
          initialValues: _initialValues(initialEvent, initialDateTime),
        );

  String get subtype => state.value<String>('subtype');
  DateTime get occurredAt => state.value<DateTime>('occurredAt');
  String get appearance => state.value<String>('appearance');
  String get color => state.value<String>('color');
  String get amount => state.value<String>('amount');
  String get urineColor => state.value<String>('urineColor');
  String get urineAmount => state.value<String>('urineAmount');
  String get notes => state.value<String>('notes');
  String get symptoms => state.value<String>('symptoms');
  bool get scheduleReminder => state.value<bool>('scheduleReminder');
  int get reminderHours => state.value<int>('reminderHours');

  void subtypeChanged(String value) => setValue('subtype', value);
  void dateChanged(DateTime value) =>
      setValue('occurredAt', replaceDate(occurredAt, value));
  void timeChanged(int hour, int minute) =>
      setValue('occurredAt', replaceTime(occurredAt, hour, minute));
  void appearanceChanged(String value) => setValue('appearance', value);
  void colorChanged(String value) => setValue('color', value);
  void amountChanged(String value) => setValue('amount', value);
  void urineColorChanged(String value) => setValue('urineColor', value);
  void urineAmountChanged(String value) => setValue('urineAmount', value);
  void notesChanged(String value) => setValue('notes', value);
  void symptomsChanged(String value) => setValue('symptoms', value);
  void scheduleReminderChanged(bool value) =>
      setValue('scheduleReminder', value);
  void reminderHoursChanged(int value) => setValue('reminderHours', value);

  @override
  RegisterEventDraft buildDraft() {
    final includesUrine = subtype == 'wet' || subtype == 'mixed';
    final includesStool = subtype == 'dirty' || subtype == 'mixed';
    return RegisterEventDraft(
      babyId: babyId,
      type: RegisterEventType.diaper,
      occurredAt: occurredAt,
      notes: notes,
      details: {
        'subtype': subtype,
        if (includesUrine) 'urine_color': urineColor,
        if (includesUrine) 'urine_amount': urineAmount,
        if (includesStool) 'appearance': appearance,
        if (includesStool) 'color': color,
        if (includesStool) 'amount': amount,
        'symptoms': symptoms.trim(),
        'schedule_reminder': scheduleReminder,
        if (scheduleReminder) 'reminder_interval_hours': reminderHours,
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
    'subtype': details['subtype'] as String? ?? 'dirty',
    'occurredAt':
        event?.occurredAt.toLocal() ?? initialDateTime ?? DateTime.now(),
    'appearance': details['appearance'] as String? ?? 'normal',
    'color': details['color'] as String? ?? 'yellow',
    'amount': details['amount'] as String? ?? 'normal',
    'urineColor': details['urine_color'] as String? ?? 'clear',
    'urineAmount': details['urine_amount'] as String? ?? 'normal',
    'notes': event?.notes ?? '',
    'symptoms': details['symptoms'] as String? ?? '',
    'scheduleReminder': details['schedule_reminder'] as bool? ?? false,
    'reminderHours': _intValue(details['reminder_interval_hours'], 3),
  };
}

int _intValue(Object? value, int fallback) => switch (value) {
      final int number => number,
      final num number => number.toInt(),
      _ => int.tryParse('$value') ?? fallback,
    };
