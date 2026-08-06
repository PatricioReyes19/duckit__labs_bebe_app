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
    this.babyId = 'local-active-baby',
    this.babyName = 'Mateo Reyes',
    this.babyAge = '2 meses',
    this.familyContextLabel = '2 bebés en la familia',
    super.name,
    super.parentNavigatorKey,
    super.routes,
  }) : super(
          path: fullPath,
          pageBuilder: (context, state) {
            final save = saveRegisterEvent(context);
            final initialKind = RegisterEventKind.fromRouteValue(
              state.uri.queryParameters['type'],
            );
            return CupertinoPage<void>(
              key: ValueKey('register-${initialKind.routeValue}'),
              name: name ?? nameRoute,
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
                child: RegisterPageView(
                  initialKind: initialKind,
                  babyName: babyName,
                  babyAge: babyAge,
                  familyContextLabel: familyContextLabel,
                  onSaved: (event) => onSaved(context, event),
                  onCancel: () => onCancel(context),
                ),
              ),
            );
          },
        );

  final String babyId;
  final String babyName;
  final String babyAge;
  final String familyContextLabel;

  static const nameRoute = 'Register';
  static const fullPath = '/register';

  static void open(BuildContext context, {RegisterEventKind? kind}) {
    final query = kind == null ? '' : '?type=${kind.routeValue}';
    context.push('$fullPath$query');
  }
}
