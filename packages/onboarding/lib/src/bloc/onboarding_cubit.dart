import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/onboarding_repository.dart';
import '../models/models.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required OnboardingRepository repository,
    OnboardingEntry entry = OnboardingEntry.choice,
  })  : _repository = repository,
        super(OnboardingState.initial(entry));

  final OnboardingRepository _repository;

  void createBabySelected() {
    emit(state.copyWith(step: OnboardingStep.babyProfile));
  }

  void invitationSelected() {
    emit(state.copyWith(step: OnboardingStep.invitationCode));
  }

  void backToChoice() {
    emit(
      OnboardingState.initial(OnboardingEntry.choice).copyWith(
        invitationCode: state.invitationCode,
      ),
    );
  }

  void invitationCodeChanged(String value) {
    emit(
      state.copyWith(
        invitationCode: value.toUpperCase(),
        clearInvitationCodeError: true,
        clearMessage: true,
      ),
    );
  }

  Future<void> invitationSubmitted() async {
    final code = state.invitationCode.trim();
    if (code.length < 5) {
      emit(
        state.copyWith(
          invitationCodeError: 'Ingresa el código completo de la invitación.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: OnboardingActionStatus.loading,
        clearInvitationCodeError: true,
        clearMessage: true,
        clearInvitation: true,
        clearInvitationFailure: true,
      ),
    );
    try {
      final result = await _repository.findInvitation(code);
      if (result case InvitationLookupResult(:final invitation?)) {
        emit(
          state.copyWith(
            step: OnboardingStep.invitationReview,
            status: OnboardingActionStatus.idle,
            invitation: invitation,
          ),
        );
      } else {
        emit(
          state.copyWith(
            step: OnboardingStep.invitationInvalid,
            status: OnboardingActionStatus.idle,
            invitationFailure: result.failure,
          ),
        );
      }
    } on Object {
      emit(
        state.copyWith(
          status: OnboardingActionStatus.failure,
          message: 'No pudimos revisar la invitación. Inténtalo nuevamente.',
        ),
      );
    }
  }

  Future<void> invitationAccepted() async {
    final invitation = state.invitation;
    if (invitation == null || state.isLoading) {
      return;
    }
    emit(state.copyWith(status: OnboardingActionStatus.loading));
    try {
      await _repository.acceptInvitation(invitation);
      emit(
        state.copyWith(
          step: OnboardingStep.invitationAccepted,
          status: OnboardingActionStatus.idle,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: OnboardingActionStatus.failure,
          message: 'No pudimos aceptar la invitación. Inténtalo nuevamente.',
        ),
      );
    }
  }

  Future<void> invitationDeclined() async {
    final invitation = state.invitation;
    if (invitation != null) {
      await _repository.declineInvitation(invitation);
    }
    backToChoice();
  }

  void retryInvitation() {
    emit(
      state.copyWith(
        step: OnboardingStep.invitationCode,
        status: OnboardingActionStatus.idle,
        clearInvitation: true,
        clearInvitationFailure: true,
        clearMessage: true,
      ),
    );
  }

  void babyNameChanged(String value) {
    emit(
      state.copyWith(
        babyName: value,
        clearBabyNameError: true,
        clearMessage: true,
      ),
    );
  }

  void birthDateChanged(DateTime value) {
    emit(
      state.copyWith(
        birthDate: DateTime(value.year, value.month, value.day),
        clearBirthDateError: true,
        clearMessage: true,
      ),
    );
  }

  void sexReferenceChanged(SexReference value) {
    emit(
      state.copyWith(
        sexReference: value,
        clearSexReferenceError: true,
        clearMessage: true,
      ),
    );
  }

  void babyPhotoChanged(String? path) {
    final normalized = path?.trim();
    emit(
      state.copyWith(
        babyPhotoPath: normalized,
        clearBabyPhoto: normalized == null || normalized.isEmpty,
        clearMessage: true,
      ),
    );
  }

  Future<void> babySubmitted() async {
    final name = state.babyName.trim();
    final birthDate = state.birthDate;
    final sexReference = state.sexReference;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final nameError = name.isEmpty
        ? 'Ingresa el nombre del bebé.'
        : name.length < 2
            ? 'El nombre debe tener al menos 2 caracteres.'
            : null;
    final birthDateError = birthDate == null
        ? 'Selecciona la fecha de nacimiento.'
        : birthDate.isAfter(todayOnly)
            ? 'La fecha no puede estar en el futuro.'
            : null;
    final sexError = sexReference == null
        ? 'Selecciona una referencia para las curvas de crecimiento.'
        : null;

    if (nameError != null || birthDateError != null || sexError != null) {
      emit(
        state.copyWith(
          babyNameError: nameError,
          birthDateError: birthDateError,
          sexReferenceError: sexError,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: OnboardingActionStatus.loading,
        clearMessage: true,
      ),
    );
    try {
      final baby = await _repository.createBaby(
        BabyDraft(
          name: name,
          birthDate: birthDate!,
          sexReference: sexReference!,
          photoPath: state.babyPhotoPath,
        ),
      );
      emit(
        state.copyWith(
          step: OnboardingStep.babyCreated,
          status: OnboardingActionStatus.idle,
          createdBaby: baby,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: OnboardingActionStatus.failure,
          message: 'No pudimos crear el perfil. Inténtalo nuevamente.',
        ),
      );
    }
  }
}
