import 'dart:async';

import 'package:agenda/agenda.dart';
import 'package:app_layout/app_layout.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:home/home.dart';
import 'package:login/login.dart';
import 'package:onboarding/onboarding.dart';
import 'package:register/register.dart';
import 'package:splash/splash.dart';
import 'package:signup/signup.dart';

import '../dependencies/dependencies.dart';
import 'app_layout_configuration.dart';
import 'navigation_session_store.dart';
import 'startup_route_mapper.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final agendaNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'agenda');
final healthNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'health');
final familyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'family');

GoRouter createAppRouter({
  required NavigationSessionStore navigationSessionStore,
}) {
  const startupRouteMapper = StartupRouteMapper();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: navigationSessionStore.initialLocation,
    redirect: (_, state) {
      unawaited(navigationSessionStore.remember(state.uri));
      return null;
    },
    routes: [
      SplashPage(
        splashBloc: (_) => SplashBloc(
          resolveEntryDestination: getIt<ResolveEntryDestination>(),
          errorReporter: (error, stackTrace) {
            debugPrint('Splash error: $error');
            debugPrintStack(stackTrace: stackTrace);
          },
        ),
        onDestinationResolved: (context, destination) {
          context.go(startupRouteMapper.pathFor(destination));
        },
        onInvitationAccessRequested: (context) => () {
          context.go('${StartupPaths.login}?next=invitation');
        },
      ),
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
                onPrimaryActionPressed: () =>
                    context.push(RegisterPage.fullPath),
                child: navigationShell,
              );
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: homeNavigatorKey,
                routes: [
                  HomePage(
                    homeBloc: (_) => getIt<HomeBloc>(),
                    openRegister: (context, actionId) => context.push(
                      '${RegisterPage.fullPath}?type=$actionId',
                    ),
                    openAgenda: (context) => context.go(AgendaPage.fullPath),
                    openHealth: (context) => context.go(HealthPage.fullPath),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: agendaNavigatorKey,
                routes: [
                  AgendaPage(agendaBloc: (_) => getIt<AgendaBloc>()),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: healthNavigatorKey,
                routes: [
                  HealthPage(healthBloc: (_) => getIt<HealthBloc>()),
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
        path: StartupPaths.authEntry,
        parentNavigatorKey: rootNavigatorKey,
        redirect: (_, __) => SplashPage.fullPath,
      ),
      GoRoute(
        path: StartupPaths.login,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final invitationPending =
              state.uri.queryParameters['next'] == 'invitation';
          return LoginPage(
            authService: getIt<AuthService>(),
            invitationPending: invitationPending,
            onAuthenticated: () {
              if (invitationPending) {
                context.go(StartupPaths.invitation);
                return;
              }
              unawaited(_openResolvedDestination(context));
            },
            onSignUpPressed: () {
              final suffix = invitationPending ? '?next=invitation' : '';
              context.go('${StartupPaths.signUp}$suffix');
            },
          );
        },
      ),
      GoRoute(
        path: StartupPaths.signUp,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final invitationPending =
              state.uri.queryParameters['next'] == 'invitation';
          return SignUpPage(
            authService: getIt<AuthService>(),
            invitationPending: invitationPending,
            onAccountCreated: () {
              context.go(
                invitationPending
                    ? StartupPaths.invitation
                    : StartupPaths.onboarding,
              );
            },
            onLoginPressed: () {
              final suffix = invitationPending ? '?next=invitation' : '';
              context.go('${StartupPaths.login}$suffix');
            },
          );
        },
      ),
      OnboardingPage(
        path: StartupPaths.onboarding,
        parentNavigatorKey: rootNavigatorKey,
        redirect: (_, __) => _requireSession(),
        onboardingRepository: (_) => getIt<OnboardingRepository>(),
        entry: OnboardingEntry.choice,
        onCompleted: (context) => context.go(StartupPaths.home),
        onExitRequested: (context) => _exitOnboarding(
          context,
          OnboardingEntry.choice,
        ),
        onUseAnotherAccount: (context) => _signOutAndOpenLogin(context),
      ),
      OnboardingPage(
        path: StartupPaths.invitation,
        parentNavigatorKey: rootNavigatorKey,
        redirect: (_, __) => _requireSession(invitationPending: true),
        onboardingRepository: (_) => getIt<OnboardingRepository>(),
        entry: OnboardingEntry.invitation,
        onCompleted: (context) => context.go(StartupPaths.home),
        onExitRequested: (context) => _exitOnboarding(
          context,
          OnboardingEntry.invitation,
        ),
        onUseAnotherAccount: (context) => _signOutAndOpenLogin(
          context,
          invitationPending: true,
        ),
      ),
      GoRoute(
        path: StartupPaths.createCareCircle,
        parentNavigatorKey: rootNavigatorKey,
        redirect: (_, __) => StartupPaths.createBaby,
      ),
      GoRoute(
        path: StartupPaths.selectCareCircle,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const _PendingPage(
          title: 'Seleccionar círculo',
          description: 'Selecciona el círculo de cuidado que deseas usar.',
        ),
      ),
      OnboardingPage(
        path: StartupPaths.createBaby,
        parentNavigatorKey: rootNavigatorKey,
        redirect: (_, __) => _requireSession(),
        onboardingRepository: (_) => getIt<OnboardingRepository>(),
        entry: OnboardingEntry.babyProfile,
        onCompleted: (context) => context.go(StartupPaths.home),
        onExitRequested: (context) => _exitOnboarding(
          context,
          OnboardingEntry.babyProfile,
        ),
        onUseAnotherAccount: (context) => _signOutAndOpenLogin(context),
      ),
      GoRoute(
        path: StartupPaths.selectBaby,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const _PendingPage(
          title: 'Seleccionar bebé',
          description: 'Selecciona el perfil con el que deseas continuar.',
        ),
      ),
      RegisterPage(
        parentNavigatorKey: rootNavigatorKey,
        saveRegisterEvent: (_) => getIt<SaveRegisterEvent>(),
        onSaved: (context, event) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registro guardado en este dispositivo.')),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(StartupPaths.home);
          }
        },
        onCancel: (context) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(StartupPaths.home);
          }
        },
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const _PendingPage(
          title: 'Notificaciones',
          description: 'Centro de notificaciones pendiente.',
        ),
      ),
    ],
  );
}

Future<void> _openResolvedDestination(BuildContext context) async {
  final resolution = await getIt<ResolveEntryDestination>()();
  if (!context.mounted) {
    return;
  }
  context.go(const StartupRouteMapper().pathFor(resolution.destination));
}

void _exitOnboarding(BuildContext context, OnboardingEntry entry) {
  if (context.canPop()) {
    context.pop();
    return;
  }

  switch (entry) {
    case OnboardingEntry.choice:
      unawaited(_signOutAndOpenLogin(context));
    case OnboardingEntry.invitation:
    case OnboardingEntry.babyProfile:
      context.go(StartupPaths.onboarding);
  }
}

Future<String?> _requireSession({bool invitationPending = false}) async {
  final session = await getIt<AuthService>().currentSession();
  if (session != null) {
    return null;
  }
  return invitationPending
      ? '${StartupPaths.login}?next=invitation'
      : StartupPaths.login;
}

Future<void> _signOutAndOpenLogin(
  BuildContext context, {
  bool invitationPending = false,
}) async {
  await getIt<AuthService>().signOut();
  if (context.mounted) {
    final suffix = invitationPending ? '?next=invitation' : '';
    context.go('${StartupPaths.login}$suffix');
  }
}

class _PendingPage extends StatelessWidget {
  const _PendingPage({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => SplashPage.open(context),
                  child: const Text('Volver al flujo inicial'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
