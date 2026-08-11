import 'dart:io';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
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
typedef GetFamilyOverviewFactory = GetFamilyOverview Function(
  BuildContext context,
);

class RegisterPage extends GoRoute {
  RegisterPage({
    required SaveRegisterEventFactory saveRegisterEvent,
    required RegisterRouteSaved onSaved,
    required RegisterRouteAction onCancel,
    this.getFamilyOverview,
    this.onNotificationsPressed,
    this.onHomePressed,
    this.onAgendaPressed,
    this.onHealthPressed,
    this.onFamilyPressed,
    this.babyId = 'baby-preview',
    this.babyName = 'Tu bebé',
    this.babyAge = 'Perfil activo',
    this.familyContextLabel = 'Tu familia',
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
            getFamilyOverview: getFamilyOverview,
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
                getFamilyOverview: getFamilyOverview,
              ),
            ),
            ...routes,
          ],
        );

  final String babyId;
  final String babyName;
  final String babyAge;
  final String familyContextLabel;
  final GetFamilyOverviewFactory? getFamilyOverview;
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
  required GetFamilyOverviewFactory? getFamilyOverview,
}) {
  final save = saveRegisterEvent(context);
  return MaterialPage<void>(
    key: ValueKey('register-${kind.routeValue}'),
    name: pageName,
    child: getFamilyOverview == null
        ? _registerContent(
            kind: kind,
            save: save,
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
          )
        : FutureBuilder<FamilyOverviewEntity>(
            future: getFamilyOverview(context)(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final family = snapshot.data;
              if (family == null) {
                return _RegisterContextError(
                  onRetry: () => RegisterPage.open(context, kind: kind),
                );
              }
              final activeBaby = family.activeBaby;
              return _registerContent(
                kind: kind,
                save: save,
                onSaved: onSaved,
                onCancel: onCancel,
                onNotificationsPressed: onNotificationsPressed,
                onHomePressed: onHomePressed,
                onAgendaPressed: onAgendaPressed,
                onHealthPressed: onHealthPressed,
                onFamilyPressed: onFamilyPressed,
                babyId: activeBaby.id,
                babyName: activeBaby.name,
                babyAge: _babyAge(activeBaby.birthDate, DateTime.now()),
                familyContextLabel: family.babies.length == 1
                    ? '1 bebé en la familia'
                    : '${family.babies.length} bebés en la familia',
                babyAvatar: _babyAvatar(activeBaby),
              );
            },
          ),
  );
}

Widget _registerContent({
  required RegisterEventKind kind,
  required SaveRegisterEvent save,
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
  BebeAvatar? babyAvatar,
}) {
  return MultiBlocProvider(
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
        babyAvatar: babyAvatar,
        onKindChanged: (nextKind) => _openKind(pageContext, kind, nextKind),
        onSaved: (event) => onSaved(pageContext, event),
        onCancel: () => onCancel(pageContext),
        onNotificationsPressed: onNotificationsPressed == null
            ? null
            : () => onNotificationsPressed(pageContext),
        onHomePressed:
            onHomePressed == null ? null : () => onHomePressed(pageContext),
        onAgendaPressed:
            onAgendaPressed == null ? null : () => onAgendaPressed(pageContext),
        onHealthPressed:
            onHealthPressed == null ? null : () => onHealthPressed(pageContext),
        onFamilyPressed:
            onFamilyPressed == null ? null : () => onFamilyPressed(pageContext),
      ),
    ),
  );
}

class _RegisterContextError extends StatelessWidget {
  const _RegisterContextError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.child_care_outlined, size: 42),
              const SizedBox(height: 12),
              const Text(
                'No pudimos identificar el perfil activo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
}

BebeAvatar? _babyAvatar(BabyEntity baby) {
  final path = baby.avatarAssetPath;
  if (path == null || path.isEmpty) return null;
  final file = File(path);
  if (!file.existsSync()) return null;
  return BebeAvatar.image(
    image: FileImage(file),
    size: BebeAvatarSize.lg,
    semanticLabel: 'Foto de ${baby.name}',
  );
}

String _babyAge(DateTime birthDate, DateTime referenceDate) {
  final birth = birthDate.toLocal();
  var months = (referenceDate.year - birth.year) * 12 +
      referenceDate.month -
      birth.month;
  if (referenceDate.day < birth.day) months--;
  if (months <= 0) return 'Menos de un mes';
  return months == 1 ? '1 mes' : '$months meses';
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
