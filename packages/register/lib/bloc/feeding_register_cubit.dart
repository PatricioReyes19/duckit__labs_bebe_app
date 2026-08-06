import 'package:core/core.dart';

import 'register_form_cubit.dart';

class FeedingRegisterCubit extends RegisterFormCubit {
  FeedingRegisterCubit({
    required super.saveRegisterEvent,
    required super.babyId,
    DateTime? initialDateTime,
  }) : super(
          initialValues: {
            'subtype': 'breast',
            'side': 'both',
            'startedAt': initialDateTime ?? DateTime.now(),
            'durationMinutes': 15,
            'endAt': null,
            'mood': 'calm',
            'notes': '',
            'symptoms': '',
          },
        );

  String get subtype => state.value<String>('subtype');
  String get side => state.value<String>('side');
  DateTime get startedAt => state.value<DateTime>('startedAt');
  int get durationMinutes => state.value<int>('durationMinutes');
  DateTime? get endAt => state.optionalValue<DateTime>('endAt');
  String get mood => state.value<String>('mood');
  String get notes => state.value<String>('notes');
  String get symptoms => state.value<String>('symptoms');

  void subtypeChanged(String value) => setValue('subtype', value);
  void sideChanged(String value) => setValue('side', value);
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

  @override
  RegisterEventDraft buildDraft() {
    return RegisterEventDraft(
      babyId: babyId,
      type: RegisterEventType.feeding,
      occurredAt: startedAt,
      notes: notes,
      details: {
        'subtype': subtype,
        'side': side,
        'duration_minutes': durationMinutes,
        'end_at': endAt?.toUtc().toIso8601String(),
        'mood': mood,
        'symptoms': symptoms.trim(),
      },
    );
  }
}
