import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';

typedef HealthBlocFactory = HealthBloc Function(BuildContext context);
typedef HealthRouteAction = void Function(BuildContext context);

class HealthPage extends GoRoute {
  HealthPage({
    required HealthBlocFactory healthBloc,
    required HealthRouteAction openVaccines,
    required HealthRouteAction openControls,
    required HealthRouteAction openGrowth,
    required HealthRouteAction openConsultations,
    required HealthRouteAction openPediatricCare,
    required HealthRouteAction openAgenda,
    required HealthRouteAction openClinicalHistory,
    super.name,
    super.routes,
  }) : super(
         path: fullPath,
         pageBuilder: (context, state) {
           return CupertinoPage<void>(
             key: const ValueKey('health'),
             name: name ?? nameRoute,
             child: BlocProvider(
               create: (context) =>
                   healthBloc(context)..add(const HealthEvent.started()),
               child: HealthView(
                 onVaccinesPressed: () => openVaccines(context),
                 onControlsPressed: () => openControls(context),
                 onGrowthPressed: () => openGrowth(context),
                 onConsultationsPressed: () => openConsultations(context),
                 onPediatricCarePressed: () => openPediatricCare(context),
                 onAgendaPressed: () => openAgenda(context),
                 onClinicalHistoryPressed: () => openClinicalHistory(context),
               ),
             ),
           );
         },
       );

  static const nameRoute = 'Health';
  static const fullPath = '/health';

  static void open(BuildContext context) => context.go(fullPath);
}
