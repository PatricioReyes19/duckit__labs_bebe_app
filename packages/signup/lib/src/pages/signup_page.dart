import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/signup_cubit.dart';
import '../views/signup_view.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({
    required this.authService,
    required this.onAccountCreated,
    required this.onLoginPressed,
    this.invitationPending = false,
    super.key,
  });

  final AuthService authService;
  final VoidCallback onAccountCreated;
  final VoidCallback onLoginPressed;
  final bool invitationPending;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignUpCubit(authService),
      child: SignUpView(
        onAccountCreated: onAccountCreated,
        onLoginPressed: onLoginPressed,
        invitationPending: invitationPending,
      ),
    );
  }
}
