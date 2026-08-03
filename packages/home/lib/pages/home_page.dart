import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:home/home.dart';

typedef HomeBlocFactory = HomeBloc Function(BuildContext context);

class HomePage extends GoRoute {
  HomePage({
    required HomeBlocFactory homeBloc,
    required void Function(BuildContext context) openNotifications,
    required void Function(BuildContext context, String actionId) openRegister,
    required void Function(BuildContext context) openAgenda,
    required void Function(BuildContext context) openHealth,
    super.name,
    super.routes,
  }) : super(
          path: fullPath,
          pageBuilder: (context, state) {
            return CupertinoPage<void>(
              key: const ValueKey('home'),
              name: name ?? nameRoute,
              child: BlocProvider(
                create: (context) =>
                    homeBloc(context)..add(const HomeEvent.started()),
                child: HomeView(
                  openNotifications: openNotifications,
                  openRegister: openRegister,
                  openAgenda: openAgenda,
                  openHealth: openHealth,
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
