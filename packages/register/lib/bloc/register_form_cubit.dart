import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum RegisterSubmissionStatus { idle, saving, success, failure }

class RegisterFormState {
  RegisterFormState({
    required Map<String, Object?> values,
    this.status = RegisterSubmissionStatus.idle,
    this.message,
    this.savedEvent,
  }) : values = Map.unmodifiable(values);

  final Map<String, Object?> values;
  final RegisterSubmissionStatus status;
  final String? message;
  final RegisteredEvent? savedEvent;

  bool get isSaving => status == RegisterSubmissionStatus.saving;

  T value<T>(String key) => values[key]! as T;

  T? optionalValue<T>(String key) => values[key] as T?;

  RegisterFormState copyWith({
    Map<String, Object?>? values,
    RegisterSubmissionStatus? status,
    String? message,
    RegisteredEvent? savedEvent,
    bool clearMessage = false,
    bool clearSavedEvent = false,
  }) {
    return RegisterFormState(
      values: values ?? this.values,
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
      savedEvent: clearSavedEvent ? null : savedEvent ?? this.savedEvent,
    );
  }
}

class RegisterValidationException implements Exception {
  const RegisterValidationException(this.message);

  final String message;
}

abstract class RegisterFormCubit extends Cubit<RegisterFormState> {
  RegisterFormCubit({
    required SaveRegisterEvent saveRegisterEvent,
    required this.babyId,
    required Map<String, Object?> initialValues,
  })  : _saveRegisterEvent = saveRegisterEvent,
        super(RegisterFormState(values: initialValues));

  final SaveRegisterEvent _saveRegisterEvent;
  final String babyId;

  void setValue(String key, Object? value) {
    emit(
      state.copyWith(
        values: {...state.values, key: value},
        status: RegisterSubmissionStatus.idle,
        clearMessage: true,
        clearSavedEvent: true,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSaving) {
      return;
    }
    RegisterEventDraft draft;
    try {
      draft = buildDraft();
    } on RegisterValidationException catch (error) {
      emit(
        state.copyWith(
          status: RegisterSubmissionStatus.failure,
          message: error.message,
          clearSavedEvent: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: RegisterSubmissionStatus.saving,
        clearMessage: true,
        clearSavedEvent: true,
      ),
    );
    try {
      final saved = await _saveRegisterEvent(draft);
      emit(
        state.copyWith(
          status: RegisterSubmissionStatus.success,
          savedEvent: saved,
          clearMessage: true,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: RegisterSubmissionStatus.failure,
          message: 'No pudimos guardar el registro. Inténtalo nuevamente.',
          clearSavedEvent: true,
        ),
      );
    }
  }

  RegisterEventDraft buildDraft();

  DateTime replaceDate(DateTime current, DateTime date) => DateTime(
        date.year,
        date.month,
        date.day,
        current.hour,
        current.minute,
      );

  DateTime replaceTime(DateTime current, int hour, int minute) =>
      DateTime(current.year, current.month, current.day, hour, minute);
}
