import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:health/models/health_flow_controller.dart';
import 'package:health/pages/health_section_page.dart';
import 'package:health/pages/views/health_flow_widgets.dart';

typedef HealthFlowNavigator = void Function(String action);

class VaccinesSectionView extends StatefulWidget {
  const VaccinesSectionView({
    required this.controller,
    required this.openFlow,
    super.key,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  State<VaccinesSectionView> createState() => _VaccinesSectionViewState();
}

class _VaccinesSectionViewState extends State<VaccinesSectionView> {
  int filter = 0;

  @override
  Widget build(BuildContext context) {
    return HealthFlowBody(
      controller: widget.controller,
      builder: (context) {
        final all =
            widget.controller.overview?.events
                .where((event) => event.type == HealthEventType.vaccine)
                .toList(growable: false) ??
            const <HealthEventEntity>[];
        final visible = switch (filter) {
          1 =>
            all
                .where((event) => event.status == HealthEventStatus.scheduled)
                .toList(growable: false),
          2 =>
            all
                .where((event) => event.status == HealthEventStatus.completed)
                .toList(growable: false),
          _ => all,
        };
        return [
          HealthBabyBanner(controller: widget.controller),
          const SizedBox(height: 18),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Todas')),
              ButtonSegment(value: 1, label: Text('Próximas')),
              ButtonSegment(value: 2, label: Text('Aplicadas')),
            ],
            selected: {filter},
            showSelectedIcon: false,
            onSelectionChanged: (value) => setState(() => filter = value.first),
          ),
          const SizedBox(height: 24),
          HealthSectionHeading(
            title: filter == 2 ? 'Vacunas aplicadas' : 'Calendario de vacunas',
            subtitle: '${visible.length} registros para el perfil activo',
          ),
          const SizedBox(height: 14),
          if (visible.isEmpty)
            HealthSurface(
              child: Column(
                children: [
                  Icon(
                    Icons.vaccines_outlined,
                    size: 52,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text('No hay vacunas en esta categoría.'),
                ],
              ),
            )
          else
            for (final event in visible) ...[
              HealthActionRow(
                icon: event.status == HealthEventStatus.completed
                    ? Icons.verified_outlined
                    : Icons.vaccines_outlined,
                title: event.title,
                subtitle:
                    '${event.description} · ${healthDateLabel(event.startsAt)}',
                trailing: _HealthEventStatus(event.status),
                onTap: () => widget.openFlow(HealthFlowAction.detail),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 10),
          HealthPrimaryButton(
            label: 'Registrar vacuna aplicada',
            icon: Icons.vaccines_outlined,
            onPressed: () => widget.openFlow(HealthFlowAction.register),
          ),
          const SizedBox(height: 12),
          HealthPrimaryButton(
            label: 'Recordatorios y sincronización',
            icon: Icons.notifications_active_outlined,
            outlined: true,
            onPressed: () => widget.openFlow(HealthFlowAction.sync),
          ),
        ];
      },
    );
  }
}

class ControlsSectionView extends StatelessWidget {
  const ControlsSectionView({
    required this.controller,
    required this.openFlow,
    super.key,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    return HealthFlowBody(
      controller: controller,
      builder: (context) {
        final controls =
            controller.overview?.events
                .where(
                  (event) => event.type == HealthEventType.pediatricControl,
                )
                .toList(growable: false) ??
            const <HealthEventEntity>[];
        return [
          HealthBabyBanner(controller: controller),
          const SizedBox(height: 24),
          const HealthSectionHeading(
            title: 'Próximos controles',
            subtitle: 'Seguimiento del desarrollo y la salud del bebé',
          ),
          const SizedBox(height: 14),
          if (controls.isEmpty)
            const HealthActionRow(
              icon: Icons.medical_services_outlined,
              title: 'Control de 4 meses',
              subtitle: 'Pediatría · Fecha por programar',
            )
          else
            for (final event in controls) ...[
              HealthActionRow(
                icon: Icons.medical_services_outlined,
                title: event.title,
                subtitle:
                    '${event.description} · ${healthDateLabel(event.startsAt)} ${healthTimeLabel(event.startsAt)}',
                onTap: () => openFlow(HealthFlowAction.detail),
              ),
              const SizedBox(height: 12),
            ],
          const HealthActionRow(
            icon: Icons.restaurant_outlined,
            title: 'Control de crecimiento',
            subtitle: 'Nutrición · Seguimiento recomendado',
          ),
          const SizedBox(height: 12),
          HealthActionRow(
            icon: Icons.history_rounded,
            title: 'Ver controles anteriores',
            subtitle: 'Consulta el historial clínico completo',
            onTap: () => openFlow(HealthFlowAction.history),
          ),
          const SizedBox(height: 20),
          HealthPrimaryButton(
            label: 'Registrar nueva consulta',
            icon: Icons.add_rounded,
            onPressed: () => openFlow(HealthFlowAction.register),
          ),
        ];
      },
    );
  }
}

class GrowthSectionView extends StatefulWidget {
  const GrowthSectionView({
    required this.controller,
    required this.openFlow,
    super.key,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  State<GrowthSectionView> createState() => _GrowthSectionViewState();
}

class _GrowthSectionViewState extends State<GrowthSectionView> {
  HealthMeasurementType type = HealthMeasurementType.weight;

  @override
  Widget build(BuildContext context) {
    return HealthFlowBody(
      controller: widget.controller,
      builder: (context) {
        final measurements = _measurements(widget.controller, type);
        final latest = measurements.isEmpty ? null : measurements.first;
        final value =
            latest?.$1 ?? (type == HealthMeasurementType.weight ? 7.25 : 65.0);
        final unit = type == HealthMeasurementType.weight ? 'kg' : 'cm';
        final color = Theme.of(context).colorScheme.primary;
        return [
          HealthBabyBanner(controller: widget.controller),
          const SizedBox(height: 18),
          SegmentedButton<HealthMeasurementType>(
            segments: const [
              ButtonSegment(
                value: HealthMeasurementType.weight,
                label: Text('Peso'),
                icon: Icon(Icons.monitor_weight_outlined),
              ),
              ButtonSegment(
                value: HealthMeasurementType.height,
                label: Text('Talla'),
                icon: Icon(Icons.straighten_rounded),
              ),
            ],
            selected: {type},
            onSelectionChanged: (value) => setState(() => type = value.first),
          ),
          const SizedBox(height: 18),
          HealthSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        type == HealthMeasurementType.weight
                            ? Icons.monitor_weight_outlined
                            : Icons.straighten_rounded,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type == HealthMeasurementType.weight
                                ? 'Peso actual'
                                : 'Talla actual',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${value.toStringAsFixed(type == HealthMeasurementType.weight ? 2 : 1)} $unit',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'P41',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text('Percentil'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _GrowthChartPainter(color: color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const HealthSectionHeading(title: 'Últimas mediciones'),
          const SizedBox(height: 12),
          HealthSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                if (measurements.isEmpty)
                  for (final item in _sampleMeasurements(type))
                    _MeasurementRow(
                      value: item.$1,
                      unit: unit,
                      date: item.$2,
                      status: RegisterSyncStatus.synced,
                      onTap: () => widget.openFlow(HealthFlowAction.detail),
                    )
                else
                  for (final item in measurements)
                    _MeasurementRow(
                      value: item.$1,
                      unit: unit,
                      date: item.$2,
                      status: item.$3,
                      onTap: () => widget.openFlow(HealthFlowAction.detail),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HealthSurface(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Row(
              children: [
                Icon(Icons.auto_graph_rounded),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Curva basada en referencias OMS. Lo importante es mantener una tendencia estable.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          HealthPrimaryButton(
            label: 'Registrar medición',
            icon: Icons.add_circle_outline_rounded,
            onPressed: () => widget.openFlow(
              type == HealthMeasurementType.weight
                  ? HealthFlowAction.registerWeight
                  : HealthFlowAction.registerHeight,
            ),
          ),
        ];
      },
    );
  }
}

class ConsultationsSectionView extends StatelessWidget {
  const ConsultationsSectionView({
    required this.controller,
    required this.openFlow,
    super.key,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    return HealthFlowBody(
      controller: controller,
      builder: (context) {
        final consultations = controller.clinicalRecords
            .where(
              (event) =>
                  event.details['observation_type'] == 'medical_consultation',
            )
            .toList(growable: false);
        return [
          HealthBabyBanner(controller: controller),
          const SizedBox(height: 20),
          HealthSurface(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 38,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próxima consulta',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 3),
                      Text('Control pediátrico · 12 jun · 11:30'),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),
          HealthSectionHeading(
            title: 'Historial reciente',
            subtitle: consultations.isEmpty
                ? 'Aún no hay consultas guardadas'
                : '${consultations.length} consultas registradas',
          ),
          const SizedBox(height: 14),
          if (consultations.isEmpty) ...[
            HealthActionRow(
              icon: Icons.medical_information_outlined,
              title: 'Control pediátrico',
              subtitle: 'Consulta de ejemplo · Dra. Valeria Ruiz',
              onTap: () => openFlow(HealthFlowAction.detail),
            ),
            const SizedBox(height: 12),
          ] else
            for (final consultation in consultations) ...[
              HealthActionRow(
                icon: Icons.medical_information_outlined,
                title: _detailText(
                  consultation,
                  'title',
                  'Consulta pediátrica',
                ),
                subtitle:
                    '${healthDateLabel(consultation.occurredAt)} · ${_detailText(consultation, 'pediatrician', 'Pediatra')}',
                trailing: HealthSyncBadge(
                  status: consultation.syncStatus,
                  compact: true,
                ),
                onTap: () => openFlow(HealthFlowAction.detail),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 8),
          HealthPrimaryButton(
            label: 'Registrar nueva consulta',
            icon: Icons.add_rounded,
            onPressed: () => openFlow(HealthFlowAction.register),
          ),
          const SizedBox(height: 12),
          HealthPrimaryButton(
            label: 'Ver reportes de salud',
            icon: Icons.bar_chart_rounded,
            outlined: true,
            onPressed: () => openFlow(HealthFlowAction.reports),
          ),
        ];
      },
    );
  }
}

class PediatricCareSectionView extends StatelessWidget {
  const PediatricCareSectionView({
    required this.controller,
    required this.openFlow,
    super.key,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return HealthFlowBody(
      controller: controller,
      builder: (context) => [
        const HealthSectionHeading(
          title: 'Mis pediatras',
          subtitle: 'Profesionales y centros guardados para el bebé',
        ),
        const SizedBox(height: 16),
        HealthSurface(
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: colors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dra. Valeria Ruiz',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text('Pediatría general'),
                        SizedBox(height: 5),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber),
                            Text('5.0 · 4 consultas'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => openFlow(HealthFlowAction.detail),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const Divider(height: 28),
              const Row(
                children: [
                  Icon(Icons.location_on_outlined),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Clínica infantil · Atención pediátrica'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        HealthActionRow(
          icon: Icons.local_hospital_outlined,
          title: 'Clínica infantil',
          subtitle: 'Av. del Sol 123 · Atención pediátrica integral',
          tint: colors.tertiary,
          onTap: () => openFlow(HealthFlowAction.detail),
        ),
        const SizedBox(height: 20),
        HealthPrimaryButton(
          label: 'Agregar pediatra',
          icon: Icons.person_add_alt_1_rounded,
          onPressed: () => openFlow(HealthFlowAction.register),
        ),
        const SizedBox(height: 12),
        HealthPrimaryButton(
          label: 'Comparar experiencias',
          icon: Icons.compare_arrows_rounded,
          outlined: true,
          onPressed: () => openFlow(HealthFlowAction.compare),
        ),
      ],
    );
  }
}

class ClinicalHistorySectionView extends StatelessWidget {
  const ClinicalHistorySectionView({
    required this.controller,
    required this.openFlow,
    super.key,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    return HealthFlowBody(
      controller: controller,
      builder: (context) {
        final events = controller.overview?.events ?? const [];
        final timeline = <_HistoryItem>[
          for (final event in events)
            _HistoryItem(
              title: event.title,
              subtitle: event.description,
              occurredAt: event.startsAt,
              icon: switch (event.type) {
                HealthEventType.vaccine => Icons.vaccines_outlined,
                HealthEventType.pediatricControl =>
                  Icons.medical_services_outlined,
                HealthEventType.growthControl => Icons.monitor_weight_outlined,
              },
              color: Theme.of(context).colorScheme.primary,
            ),
          for (final record in controller.records.take(12))
            _HistoryItem(
              title: _historyTitle(record),
              subtitle: _historySubtitle(record),
              occurredAt: record.occurredAt,
              icon: _historyIcon(record.type),
              color: _historyColor(context, record.type),
              syncStatus: record.syncStatus,
            ),
        ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
        return [
          HealthBabyBanner(controller: controller),
          const SizedBox(height: 20),
          const HealthSectionHeading(
            title: 'Historial clínico',
            subtitle: 'Vacunas, consultas, mediciones y observaciones',
          ),
          const SizedBox(height: 14),
          if (timeline.isEmpty)
            const HealthActionRow(
              icon: Icons.folder_open_outlined,
              title: 'Aún no hay historial',
              subtitle: 'Los registros de salud aparecerán aquí.',
            )
          else
            for (final item in timeline.take(16)) ...[
              HealthActionRow(
                icon: item.icon,
                title: item.title,
                subtitle:
                    '${healthDateLabel(item.occurredAt)} · ${item.subtitle}',
                tint: item.color,
                trailing: item.syncStatus == null
                    ? null
                    : HealthSyncBadge(status: item.syncStatus!, compact: true),
                onTap: () => openFlow(HealthFlowAction.detail),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 10),
          HealthPrimaryButton(
            label: 'Abrir reportes',
            icon: Icons.insights_rounded,
            onPressed: () => openFlow(HealthFlowAction.reports),
          ),
        ];
      },
    );
  }
}

class ReportsSectionView extends StatelessWidget {
  const ReportsSectionView({
    required this.controller,
    required this.openFlow,
    super.key,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return HealthFlowBody(
      controller: controller,
      builder: (context) {
        final days = switch (controller.reportRange) {
          HealthReportRange.day => 1,
          HealthReportRange.week => 7,
          HealthReportRange.month => 30,
        };
        final after = DateTime.now().subtract(Duration(days: days));
        int count(RegisterEventType type) => controller.records
            .where(
              (event) => event.type == type && event.occurredAt.isAfter(after),
            )
            .length;
        final feedings = count(RegisterEventType.feeding);
        final sleeps = count(RegisterEventType.sleep);
        final diapers = count(RegisterEventType.diaper);
        return [
          if (controller.offlineMode) ...[
            HealthSurface(
              color: colors.secondaryContainer,
              child: const Row(
                children: [
                  Icon(Icons.cloud_off_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sin conexión · Mostrando datos guardados localmente',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          SegmentedButton<HealthReportRange>(
            segments: const [
              ButtonSegment(value: HealthReportRange.day, label: Text('1 día')),
              ButtonSegment(
                value: HealthReportRange.week,
                label: Text('7 días'),
              ),
              ButtonSegment(
                value: HealthReportRange.month,
                label: Text('30 días'),
              ),
            ],
            selected: {controller.reportRange},
            showSelectedIcon: false,
            onSelectionChanged: (value) =>
                controller.selectReportRange(value.first),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HealthMetricTile(
                  label: 'Alimentación',
                  value: feedings == 0 ? '—' : '$feedings',
                  caption: feedings == 0 ? 'Sin datos' : 'tomas',
                  icon: Icons.local_drink_outlined,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HealthMetricTile(
                  label: 'Sueño',
                  value: sleeps == 0 ? '—' : '$sleeps',
                  caption: sleeps == 0 ? 'Sin datos' : 'registros',
                  icon: Icons.bedtime_outlined,
                  color: colors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HealthMetricTile(
                  label: 'Pañales',
                  value: diapers == 0 ? '—' : '$diapers',
                  caption: diapers == 0 ? 'Sin datos' : 'cambios',
                  icon: Icons.water_drop_outlined,
                  color: colors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          HealthSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tendencias del período',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _ReportsChartPainter(
                      primary: colors.primary,
                      secondary: colors.secondary,
                      tertiary: colors.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          HealthSectionHeading(
            title: 'Observaciones clínicas',
            trailing: TextButton.icon(
              onPressed: () => openFlow(HealthFlowAction.observation),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva'),
            ),
          ),
          const SizedBox(height: 12),
          if (controller.clinicalRecords.isEmpty)
            const HealthActionRow(
              icon: Icons.note_alt_outlined,
              title: 'Sin observaciones en el período',
              subtitle: 'Agrega una observación para incluirla en el reporte.',
            )
          else
            for (final event in controller.clinicalRecords.take(3)) ...[
              HealthActionRow(
                icon: Icons.note_alt_outlined,
                title: _detailText(event, 'title', 'Observación clínica'),
                subtitle: _detailText(
                  event,
                  'description',
                  'Registro del cuidador',
                ),
                trailing: HealthSyncBadge(
                  status: event.syncStatus,
                  compact: true,
                ),
                onTap: () => openFlow(HealthFlowAction.detail),
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 18),
          HealthPrimaryButton(
            label: 'Exportar o compartir reporte',
            icon: Icons.ios_share_rounded,
            onPressed: controller.offlineMode
                ? null
                : () => openFlow(HealthFlowAction.export),
          ),
          const SizedBox(height: 12),
          HealthPrimaryButton(
            label: 'Estado de sincronización',
            icon: Icons.sync_rounded,
            outlined: true,
            onPressed: () => openFlow(HealthFlowAction.sync),
          ),
        ];
      },
    );
  }
}

class SyncSectionView extends StatelessWidget {
  const SyncSectionView({
    required this.controller,
    required this.openFlow,
    super.key,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return HealthFlowBody(
      controller: controller,
      builder: (context) {
        final state = controller.syncState;
        final phaseLabel = switch (state.phase) {
          RegisterSyncPhase.disabled => 'Guardado solo en este dispositivo',
          RegisterSyncPhase.waitingForAuthentication =>
            'Esperando inicio de sesión',
          RegisterSyncPhase.idle => 'Listo para sincronizar',
          RegisterSyncPhase.syncing => 'Sincronizando ahora',
          RegisterSyncPhase.synced => 'Todo está sincronizado',
          RegisterSyncPhase.failed => 'Hay registros con error',
        };
        return [
          HealthSurface(
            color: controller.offlineMode
                ? colors.secondaryContainer
                : colors.primaryContainer,
            child: Row(
              children: [
                Icon(
                  controller.offlineMode
                      ? Icons.cloud_off_outlined
                      : Icons.cloud_done_outlined,
                  size: 40,
                  color: controller.offlineMode
                      ? colors.secondary
                      : colors.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.networkUnavailable
                            ? 'Sin conexión a la red'
                            : controller.offlineMode
                            ? 'Modo sin conexión'
                            : phaseLabel,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        controller.offlineMode
                            ? 'Los cambios quedan seguros y se enviarán al reconectar.'
                            : state.message ??
                                  'Los registros locales y familiares están al día.',
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.offlineMode,
                  onChanged: controller.networkUnavailable
                      ? null
                      : controller.setOfflineMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: HealthMetricTile(
                  label: 'Pendientes',
                  value: '${controller.pendingSyncCount}',
                  icon: Icons.schedule_rounded,
                  color: colors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HealthMetricTile(
                  label: 'Errores',
                  value: '${state.failedCount}',
                  icon: Icons.error_outline_rounded,
                  color: colors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const HealthSectionHeading(
            title: 'Registros recientes',
            subtitle: 'Estado local y de respaldo familiar',
          ),
          const SizedBox(height: 12),
          if (controller.records.isEmpty)
            const HealthActionRow(
              icon: Icons.cloud_done_outlined,
              title: 'No hay registros pendientes',
              subtitle: 'Cuando guardes actividad aparecerá aquí.',
            )
          else
            for (final event in controller.records.take(8)) ...[
              HealthActionRow(
                icon: _historyIcon(event.type),
                title: _historyTitle(event),
                subtitle: healthDateLabel(event.occurredAt),
                trailing: HealthSyncBadge(
                  status: event.syncStatus,
                  compact: true,
                ),
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 16),
          HealthPrimaryButton(
            label: state.phase == RegisterSyncPhase.syncing
                ? 'Sincronizando…'
                : 'Reintentar sincronización',
            icon: Icons.sync_rounded,
            busy: state.phase == RegisterSyncPhase.syncing,
            onPressed: controller.offlineMode ? null : controller.retrySync,
          ),
          const SizedBox(height: 12),
          HealthPrimaryButton(
            label: 'Volver a reportes',
            outlined: true,
            onPressed: () => openFlow(HealthFlowAction.reports),
          ),
        ];
      },
    );
  }
}

class _HealthEventStatus extends StatelessWidget {
  const _HealthEventStatus(this.status);

  final HealthEventStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      HealthEventStatus.completed => ('Aplicada', colors.tertiary),
      HealthEventStatus.scheduled => ('Próxima', colors.secondary),
      HealthEventStatus.cancelled => ('Cancelada', colors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  const _MeasurementRow({
    required this.value,
    required this.unit,
    required this.date,
    required this.status,
    required this.onTap,
  });

  final double value;
  final String unit;
  final DateTime date;
  final RegisterSyncStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.calendar_today_outlined),
        title: Text(healthDateLabel(date)),
        subtitle: Text('${value.toStringAsFixed(2)} $unit'),
        trailing: HealthSyncBadge(status: status, compact: true),
      ),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.occurredAt,
    required this.icon,
    required this.color,
    this.syncStatus,
  });

  final String title;
  final String subtitle;
  final DateTime occurredAt;
  final IconData icon;
  final Color color;
  final RegisterSyncStatus? syncStatus;
}

List<(double, DateTime, RegisterSyncStatus)> _measurements(
  HealthFlowController controller,
  HealthMeasurementType type,
) {
  final result = <(double, DateTime, RegisterSyncStatus)>[];
  for (final event in controller.measurementRecords) {
    if (event.details['measurement_type'] != type.name) continue;
    final value = event.details['value'];
    if (value is num) {
      result.add((value.toDouble(), event.occurredAt, event.syncStatus));
    }
  }
  for (final measurement in controller.overview?.measurements ?? const []) {
    if (measurement.type == type) {
      result.add((
        measurement.value,
        measurement.recordedAt,
        RegisterSyncStatus.synced,
      ));
    }
  }
  result.sort((a, b) => b.$2.compareTo(a.$2));
  return result;
}

List<(double, DateTime)> _sampleMeasurements(HealthMeasurementType type) {
  final now = DateTime.now();
  return type == HealthMeasurementType.weight
      ? [(7.25, now), (6.65, now.subtract(const Duration(days: 30)))]
      : [(65.0, now), (61.8, now.subtract(const Duration(days: 30)))];
}

String _detailText(RegisteredEvent event, String key, String fallback) {
  final value = event.details[key];
  return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
}

String _historyTitle(RegisteredEvent event) => switch (event.type) {
  RegisterEventType.feeding => 'Alimentación registrada',
  RegisterEventType.sleep => 'Sueño registrado',
  RegisterEventType.diaper => 'Cambio de pañal',
  RegisterEventType.clinicalObservation => _detailText(
    event,
    'title',
    'Observación clínica',
  ),
  RegisterEventType.medication => 'Medicamento registrado',
  RegisterEventType.measurement => 'Medición de crecimiento',
};

String _historySubtitle(RegisteredEvent event) => switch (event.type) {
  RegisterEventType.clinicalObservation => _detailText(
    event,
    'description',
    'Registro del cuidador',
  ),
  RegisterEventType.measurement =>
    '${event.details['value'] ?? '—'} ${event.details['unit'] ?? ''}',
  _ => event.notes ?? 'Registro de actividad',
};

IconData _historyIcon(RegisterEventType type) => switch (type) {
  RegisterEventType.feeding => Icons.local_drink_outlined,
  RegisterEventType.sleep => Icons.bedtime_outlined,
  RegisterEventType.diaper => Icons.water_drop_outlined,
  RegisterEventType.clinicalObservation => Icons.note_alt_outlined,
  RegisterEventType.medication => Icons.medication_outlined,
  RegisterEventType.measurement => Icons.monitor_weight_outlined,
};

Color _historyColor(BuildContext context, RegisterEventType type) {
  final colors = Theme.of(context).colorScheme;
  return switch (type) {
    RegisterEventType.feeding => colors.primary,
    RegisterEventType.sleep => colors.secondary,
    RegisterEventType.diaper => colors.tertiary,
    RegisterEventType.clinicalObservation => colors.error,
    RegisterEventType.medication => colors.secondary,
    RegisterEventType.measurement => colors.tertiary,
  };
}

class _GrowthChartPainter extends CustomPainter {
  const _GrowthChartPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = color.withValues(alpha: 0.14)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final percentile = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    for (var line = 0; line < 3; line++) {
      final path = Path();
      for (var i = 0; i <= 6; i++) {
        final x = size.width * i / 6;
        final y = size.height * (0.84 - line * 0.19) - (i * 7.0).clamp(0, 32);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, percentile);
    }
    final actual = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(4, size.height * 0.82)
      ..lineTo(size.width * 0.24, size.height * 0.68)
      ..lineTo(size.width * 0.48, size.height * 0.54);
    canvas.drawPath(path, actual);
    final point = Paint()..color = color;
    for (final offset in [
      Offset(4, size.height * 0.82),
      Offset(size.width * 0.24, size.height * 0.68),
      Offset(size.width * 0.48, size.height * 0.54),
    ]) {
      canvas.drawCircle(offset, 5, point);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ReportsChartPainter extends CustomPainter {
  const _ReportsChartPainter({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = primary.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    void line(Color color, List<double> points) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final x = size.width * i / (points.length - 1);
        final y = size.height * (1 - points[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
      final dot = Paint()..color = color;
      for (var i = 0; i < points.length; i++) {
        canvas.drawCircle(
          Offset(
            size.width * i / (points.length - 1),
            size.height * (1 - points[i]),
          ),
          4,
          dot,
        );
      }
    }

    line(primary, const [0.42, 0.55, 0.50, 0.66, 0.58, 0.70, 0.48]);
    line(secondary, const [0.65, 0.75, 0.52, 0.45, 0.54, 0.62, 0.60]);
    line(tertiary, const [0.20, 0.28, 0.18, 0.20, 0.24, 0.30, 0.22]);
  }

  @override
  bool shouldRepaint(covariant _ReportsChartPainter oldDelegate) =>
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.tertiary != tertiary;
}
