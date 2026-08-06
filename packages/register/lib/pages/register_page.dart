import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:register/register.dart';

typedef SaveRegisterEventFactory = SaveRegisterEvent Function(
  BuildContext context,
);
typedef RegisterRouteSaved = void Function(
  BuildContext context,
  RegisteredEvent event,
);
typedef RegisterRouteAction = void Function(BuildContext context);

class RegisterPage extends GoRoute {
  RegisterPage({
    required SaveRegisterEventFactory saveRegisterEvent,
    required RegisterRouteSaved onSaved,
    required RegisterRouteAction onCancel,
    this.onNotificationsPressed,
    this.onHomePressed,
    this.onAgendaPressed,
    this.onHealthPressed,
    this.onFamilyPressed,
    this.babyId = 'local-active-baby',
    this.babyName = 'Mateo Reyes',
    this.babyAge = '2 meses',
    this.familyContextLabel = '2 bebés en la familia',
    super.name,
    super.parentNavigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
  }) : super(
          path: fullPath,
          redirect: (context, state) {
            final legacyType = state.uri.queryParameters['type'];
            if (legacyType == null) {
              return null;
            }
            return locationFor(
              RegisterEventKind.fromRouteValue(legacyType),
            );
          },
          pageBuilder: (context, state) => _buildPage(
            context: context,
            kind: RegisterEventKind.feeding,
            pageName: name ?? nameRoute,
            saveRegisterEvent: saveRegisterEvent,
            onSaved: onSaved,
            onCancel: onCancel,
            onNotificationsPressed: onNotificationsPressed,
            onHomePressed: onHomePressed,
            onAgendaPressed: onAgendaPressed,
            onHealthPressed: onHealthPressed,
            onFamilyPressed: onFamilyPressed,
            babyId: babyId,
            babyName: babyName,
            babyAge: babyAge,
            familyContextLabel: familyContextLabel,
          ),
          routes: [
            GoRoute(
              name: kindNameRoute,
              path: kindPath,
              redirect: (context, state) {
                final routeValue = state.pathParameters['kind'];
                final kind = RegisterEventKind.tryFromRouteValue(routeValue);
                if (kind == null || kind == RegisterEventKind.feeding) {
                  return fullPath;
                }
                if (routeValue != kind.routeValue) {
                  return locationFor(kind);
                }
                return null;
              },
              pageBuilder: (context, state) => _buildPage(
                context: context,
                kind: RegisterEventKind.fromRouteValue(
                  state.pathParameters['kind'],
                ),
                pageName: kindNameRoute,
                saveRegisterEvent: saveRegisterEvent,
                onSaved: onSaved,
                onCancel: onCancel,
                onNotificationsPressed: onNotificationsPressed,
                onHomePressed: onHomePressed,
                onAgendaPressed: onAgendaPressed,
                onHealthPressed: onHealthPressed,
                onFamilyPressed: onFamilyPressed,
                babyId: babyId,
                babyName: babyName,
                babyAge: babyAge,
                familyContextLabel: familyContextLabel,
              ),
            ),
            ...routes,
          ],
        );

  final String babyId;
  final String babyName;
  final String babyAge;
  final String familyContextLabel;
  final RegisterRouteAction? onNotificationsPressed;
  final RegisterRouteAction? onHomePressed;
  final RegisterRouteAction? onAgendaPressed;
  final RegisterRouteAction? onHealthPressed;
  final RegisterRouteAction? onFamilyPressed;

  static const nameRoute = 'Register';
  static const kindNameRoute = 'RegisterKind';
  static const fullPath = '/register';
  static const kindPath = ':kind';

  static String locationFor(RegisterEventKind kind) {
    if (kind == RegisterEventKind.feeding) {
      return fullPath;
    }
    return '$fullPath/${kind.routeValue}';
  }

  static void open(BuildContext context, {RegisterEventKind? kind}) {
    context.push(locationFor(kind ?? RegisterEventKind.feeding));
  }
}

Page<void> _buildPage({
  required BuildContext context,
  required RegisterEventKind kind,
  required String pageName,
  required SaveRegisterEventFactory saveRegisterEvent,
  required RegisterRouteSaved onSaved,
  required RegisterRouteAction onCancel,
  required RegisterRouteAction? onNotificationsPressed,
  required RegisterRouteAction? onHomePressed,
  required RegisterRouteAction? onAgendaPressed,
  required RegisterRouteAction? onHealthPressed,
  required RegisterRouteAction? onFamilyPressed,
  required String babyId,
  required String babyName,
  required String babyAge,
  required String familyContextLabel,
}) {
  final save = saveRegisterEvent(context);
  return CupertinoPage<void>(
    key: ValueKey('register-${kind.routeValue}'),
    name: pageName,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FeedingRegisterCubit(
            saveRegisterEvent: save,
            babyId: babyId,
          ),
        ),
        BlocProvider(
          create: (_) => SleepRegisterCubit(
            saveRegisterEvent: save,
            babyId: babyId,
          ),
        ),
        BlocProvider(
          create: (_) => DiaperRegisterCubit(
            saveRegisterEvent: save,
            babyId: babyId,
          ),
        ),
        BlocProvider(
          create: (_) => ClinicalObservationRegisterCubit(
            saveRegisterEvent: save,
            babyId: babyId,
          ),
        ),
        BlocProvider(
          create: (_) => MedicationRegisterCubit(
            saveRegisterEvent: save,
            babyId: babyId,
          ),
        ),
        BlocProvider(
          create: (_) => MeasurementRegisterCubit(
            saveRegisterEvent: save,
            babyId: babyId,
          ),
        ),
      ],
      child: Builder(
        builder: (pageContext) => RegisterPageView(
          initialKind: kind,
          babyName: babyName,
          babyAge: babyAge,
          familyContextLabel: familyContextLabel,
          onKindChanged: (nextKind) => _openKind(pageContext, kind, nextKind),
          onSaved: (event) => onSaved(pageContext, event),
          onCancel: () => onCancel(pageContext),
          onNotificationsPressed: onNotificationsPressed == null
              ? null
              : () => onNotificationsPressed(pageContext),
          onHomePressed:
              onHomePressed == null ? null : () => onHomePressed(pageContext),
          onAgendaPressed: onAgendaPressed == null
              ? null
              : () => onAgendaPressed(pageContext),
          onHealthPressed: onHealthPressed == null
              ? null
              : () => onHealthPressed(pageContext),
          onFamilyPressed: onFamilyPressed == null
              ? null
              : () => onFamilyPressed(pageContext),
        ),
      ),
    ),
  );
}

void _openKind(
  BuildContext context,
  RegisterEventKind currentKind,
  RegisterEventKind nextKind,
) {
  if (currentKind == nextKind) {
    return;
  }

  if (currentKind == RegisterEventKind.feeding) {
    context.push(RegisterPage.locationFor(nextKind));
    return;
  }

  if (nextKind == RegisterEventKind.feeding) {
    context.pop();
    return;
  }

  context.replace(RegisterPage.locationFor(nextKind));
}
