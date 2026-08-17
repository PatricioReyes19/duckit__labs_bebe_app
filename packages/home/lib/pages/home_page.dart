import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:home/home.dart';

typedef HomeBlocFactory = HomeBloc Function(BuildContext context);
typedef HomeBabySwitcher = Future<void> Function(String babyId);
typedef HomeHistoryOpener = void Function(
  BuildContext context,
  RegisterEventType? type,
);

class HomePage extends GoRoute {
  HomePage({
    required HomeBlocFactory homeBloc,
    required void Function(BuildContext context, String actionId) openRegister,
    required void Function(BuildContext context) openAgenda,
    required void Function(BuildContext context) openHealth,
    required HomeHistoryOpener openTodayHistory,
    required HomeBabySwitcher switchBaby,
    super.name,
    super.routes,
  }) : super(
          path: fullPath,
          pageBuilder: (context, state) {
            return MaterialPage<void>(
              key: const ValueKey('home'),
              name: name ?? nameRoute,
              child: BlocProvider(
                create: (context) =>
                    homeBloc(context)..add(const HomeEvent.started()),
                child: HomeView(
                  openRegister: openRegister,
                  openAgenda: openAgenda,
                  openHealth: openHealth,
                  openTodayHistory: openTodayHistory,
                  switchBaby: switchBaby,
                ),
              ),
            );
          },
        );

  static const nameRoute = 'Home';
  static const fullPath = '/home';

  static void open(BuildContext context) {
    context.go(fullPath);
  }
}
