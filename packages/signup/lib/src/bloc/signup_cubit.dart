import 'package:auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authService) : super(const SignUpState());

  final AuthService _authService;

  void displayNameChanged(String value) {
    emit(
      state.copyWith(
        displayName: value,
        clearDisplayNameError: true,
        clearMessage: true,
      ),
    );
  }

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        clearEmailError: true,
        clearMessage: true,
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
        clearPasswordError: true,
        clearMessage: true,
      ),
    );
  }

  void termsChanged(bool value) {
    emit(
      state.copyWith(
        acceptedTerms: value,
        clearTermsError: true,
        clearMessage: true,
      ),
    );
  }

  void passwordVisibilityToggled() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> submitted() async {
    if (state.isSubmitting) {
      return;
    }

    emit(
      state.copyWith(
        status: SignUpSubmissionStatus.submitting,
        clearDisplayNameError: true,
        clearEmailError: true,
        clearPasswordError: true,
        clearTermsError: true,
        clearMessage: true,
      ),
    );

    try {
      await _authService.signUp(
        displayName: state.displayName,
        email: state.email,
        password: state.password,
        acceptedTerms: state.acceptedTerms,
      );
      emit(state.copyWith(status: SignUpSubmissionStatus.success));
    } on AuthValidationFailure catch (failure) {
      emit(
        state.copyWith(
          status: SignUpSubmissionStatus.failure,
          displayNameError: failure.fieldErrors['displayName'],
          emailError: failure.fieldErrors['email'],
          passwordError: failure.fieldErrors['password'],
          termsError: failure.fieldErrors['terms'],
        ),
      );
    } on AuthFailure catch (failure) {
      emit(
        state.copyWith(
          status: SignUpSubmissionStatus.failure,
          message: failure.message,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: SignUpSubmissionStatus.failure,
          message: 'No pudimos crear la cuenta. Inténtalo nuevamente.',
        ),
      );
    }
  }
}
