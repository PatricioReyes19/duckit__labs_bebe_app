import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health/models/health_flow_controller.dart';
import 'package:health/pages/views/health_flow_detail_views.dart';
import 'package:health/pages/views/health_section_views.dart';

enum HealthSectionKind {
  vaccines,
  controls,
  growth,
  consultations,
  pediatricCare,
  clinicalHistory,
  reports,
  sync,
}

extension HealthSectionKindPresentation on HealthSectionKind {
  String get relativePath => switch (this) {
    HealthSectionKind.vaccines => 'vaccines',
    HealthSectionKind.controls => 'controls',
    HealthSectionKind.growth => 'growth',
    HealthSectionKind.consultations => 'consultations',
    HealthSectionKind.pediatricCare => 'pediatric-care',
    HealthSectionKind.clinicalHistory => 'clinical-history',
    HealthSectionKind.reports => 'reports',
    HealthSectionKind.sync => 'sync',
  };

  String get title => switch (this) {
    HealthSectionKind.vaccines => 'Vacunas',
    HealthSectionKind.controls => 'Controles',
    HealthSectionKind.growth => 'Crecimiento',
    HealthSectionKind.consultations => 'Consultas',
    HealthSectionKind.pediatricCare => 'Atención pediátrica',
    HealthSectionKind.clinicalHistory => 'Historial clínico',
    HealthSectionKind.reports => 'Reportes',
    HealthSectionKind.sync => 'Sincronización',
  };

  IconData get icon => switch (this) {
    HealthSectionKind.vaccines => Icons.vaccines_outlined,
    HealthSectionKind.controls => Icons.medical_services_outlined,
    HealthSectionKind.growth => Icons.monitor_weight_outlined,
    HealthSectionKind.consultations => Icons.medical_information_outlined,
    HealthSectionKind.pediatricCare => Icons.child_care_outlined,
    HealthSectionKind.clinicalHistory => Icons.history_outlined,
    HealthSectionKind.reports => Icons.insights_rounded,
    HealthSectionKind.sync => Icons.sync_rounded,
  };
}

abstract final class HealthFlowAction {
  static const detail = 'detail';
  static const register = 'register';
  static const registerWeight = 'register-weight';
  static const registerHeight = 'register-height';
  static const success = 'success';
  static const sync = 'sync';
  static const history = 'history';
  static const reports = 'reports';
  static const export = 'export';
  static const exported = 'exported';
  static const observation = 'observation';
  static const compare = 'compare';
}

class HealthSectionPage extends GoRoute {
  HealthSectionPage({
    required HealthSectionKind kind,
    required HealthFlowController controller,
    required void Function(BuildContext context) openMeasurementRegister,
  }) : super(
         path: kind.relativePath,
         pageBuilder: (context, state) => MaterialPage<void>(
           key: ValueKey('health-${kind.name}'),
           name: 'Health${kind.name}',
           child: _HealthSectionView(
             kind: kind,
             controller: controller,
             openFlow: (action) => _openFlow(
               context,
               kind,
               action,
               openMeasurementRegister: openMeasurementRegister,
             ),
           ),
         ),
         routes: [
           GoRoute(
             path: ':action',
             pageBuilder: (context, state) {
               final action =
                   state.pathParameters['action'] ?? HealthFlowAction.detail;
               return MaterialPage<void>(
                 key: ValueKey('health-${kind.name}-$action'),
                 name: 'Health${kind.name}-$action',
                 child: HealthFlowDetailView(
                   kind: kind,
                   action: action,
                   controller: controller,
                   openFlow: (nextAction) => _openFlow(
                     context,
                     kind,
                     nextAction,
                     openMeasurementRegister: openMeasurementRegister,
                   ),
                 ),
               );
             },
           ),
         ],
       );

  static String locationFor(HealthSectionKind kind) =>
      '/health/${kind.relativePath}';

  static String flowLocation(HealthSectionKind kind, String action) =>
      '${locationFor(kind)}/$action';

  static void _openFlow(
    BuildContext context,
    HealthSectionKind currentKind,
    String action, {
    required void Function(BuildContext context) openMeasurementRegister,
  }) {
    if (action == HealthFlowAction.registerWeight ||
        action == HealthFlowAction.registerHeight ||
        (currentKind == HealthSectionKind.growth &&
            action == HealthFlowAction.register)) {
      openMeasurementRegister(context);
      return;
    }
    final targetKind = switch (action) {
      HealthFlowAction.sync => HealthSectionKind.sync,
      HealthFlowAction.history => HealthSectionKind.clinicalHistory,
      HealthFlowAction.reports => HealthSectionKind.reports,
      _ => currentKind,
    };
    final isSectionDestination =
        action == HealthFlowAction.sync ||
        action == HealthFlowAction.history ||
        action == HealthFlowAction.reports;
    final location = isSectionDestination
        ? locationFor(targetKind)
        : flowLocation(targetKind, action);
    if (action == HealthFlowAction.success ||
        action == HealthFlowAction.exported) {
      context.pushReplacement(location);
      return;
    }
    context.push(location);
  }
}

class _HealthSectionView extends StatelessWidget {
  const _HealthSectionView({
    required this.kind,
    required this.controller,
    required this.openFlow,
  });

  final HealthSectionKind kind;
  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) => switch (kind) {
    HealthSectionKind.vaccines => VaccinesSectionView(
      controller: controller,
      openFlow: openFlow,
    ),
    HealthSectionKind.controls => ControlsSectionView(
      controller: controller,
      openFlow: openFlow,
    ),
    HealthSectionKind.growth => GrowthSectionView(
      controller: controller,
      openFlow: openFlow,
    ),
    HealthSectionKind.consultations => ConsultationsSectionView(
      controller: controller,
      openFlow: openFlow,
    ),
    HealthSectionKind.pediatricCare => PediatricCareSectionView(
      controller: controller,
      openFlow: openFlow,
    ),
    HealthSectionKind.clinicalHistory => ClinicalHistorySectionView(
      controller: controller,
      openFlow: openFlow,
    ),
    HealthSectionKind.reports => ReportsSectionView(
      controller: controller,
      openFlow: openFlow,
    ),
    HealthSectionKind.sync => SyncSectionView(
      controller: controller,
      openFlow: openFlow,
    ),
  };
}
