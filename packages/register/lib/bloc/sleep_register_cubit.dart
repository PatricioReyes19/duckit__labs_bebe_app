import 'package:core/core.dart';

import 'register_form_cubit.dart';

typedef SleepRegisterClock = DateTime Function();

enum SleepRegisterMode { ongoing, completed }

DateTime _atMinutePrecision(DateTime value) =>
    DateTime(value.year, value.month, value.day, value.hour, value.minute);

class SleepRegisterCubit extends RegisterFormCubit {
  SleepRegisterCubit({
    required super.saveRegisterEvent,
    required super.babyId,
    DateTime? initialDateTime,
    SleepRegisterClock? clock,
  })  : _clock = clock ?? DateTime.now,
        super(
          initialValues: {
            'mode': SleepRegisterMode.ongoing.name,
            'subtype': 'nap',
            'startedAt': _atMinutePrecision(
              initialDateTime ?? (clock ?? DateTime.now)(),
            ),
            'durationMinutes': 60,
            'endAt': null,
            'place': 'crib',
            'mood': 'calm',
            'notes': '',
            'symptoms': '',
          },
        );

  final SleepRegisterClock _clock;

  SleepRegisterMode get mode => SleepRegisterMode.values.byName(
        state.value<String>('mode'),
      );
  bool get isOngoing => mode == SleepRegisterMode.ongoing;
  String get subtype => state.value<String>('subtype');
  DateTime get startedAt => state.value<DateTime>('startedAt');
  int get durationMinutes => state.value<int>('durationMinutes');
  DateTime? get endAt => state.optionalValue<DateTime>('endAt');
  String get place => state.value<String>('place');
  String get mood => state.value<String>('mood');
  String get notes => state.value<String>('notes');
  String get symptoms => state.value<String>('symptoms');

  void modeChanged(String value) {
    final next = SleepRegisterMode.values.where((mode) => mode.name == value);
    if (next.isEmpty || next.first == mode) return;
    setValue('mode', value);
    if (next.first == SleepRegisterMode.ongoing) {
      setValue('endAt', null);
    } else {
      setValue(
        'endAt',
        startedAt.add(Duration(minutes: durationMinutes)),
      );
    }
  }

  void subtypeChanged(String value) => setValue('subtype', value);
  void timeChanged(int hour, int minute) {
    final updated = replaceTime(startedAt, hour, minute);
    setValue('startedAt', updated);
    if (!isOngoing) {
      setValue('endAt', updated.add(Duration(minutes: durationMinutes)));
    }
  }

  void durationChanged(int value) {
    setValue('durationMinutes', value);
    if (!isOngoing) {
      setValue('endAt', startedAt.add(Duration(minutes: value)));
    }
  }

  void endTimeChanged(int hour, int minute) {
    var updated = replaceTime(startedAt, hour, minute);
    if (!updated.isAfter(startedAt)) {
      updated = updated.add(const Duration(days: 1));
    }
    setValue('endAt', updated);
    setValue('durationMinutes', updated.difference(startedAt).inMinutes);
  }

  void placeChanged(String value) => setValue('place', value);
  void moodChanged(String value) => setValue('mood', value);
  void notesChanged(String value) => setValue('notes', value);
  void symptomsChanged(String value) => setValue('symptoms', value);

  @override
  RegisterEventDraft buildDraft() {
    if (startedAt.isAfter(_clock().add(const Duration(minutes: 1)))) {
      throw const RegisterValidationException(
        'La hora de inicio no puede estar en el futuro.',
      );
    }
    final ongoing = isOngoing;
    final resolvedEndAt = ongoing
        ? null
        : endAt ?? startedAt.add(Duration(minutes: durationMinutes));
    final resolvedDuration =
        ongoing ? null : resolvedEndAt!.difference(startedAt).inMinutes;
    if (!ongoing && resolvedDuration! <= 0) {
      throw const RegisterValidationException(
        'La hora de despertar debe ser posterior al inicio.',
      );
    }
    return RegisterEventDraft(
      babyId: babyId,
      type: RegisterEventType.sleep,
      occurredAt: startedAt,
      notes: notes,
      details: {
        'sleep_status': ongoing ? 'ongoing' : 'completed',
        'subtype': subtype,
        'duration_minutes': resolvedDuration,
        'end_at': resolvedEndAt?.toUtc().toIso8601String(),
        'place': place,
        if (!ongoing) 'mood': mood,
        'symptoms': symptoms.trim(),
      },
    );
  }
}
