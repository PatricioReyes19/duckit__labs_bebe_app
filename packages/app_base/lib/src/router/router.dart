import 'dart:async';

import 'package:agenda/agenda.dart';
import 'package:app_layout/app_layout.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:home/home.dart';
import 'package:login/login.dart';
import 'package:notifications/notifications.dart';
import 'package:onboarding/onboarding.dart' hide BabyDraft;
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
  final healthFlowController = HealthFlowController(
    getFamilyOverview: getIt<GetFamilyOverview>(),
    getHealthOverview: getIt<GetHealthOverview>(),
    getRegisterEvents: getIt<GetRegisterEvents>(),
    saveRegisterEvent: getIt<SaveRegisterEvent>(),
    healthRepository: getIt<HealthRepository>(),
    registerSyncService: getIt<RegisterEventSyncService>(),
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    // Cada arranque pasa por ResolveEntry. La ubicación recordada sólo se
    // conserva como estado de navegación, nunca como bypass del startup.
    initialLocation: StartupPaths.splash,
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
                onPrimaryActionPressed: () => RegisterPage.open(context),
                child: navigationShell,
              );
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: homeNavigatorKey,
                routes: [
                  HomePage(
                    homeBloc: (_) => getIt<HomeBloc>(),
                    openRegister: (context, actionId) => RegisterPage.open(
                      context,
                      kind: RegisterEventKind.fromRouteValue(actionId),
                    ),
                    openAgenda: (context) => context.go(AgendaPage.fullPath),
                    openHealth: (context) => context.go(HealthPage.fullPath),
                    openTodayHistory: (context) =>
                        context.push(HomeDailyHistoryPage.fullPath),
                    routes: [
                      HomeDailyHistoryPage(
                        getRegisterEvents: (_) => getIt<GetRegisterEvents>(),
                        getFamilyOverview: (_) => getIt<GetFamilyOverview>(),
                        deleteRegisterEvent: (_) =>
                            getIt<DeleteRegisterEvent>(),
                        syncService: (_) => getIt<RegisterEventSyncService>(),
                        onRegisterPressed: RegisterPage.open,
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: agendaNavigatorKey,
                routes: [
                  AgendaPage(
                    agendaBloc: (_) => getIt<AgendaBloc>(),
                    openNotifications: (context) =>
                        context.push('/notifications'),
                    openReminderSettings: (context) =>
                        context.push(AgendaSubpage.reminderSettingsPath),
                    openHealth: (context) => context.go(HealthPage.fullPath),
                    createReminder: (context) =>
                        context.push(AgendaSubpage.createReminderPath),
                    registerEvent: RegisterPage.open,
                    openRegisterHistory: (context) =>
                        context.push(HomeDailyHistoryPage.fullPath),
                    openEvent: (context, eventId) =>
                        context.push(AgendaSubpage.eventDetailPath(eventId)),
                    routes: [
                      AgendaSubpage(
                        kind: AgendaSubpageKind.reminderSettings,
                        createAgendaEvent: getIt<CreateAgendaEvent>(),
                        agendaRepository: getIt<AgendaRepository>(),
                        appSettingsRepository: getIt<AppSettingsRepository>(),
                        getFamilyOverview: getIt<GetFamilyOverview>(),
                      ),
                      AgendaSubpage(
                        kind: AgendaSubpageKind.createReminder,
                        createAgendaEvent: getIt<CreateAgendaEvent>(),
                        agendaRepository: getIt<AgendaRepository>(),
                        appSettingsRepository: getIt<AppSettingsRepository>(),
                        getFamilyOverview: getIt<GetFamilyOverview>(),
                      ),
                      AgendaSubpage(
                        kind: AgendaSubpageKind.eventDetail,
                        createAgendaEvent: getIt<CreateAgendaEvent>(),
                        agendaRepository: getIt<AgendaRepository>(),
                        appSettingsRepository: getIt<AppSettingsRepository>(),
                        getFamilyOverview: getIt<GetFamilyOverview>(),
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: healthNavigatorKey,
                routes: [
                  HealthPage(
                    healthBloc: (_) => getIt<HealthBloc>(),
                    openVaccines: (context) => context.push(
                      HealthSectionPage.locationFor(
                        HealthSectionKind.vaccines,
                      ),
                    ),
                    openControls: (context) => context.push(
                      HealthSectionPage.locationFor(
                        HealthSectionKind.controls,
                      ),
                    ),
                    openGrowth: (context) => context.push(
                      HealthSectionPage.locationFor(HealthSectionKind.growth),
                    ),
                    openConsultations: (context) => context.push(
                      HealthSectionPage.locationFor(
                        HealthSectionKind.consultations,
                      ),
                    ),
                    openPediatricCare: (context) => context.push(
                      HealthSectionPage.locationFor(
                        HealthSectionKind.pediatricCare,
                      ),
                    ),
                    openAgenda: (context) => context.go(AgendaPage.fullPath),
                    openClinicalHistory: (context) => context.push(
                      HealthSectionPage.locationFor(
                        HealthSectionKind.clinicalHistory,
                      ),
                    ),
                    openReports: (context) => context.push(
                      HealthSectionPage.locationFor(
                        HealthSectionKind.reports,
                      ),
                    ),
                    routes: [
                      for (final kind in HealthSectionKind.values)
                        HealthSectionPage(
                          kind: kind,
                          controller: healthFlowController,
                        ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: familyNavigatorKey,
                routes: [
                  FamilyPage(
                    familyBloc: (_) => getIt<FamilyBloc>(),
                    openPersonalSettings: SettingsPage.open,
                    openFamilySettings: (context) => context.push(
                      FamilySubpage.familyConfigurationPath,
                    ),
                    openBabySelector: (context) =>
                        unawaited(_selectFamilyBaby(context)),
                    addBaby: (context) => unawaited(_addFamilyBaby(context)),
                    manageCareCircle: (context) =>
                        context.push(FamilySubpage.careCirclePath),
                    inviteCaregiver: (context) =>
                        context.push(FamilySubpage.inviteCaregiverPath),
                    openMember: (context, memberId) => context.push(
                      FamilySubpage.memberDetailPath(memberId),
                    ),
                    openBaby: (context, babyId) => context.push(
                      FamilySubpage.babyDetailPath(babyId),
                    ),
                    routes: [
                      SettingsPage(
                        settingsBloc: (_) => getIt<SettingsBloc>(),
                        openAccount: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.account,
                          ),
                        ),
                        openAppearance: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.appearance,
                          ),
                        ),
                        openLanguage: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.language,
                          ),
                        ),
                        openTimeFormat: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.timeFormat,
                          ),
                        ),
                        openTextSize: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.textSize,
                          ),
                        ),
                        openSecurity: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.security,
                          ),
                        ),
                        openPrivacy: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.privacy,
                          ),
                        ),
                        downloadData: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.downloadData,
                          ),
                        ),
                        openStorage: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.storage,
                          ),
                        ),
                        openHelpCenter: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.helpCenter,
                          ),
                        ),
                        reportProblem: (context) => context.push(
                          SettingsDetailPage.locationFor(
                            SettingsSectionKind.reportProblem,
                          ),
                        ),
                        signOut: (context) =>
                            unawaited(_signOutAndOpenLogin(context)),
                        changeTheme: (_, value) => _changeAppTheme(value),
                        routes: [
                          SettingsDetailPage(
                            settingsBloc: (_) => getIt<SettingsBloc>(),
                            changeTheme: (_, value) => _changeAppTheme(value),
                          ),
                        ],
                      ),
                      FamilySubpage(
                        kind: FamilySubpageKind.babySelector,
                        getFamilyOverview: getIt<GetFamilyOverview>(),
                        familyRepository: getIt<FamilyRepository>(),
                      ),
                      FamilySubpage(
                        kind: FamilySubpageKind.addBaby,
                        getFamilyOverview: getIt<GetFamilyOverview>(),
                        familyRepository: getIt<FamilyRepository>(),
                      ),
                      FamilySubpage(
                        kind: FamilySubpageKind.babyDetail,
                        getFamilyOverview: getIt<GetFamilyOverview>(),
                        familyRepository: getIt<FamilyRepository>(),
                      ),
                      FamilySubpage(
                        kind: FamilySubpageKind.careCircle,
                        getFamilyOverview: getIt<GetFamilyOverview>(),
                        familyRepository: getIt<FamilyRepository>(),
                      ),
                      FamilySubpage(
                        kind: FamilySubpageKind.inviteCaregiver,
                        getFamilyOverview: getIt<GetFamilyOverview>(),
                        familyRepository: getIt<FamilyRepository>(),
                      ),
                      FamilySubpage(
                        kind: FamilySubpageKind.memberDetail,
                        getFamilyOverview: getIt<GetFamilyOverview>(),
                        familyRepository: getIt<FamilyRepository>(),
                      ),
                      FamilySubpage(
                        kind: FamilySubpageKind.familyConfiguration,
                        getFamilyOverview: getIt<GetFamilyOverview>(),
                        familyRepository: getIt<FamilyRepository>(),
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
        path: SettingsPage.legacyFullPath,
        redirect: (_, __) => SettingsPage.fullPath,
      ),
      SplashAuthEntryPage(
        path: StartupPaths.authEntry,
        parentNavigatorKey: rootNavigatorKey,
        onLoginPressed: (context) => context.push(StartupPaths.login),
        onSignUpPressed: (context) => context.push(StartupPaths.signUp),
        onInvitationPressed: (context) => context.push(
          '${StartupPaths.login}?next=invitation',
        ),
      ),
      GoRoute(
        path: StartupPaths.login,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final invitationPending =
              state.uri.queryParameters['next'] == 'invitation';
          final invitationCode = state.uri.queryParameters['code'];
          return LoginPage(
            authService: getIt<AuthService>(),
            invitationPending: invitationPending,
            onBackPressed: () => _backToAuthEntry(context),
            onAuthenticated: () {
              unawaited(getIt<RegisterEventSyncService>().synchronize());
              unawaited(getIt<AgendaEventSyncService>().synchronize());
              if (invitationPending) {
                context.go(_invitationLocation(invitationCode));
                return;
              }
              unawaited(_openResolvedDestination(context));
            },
            onSignUpPressed: () {
              context.pushReplacement(
                invitationPending
                    ? _invitationAuthLocation(
                        StartupPaths.signUp,
                        invitationCode,
                      )
                    : StartupPaths.signUp,
              );
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
          final invitationCode = state.uri.queryParameters['code'];
          return SignUpPage(
            authService: getIt<AuthService>(),
            invitationPending: invitationPending,
            onBackPressed: () => _backToAuthEntry(context),
            onAccountCreated: () {
              unawaited(getIt<RegisterEventSyncService>().synchronize());
              unawaited(getIt<AgendaEventSyncService>().synchronize());
              context.go(
                invitationPending
                    ? _invitationLocation(invitationCode)
                    : StartupPaths.onboarding,
              );
            },
            onLoginPressed: () {
              context.pushReplacement(
                invitationPending
                    ? _invitationAuthLocation(
                        StartupPaths.login,
                        invitationCode,
                      )
                    : StartupPaths.login,
              );
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
        redirect: (_, state) => _requireSession(
          invitationPending: true,
          invitationCode: state.uri.queryParameters['code'],
        ),
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
          invitationCode: GoRouterState.of(context).uri.queryParameters['code'],
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
        getFamilyOverview: (_) => getIt<GetFamilyOverview>(),
        onNotificationsPressed: (context) => context.push('/notifications'),
        onHomePressed: (context) => context.go(StartupPaths.home),
        onAgendaPressed: (context) => context.go(AgendaPage.fullPath),
        onHealthPressed: (context) => context.go(HealthPage.fullPath),
        onFamilyPressed: (context) => context.go(FamilyPage.fullPath),
        onSaved: (context, event) {
          unawaited(_scheduleRegisterReminder(event));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registro guardado localmente. Se sincronizará en segundo plano.',
              ),
            ),
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
        redirect: (_, __) => _requireSession(),
        builder: (context, __) => NotificationsPage(
          notificationService: getIt<NotificationService>(),
          onBackPressed: () => _backOrHome(context),
          onNotificationPressed: (notification) =>
              context.go(notification.route ?? '/notifications'),
        ),
      ),
    ],
  );
}

Future<void> _scheduleRegisterReminder(RegisteredEvent event) async {
  final service = getIt<NotificationService>();
  final details = event.details;

  if (event.type == RegisterEventType.medication &&
      details['schedule_next_doses'] == true) {
    final interval = switch (details['frequency']) {
      'Cada 4 horas' => const Duration(hours: 4),
      'Cada 6 horas' => const Duration(hours: 6),
      'Cada 8 horas' => const Duration(hours: 8),
      'Cada 12 horas' => const Duration(hours: 12),
      'Una vez al día' => const Duration(days: 1),
      _ => null,
    };
    if (interval == null) return;
    final explicitEnd = DateTime.tryParse(
      (details['end_date'] as String?) ?? '',
    )?.toLocal();
    final horizon = explicitEnd ?? DateTime.now().add(const Duration(days: 30));
    var next = event.occurredAt.toLocal().add(interval);
    while (!next.isAfter(DateTime.now())) {
      next = next.add(interval);
    }
    final name = (details['name'] as String?)?.trim();
    var scheduled = 0;
    while (!next.isAfter(horizon) && scheduled < 60) {
      await service.scheduleReminder(
        id: 'medication-${event.id}-${next.millisecondsSinceEpoch}',
        title: 'Hora del medicamento',
        body:
            'Corresponde la próxima dosis de ${name?.isNotEmpty == true ? name : 'medicamento'}.',
        scheduledAt: next,
        route: '/agenda',
      );
      next = next.add(interval);
      scheduled += 1;
    }
    return;
  }

  final shouldSchedule = switch (event.type) {
    RegisterEventType.feeding => details['schedule_next_feeding'] == true,
    RegisterEventType.diaper => details['schedule_reminder'] == true,
    _ => false,
  };
  final hours = (details['reminder_interval_hours'] as num?)?.toInt();
  if (!shouldSchedule || hours == null || hours <= 0) return;
  final scheduledAt = event.occurredAt.toLocal().add(Duration(hours: hours));
  final (title, body, route) = switch (event.type) {
    RegisterEventType.feeding => (
        'Próxima toma',
        'Es momento de revisar si corresponde una nueva mamadera o fórmula.',
        '/register/feeding',
      ),
    RegisterEventType.diaper => (
        'Próximo cambio de pañal',
        'Revisa el pañal y registra el cambio cuando corresponda.',
        '/register/diaper',
      ),
    _ => ('Recordatorio', 'Tienes una tarea pendiente.', '/agenda'),
  };
  await service.scheduleReminder(
    id: '${event.type.name}-${event.id}-${scheduledAt.millisecondsSinceEpoch}',
    title: title,
    body: body,
    scheduledAt: scheduledAt,
    route: route,
  );
}

void _backToAuthEntry(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(StartupPaths.authEntry);
}

Future<void> _selectFamilyBaby(BuildContext context) async {
  final babyId = await context.push<String>(FamilySubpage.babySelectorPath);
  if (!context.mounted || babyId == null) return;
  context.read<FamilyBloc>().add(FamilyEvent.babySelected(babyId));
}

Future<void> _addFamilyBaby(BuildContext context) async {
  final draft = await context.push<FamilyBabyDraftResult>(
    FamilySubpage.addBabyPath,
  );
  if (!context.mounted || draft == null) return;

  final familyState = context.read<FamilyBloc>().state;
  if (familyState is! FamilyLoaded) return;

  try {
    await CreateFamilyBaby(getIt<FamilyRepository>())(
      BabyDraft(
        familyId: familyState.overview.familyId,
        name: draft.name,
        birthDate: draft.birthDate,
      ),
    );
    if (!context.mounted) return;
    context.read<FamilyBloc>().add(const FamilyEvent.retried());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil de ${draft.name} creado.')),
    );
  } on Object catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No pudimos crear el perfil: $error')),
    );
  }
}

void _changeAppTheme(BebeThemeModeOption value) {
  final mode = switch (value) {
    BebeThemeModeOption.system => ThemeMode.system,
    BebeThemeModeOption.light => ThemeMode.light,
    BebeThemeModeOption.dark => ThemeMode.dark,
  };
  getIt<AppThemeBloc>().add(AppThemeEvent.updateThemeMode(themeMode: mode));
}

void _backOrHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(StartupPaths.home);
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

Future<String?> _requireSession({
  bool invitationPending = false,
  String? invitationCode,
}) async {
  final session = await getIt<AuthService>().currentSession();
  if (session != null) {
    return null;
  }
  return invitationPending
      ? _invitationAuthLocation(StartupPaths.login, invitationCode)
      : StartupPaths.login;
}

Future<void> _signOutAndOpenLogin(
  BuildContext context, {
  bool invitationPending = false,
  String? invitationCode,
}) async {
  try {
    await getIt<AuthService>().signOut();
  } on Object catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos cerrar la sesión: $error')),
      );
    }
    return;
  }

  try {
    await NavigationSessionStore(getIt()).clear();
  } on Object {
    // Una preferencia dañada no debe impedir salir de la cuenta.
  }
  final destination = invitationPending
      ? _invitationAuthLocation(StartupPaths.login, invitationCode)
      : StartupPaths.authEntry;
  getIt<GoRouter>().go(destination);

  // La limpieza local ocurre después de navegar para que el botón responda
  // inmediatamente. La base en disco permanece aislada por usuario.
  try {
    await getIt<BebeDatabase>().close();
  } on Object {
    // La sesión ya fue cerrada por la fuente de autenticación.
  }
}

String _invitationLocation(String? code) => Uri(
      path: StartupPaths.invitation,
      queryParameters:
          code == null || code.trim().isEmpty ? null : {'code': code.trim()},
    ).toString();

String _invitationAuthLocation(String path, String? code) => Uri(
      path: path,
      queryParameters: {
        'next': 'invitation',
        if (code != null && code.trim().isNotEmpty) 'code': code.trim(),
      },
    ).toString();

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
