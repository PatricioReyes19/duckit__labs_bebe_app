enum SignUpSubmissionStatus { idle, submitting, success, failure }

class SignUpState {
  const SignUpState({
    this.displayName = '',
    this.email = '',
    this.password = '',
    this.acceptedTerms = false,
    this.obscurePassword = true,
    this.status = SignUpSubmissionStatus.idle,
    this.displayNameError,
    this.emailError,
    this.passwordError,
    this.termsError,
    this.message,
  });

  final String displayName;
  final String email;
  final String password;
  final bool acceptedTerms;
  final bool obscurePassword;
  final SignUpSubmissionStatus status;
  final String? displayNameError;
  final String? emailError;
  final String? passwordError;
  final String? termsError;
  final String? message;

  bool get isSubmitting => status == SignUpSubmissionStatus.submitting;

  SignUpState copyWith({
    String? displayName,
    String? email,
    String? password,
    bool? acceptedTerms,
    bool? obscurePassword,
    SignUpSubmissionStatus? status,
    String? displayNameError,
    String? emailError,
    String? passwordError,
    String? termsError,
    String? message,
    bool clearDisplayNameError = false,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearTermsError = false,
    bool clearMessage = false,
  }) {
    return SignUpState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      displayNameError: clearDisplayNameError
          ? null
          : displayNameError ?? this.displayNameError,
      emailError: clearEmailError ? null : emailError ?? this.emailError,
      passwordError:
          clearPasswordError ? null : passwordError ?? this.passwordError,
      termsError: clearTermsError ? null : termsError ?? this.termsError,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
