import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/login_cubit.dart';
import '../views/login_view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    required this.authService,
    required this.onAuthenticated,
    required this.onBackPressed,
    required this.onSignUpPressed,
    this.invitationPending = false,
    super.key,
  });

  final AuthService authService;
  final VoidCallback onAuthenticated;
  final VoidCallback onBackPressed;
  final VoidCallback onSignUpPressed;
  final bool invitationPending;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(authService),
      child: LoginView(
        onAuthenticated: onAuthenticated,
        onBackPressed: onBackPressed,
        onSignUpPressed: onSignUpPressed,
        invitationPending: invitationPending,
      ),
    );
  }
}
