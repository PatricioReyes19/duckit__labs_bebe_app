import 'package:core/core.dart';

import 'register_form_cubit.dart';

class SleepRegisterCubit extends RegisterFormCubit {
  SleepRegisterCubit({
    required super.saveRegisterEvent,
    required super.babyId,
    DateTime? initialDateTime,
  }) : super(
          initialValues: {
            'subtype': 'nap',
            'startedAt': initialDateTime ?? DateTime.now(),
            'durationMinutes': 60,
            'endAt': null,
            'place': 'crib',
            'mood': 'calm',
            'notes': '',
            'symptoms': '',
          },
        );

  String get subtype => state.value<String>('subtype');
  DateTime get startedAt => state.value<DateTime>('startedAt');
  int get durationMinutes => state.value<int>('durationMinutes');
  DateTime? get endAt => state.optionalValue<DateTime>('endAt');
  String get place => state.value<String>('place');
  String get mood => state.value<String>('mood');
  String get notes => state.value<String>('notes');
  String get symptoms => state.value<String>('symptoms');

  void subtypeChanged(String value) => setValue('subtype', value);
  void timeChanged(int hour, int minute) =>
      setValue('startedAt', replaceTime(startedAt, hour, minute));
  void durationChanged(int value) => setValue('durationMinutes', value);
  void endTimeChanged(int hour, int minute) => setValue(
        'endAt',
        replaceTime(endAt ?? startedAt.add(Duration(minutes: durationMinutes)),
            hour, minute),
      );
  void placeChanged(String value) => setValue('place', value);
  void moodChanged(String value) => setValue('mood', value);
  void notesChanged(String value) => setValue('notes', value);
  void symptomsChanged(String value) => setValue('symptoms', value);

  @override
  RegisterEventDraft buildDraft() {
    return RegisterEventDraft(
      babyId: babyId,
      type: RegisterEventType.sleep,
      occurredAt: startedAt,
      notes: notes,
      details: {
        'subtype': subtype,
        'duration_minutes': durationMinutes,
        'end_at': endAt?.toUtc().toIso8601String(),
        'place': place,
        'mood': mood,
        'symptoms': symptoms.trim(),
      },
    );
  }
}
