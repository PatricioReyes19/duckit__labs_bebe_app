import 'package:core/core.dart';

import 'register_form_cubit.dart';

class DiaperRegisterCubit extends RegisterFormCubit {
  DiaperRegisterCubit({
    required super.saveRegisterEvent,
    required super.babyId,
    DateTime? initialDateTime,
  }) : super(
          initialValues: {
            'subtype': 'dirty',
            'occurredAt': initialDateTime ?? DateTime.now(),
            'appearance': 'normal',
            'color': 'yellow',
            'amount': 'normal',
            'notes': '',
            'symptoms': '',
          },
        );

  String get subtype => state.value<String>('subtype');
  DateTime get occurredAt => state.value<DateTime>('occurredAt');
  String get appearance => state.value<String>('appearance');
  String get color => state.value<String>('color');
  String get amount => state.value<String>('amount');
  String get notes => state.value<String>('notes');
  String get symptoms => state.value<String>('symptoms');

  void subtypeChanged(String value) => setValue('subtype', value);
  void dateChanged(DateTime value) =>
      setValue('occurredAt', replaceDate(occurredAt, value));
  void timeChanged(int hour, int minute) =>
      setValue('occurredAt', replaceTime(occurredAt, hour, minute));
  void appearanceChanged(String value) => setValue('appearance', value);
  void colorChanged(String value) => setValue('color', value);
  void amountChanged(String value) => setValue('amount', value);
  void notesChanged(String value) => setValue('notes', value);
  void symptomsChanged(String value) => setValue('symptoms', value);

  @override
  RegisterEventDraft buildDraft() {
    return RegisterEventDraft(
      babyId: babyId,
      type: RegisterEventType.diaper,
      occurredAt: occurredAt,
      notes: notes,
      details: {
        'subtype': subtype,
        'appearance': appearance,
        'color': color,
        'amount': amount,
        'symptoms': symptoms.trim(),
      },
    );
  }
}
