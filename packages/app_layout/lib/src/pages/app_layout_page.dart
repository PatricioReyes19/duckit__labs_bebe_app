import 'package:app_layout/src/bloc/app_layout_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

typedef AppLayoutBlocFactory = AppLayoutBloc Function(BuildContext context);

/// Shell exterior responsable únicamente de inyectar AppLayoutBloc.
///
/// El StatefulNavigationShell se obtiene dentro del builder de
/// StatefulShellRoute.indexedStack, no desde el child de este ShellRoute.
class AppLayoutPage extends ShellRoute {
  AppLayoutPage({
    required super.routes,
    required AppLayoutBlocFactory appLayoutBloc,
    super.observers,
  }) : super(
         pageBuilder: (context, state, child) {
           return MaterialPage<void>(
             key: const ValueKey('app-layout-provider'),
             name: 'AppLayoutProvider',
             child: BlocProvider(create: appLayoutBloc, child: child),
           );
         },
       );
}
