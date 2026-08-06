import 'package:auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authService) : super(const LoginState());

  final AuthService _authService;

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        clearEmailError: true,
        clearMessage: true,
        resetEmailSent: false,
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

  void passwordVisibilityToggled() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> submitted() async {
    if (state.isSubmitting) {
      return;
    }

    emit(
      state.copyWith(
        status: LoginSubmissionStatus.submitting,
        clearEmailError: true,
        clearPasswordError: true,
        clearMessage: true,
      ),
    );

    try {
      await _authService.signIn(
        email: state.email,
        password: state.password,
      );
      emit(state.copyWith(status: LoginSubmissionStatus.success));
    } on AuthValidationFailure catch (failure) {
      emit(
        state.copyWith(
          status: LoginSubmissionStatus.failure,
          emailError: failure.fieldErrors['email'],
          passwordError: failure.fieldErrors['password'],
        ),
      );
    } on AuthFailure catch (failure) {
      emit(
        state.copyWith(
          status: LoginSubmissionStatus.failure,
          message: failure.message,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: LoginSubmissionStatus.failure,
          message:
              'No pudimos iniciar sesión. Revisa tu conexión e inténtalo nuevamente.',
        ),
      );
    }
  }

  Future<void> passwordResetRequested() async {
    try {
      await _authService.sendPasswordResetEmail(state.email);
      emit(
        state.copyWith(
          resetEmailSent: true,
          clearEmailError: true,
          clearMessage: true,
        ),
      );
    } on AuthValidationFailure catch (failure) {
      emit(
        state.copyWith(
          emailError: failure.fieldErrors['email'],
          resetEmailSent: false,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          message: 'No pudimos enviar el correo de recuperación.',
          resetEmailSent: false,
        ),
      );
    }
  }
}
