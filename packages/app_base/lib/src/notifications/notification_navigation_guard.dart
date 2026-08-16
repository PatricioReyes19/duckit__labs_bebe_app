import 'package:core/core.dart';
import 'package:notifications/notifications.dart';

import '../router/startup_route_mapper.dart';

typedef RestoreAuthenticatedContext = Future<EntryResolution> Function(
  AuthUser user,
);
typedef ReadAvailableFamilies = Future<List<FamilyOverviewEntity>> Function();
typedef ActivateNotificationBaby = Future<void> Function(String babyId);

class NotificationNavigationGuard {
  const NotificationNavigationGuard({
    required Future<AuthSession?> Function() getCurrentSession,
    required RestoreAuthenticatedContext restoreAuthenticatedContext,
    required ReadAvailableFamilies readAvailableFamilies,
    required ActivateNotificationBaby activateBaby,
    required ActiveContextRepository activeContextRepository,
    StartupRouteMapper routeMapper = const StartupRouteMapper(),
  })  : _getCurrentSession = getCurrentSession,
        _restoreAuthenticatedContext = restoreAuthenticatedContext,
        _readAvailableFamilies = readAvailableFamilies,
        _activateBaby = activateBaby,
        _activeContextRepository = activeContextRepository,
        _routeMapper = routeMapper;

  final Future<AuthSession?> Function() _getCurrentSession;
  final RestoreAuthenticatedContext _restoreAuthenticatedContext;
  final ReadAvailableFamilies _readAvailableFamilies;
  final ActivateNotificationBaby _activateBaby;
  final ActiveContextRepository _activeContextRepository;
  final StartupRouteMapper _routeMapper;

  Future<String> resolve(AppNotification notification) async {
    final requestedRoute = notification.route ?? '/notifications';
    final session = await _getCurrentSession();
    if (session == null) {
      if (!requestedRoute.startsWith('/invitation')) {
        return StartupPaths.login;
      }
      final code = Uri.tryParse(requestedRoute)?.queryParameters['code'];
      return Uri(
        path: StartupPaths.login,
        queryParameters: {
          'next': 'invitation',
          if (code != null && code.isNotEmpty) 'code': code,
        },
      ).toString();
    }
    if (notification.accountId != null &&
        notification.accountId != session.user.id) {
      return '/notifications';
    }

    late final EntryResolution context;
    try {
      context = await _restoreAuthenticatedContext(session.user);
    } on Object {
      return StartupPaths.splash;
    }

    if ((await _getCurrentSession())?.user.id != session.user.id) {
      return StartupPaths.login;
    }

    // Invitation routes only expose the invitation acceptance flow; they do
    // not open baby data before membership exists.
    if (requestedRoute.startsWith('/invitation')) return requestedRoute;

    final babyId = notification.babyId;
    if (babyId == null) {
      return context.destination == EntryDestination.home
          ? requestedRoute
          : _routeMapper.pathFor(context.destination);
    }

    final families = await _readAvailableFamilies();
    FamilyOverviewEntity? authorizedFamily;
    for (final family in families) {
      if (family.babies.any((baby) => baby.id == babyId)) {
        authorizedFamily = family;
        break;
      }
    }
    if (authorizedFamily == null) return '/notifications';

    await _activateBaby(babyId);
    await _activeContextRepository.save(
      ActiveContext(
        userId: session.user.id,
        circleId: authorizedFamily.id,
        babyId: babyId,
      ),
    );
    if ((await _getCurrentSession())?.user.id != session.user.id) {
      return StartupPaths.login;
    }
    return requestedRoute;
  }
}
