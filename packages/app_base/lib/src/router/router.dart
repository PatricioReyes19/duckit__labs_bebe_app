import 'package:agenda/agenda.dart';
import 'package:app_layout/app_layout.dart';
import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:home/home.dart';

import '../dependencies/dependencies.dart';
import 'app_layout_configuration.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final agendaNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'agenda');
final healthNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'health');
final familyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'family');

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: HomePage.fullPath,
    routes: [
      AppLayoutPage(
        appLayoutBloc: (_) => getIt<AppLayoutBloc>(),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return AppLayoutView(
                state: state,
                navigationShell: navigationShell,
                tabs: appLayoutTabs,
                visibilityPolicy: appLayoutVisibilityPolicy,
                defaultTitle: 'BebéApp',
                defaultHeaderActions: [
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
                onPrimaryActionPressed: () => context.push('/register'),
                child: navigationShell,
              );
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: homeNavigatorKey,
                routes: [
                  HomePage(
                    homeBloc: (_) => getIt<HomeBloc>(),
                    openNotifications: (context) =>
                        context.push('/notifications'),
                    openRegister: (context, actionId) =>
                        context.push('/register?type=$actionId'),
                    openAgenda: (context) => context.go(AgendaPage.fullPath),
                    openHealth: (context) => context.go(HealthPage.fullPath),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: agendaNavigatorKey,
                routes: [
                  AgendaPage(
                    agendaBloc: (_) => getIt<AgendaBloc>(),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: healthNavigatorKey,
                routes: [
                  HealthPage(
                    healthBloc: (_) => getIt<HealthBloc>(),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: familyNavigatorKey,
                routes: [
                  FamilyPage(
                    familyBloc: (_) => getIt<FamilyBloc>(),
                    routes: [
                      SettingsPage(
                        settingsBloc: (_) => getIt<SettingsBloc>(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const _PendingPage(title: 'Registrar'),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const _PendingPage(title: 'Notificaciones'),
      ),
    ],
  );
}

class _PendingPage extends StatelessWidget {
  const _PendingPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(title),
      ),
      body: Center(child: Text('$title: package pendiente')),
    );
  }
}
