enum LoginSubmissionStatus { idle, submitting, success, failure }

class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = LoginSubmissionStatus.idle,
    this.emailError,
    this.passwordError,
    this.message,
    this.resetEmailSent = false,
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final LoginSubmissionStatus status;
  final String? emailError;
  final String? passwordError;
  final String? message;
  final bool resetEmailSent;

  bool get isSubmitting => status == LoginSubmissionStatus.submitting;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    LoginSubmissionStatus? status,
    String? emailError,
    String? passwordError,
    String? message,
    bool? resetEmailSent,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearMessage = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      emailError: clearEmailError ? null : emailError ?? this.emailError,
      passwordError:
          clearPasswordError ? null : passwordError ?? this.passwordError,
      message: clearMessage ? null : message ?? this.message,
      resetEmailSent: resetEmailSent ?? this.resetEmailSent,
    );
  }
}
