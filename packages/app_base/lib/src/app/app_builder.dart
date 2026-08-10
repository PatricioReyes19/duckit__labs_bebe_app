import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class AppBuilder extends StatelessWidget {
  const AppBuilder({
    required this.app,
    required this.themeBloc,
    this.preconditionView,
    super.key,
  });

  final Widget app;
  final AppThemeBloc themeBloc;
  final Widget? preconditionView;

  @override
  Widget build(BuildContext context) {
    if (preconditionView != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeBloc.state.theme.lightTheme(),
        darkTheme: themeBloc.state.theme.darkTheme(),
        themeMode: themeBloc.state.themeMode,
        home: preconditionView,
      );
    }

    return app;
  }
}
