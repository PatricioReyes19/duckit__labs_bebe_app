import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum HealthSectionKind {
  vaccines,
  controls,
  growth,
  consultations,
  pediatricCare,
  clinicalHistory,
}

extension HealthSectionKindPresentation on HealthSectionKind {
  String get relativePath => switch (this) {
    HealthSectionKind.vaccines => 'vaccines',
    HealthSectionKind.controls => 'controls',
    HealthSectionKind.growth => 'growth',
    HealthSectionKind.consultations => 'consultations',
    HealthSectionKind.pediatricCare => 'pediatric-care',
    HealthSectionKind.clinicalHistory => 'clinical-history',
  };

  String get title => switch (this) {
    HealthSectionKind.vaccines => 'Vacunas',
    HealthSectionKind.controls => 'Controles',
    HealthSectionKind.growth => 'Crecimiento',
    HealthSectionKind.consultations => 'Consultas',
    HealthSectionKind.pediatricCare => 'Atención pediátrica',
    HealthSectionKind.clinicalHistory => 'Historial clínico',
  };

  IconData get icon => switch (this) {
    HealthSectionKind.vaccines => Icons.vaccines_outlined,
    HealthSectionKind.controls => Icons.medical_services_outlined,
    HealthSectionKind.growth => Icons.monitor_weight_outlined,
    HealthSectionKind.consultations => Icons.medical_information_outlined,
    HealthSectionKind.pediatricCare => Icons.child_care_outlined,
    HealthSectionKind.clinicalHistory => Icons.history_outlined,
  };
}

class HealthSectionPage extends GoRoute {
  HealthSectionPage({required HealthSectionKind kind, super.routes})
    : super(
        path: kind.relativePath,
        pageBuilder: (context, state) => CupertinoPage<void>(
          key: ValueKey('health-${kind.name}'),
          name: 'Health${kind.name}',
          child: _HealthSectionView(kind: kind),
        ),
      );

  static String locationFor(HealthSectionKind kind) =>
      '/health/${kind.relativePath}';
}

class _HealthSectionView extends StatelessWidget {
  const _HealthSectionView({required this.kind});

  final HealthSectionKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surface,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(kind.icon, size: 56, color: colors.primary),
          const SizedBox(height: 16),
          Text(
            kind.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(kind.icon),
                  title: Text(_primaryLabel),
                  subtitle: const Text(
                    'La información queda disponible incluso sin conexión.',
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.sync_rounded),
                  title: Text('Sincronización familiar'),
                  subtitle: Text(
                    'Los cuidadores autorizados verán las actualizaciones.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: Text('Agregar ${kind.title.toLowerCase()}'),
          ),
        ],
      ),
    );
  }

  String get _description => switch (kind) {
    HealthSectionKind.vaccines =>
      'Consulta las vacunas administradas y las próximas dosis.',
    HealthSectionKind.controls =>
      'Revisa controles pediátricos, resultados y recomendaciones.',
    HealthSectionKind.growth =>
      'Sigue la evolución de peso, talla y perímetro cefálico.',
    HealthSectionKind.consultations =>
      'Mantén las consultas médicas y sus indicaciones organizadas.',
    HealthSectionKind.pediatricCare =>
      'Accede rápidamente a la información relevante para una atención.',
    HealthSectionKind.clinicalHistory =>
      'Consulta cronológicamente los antecedentes de salud.',
  };

  String get _primaryLabel => switch (kind) {
    HealthSectionKind.vaccines => 'Esquema de vacunación',
    HealthSectionKind.controls => 'Próximo control',
    HealthSectionKind.growth => 'Última medición',
    HealthSectionKind.consultations => 'Consultas recientes',
    HealthSectionKind.pediatricCare => 'Resumen pediátrico',
    HealthSectionKind.clinicalHistory => 'Actividad clínica reciente',
  };
}
