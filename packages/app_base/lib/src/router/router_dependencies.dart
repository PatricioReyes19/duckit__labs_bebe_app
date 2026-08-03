import 'package:agenda/agenda.dart';
import 'package:app_layout/app_layout.dart';
import 'package:family/family.dart';
import 'package:health/health.dart';
import 'package:home/home.dart';

class RouterDependencies {
  const RouterDependencies({
    required this.appLayoutBloc,
    required this.homeBloc,
    required this.agendaBloc,
    required this.healthBloc,
    required this.familyBloc,
  });

  final AppLayoutBloc Function() appLayoutBloc;
  final HomeBloc Function() homeBloc;
  final AgendaBloc Function() agendaBloc;
  final HealthBloc Function() healthBloc;
  final FamilyBloc Function() familyBloc;
}
