import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
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
        final all = widget.controller.vaccines;
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
            const HealthEmptyState(
              title: 'No hay vacunas en esta categoría',
              description:
                  'Las vacunas registradas o programadas aparecerán aquí.',
              icon: Icons.vaccines_outlined,
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
                onTap: () {
                  widget.controller.selectHealthEvent(event);
                  widget.openFlow(HealthFlowAction.detail);
                },
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
        final controls = controller.controls;
        return [
          const HealthSectionHeading(
            title: 'Controles de salud',
            subtitle: 'Seguimiento del desarrollo y la salud del bebé',
          ),
          const SizedBox(height: 14),
          if (controls.isEmpty)
            const HealthEmptyState(
              icon: Icons.medical_services_outlined,
              title: 'Aún no hay controles',
              description:
                  'Los controles pediátricos o de crecimiento aparecerán aquí.',
            )
          else
            for (final event in controls) ...[
              HealthActionRow(
                icon: event.type == HealthEventType.growthControl
                    ? Icons.monitor_weight_outlined
                    : Icons.medical_services_outlined,
                title: event.title,
                subtitle:
                    '${event.description} · ${healthDateLabel(event.startsAt)} ${healthTimeLabel(event.startsAt)}',
                trailing: _HealthEventStatus(event.status),
                onTap: () {
                  controller.selectHealthEvent(event);
                  openFlow(HealthFlowAction.detail);
                },
              ),
              const SizedBox(height: 12),
            ],
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
        final measurements = widget.controller.measurements
            .where((measurement) => measurement.type == type)
            .toList(growable: false);
        final latest = measurements.isEmpty ? null : measurements.first;
        final value = latest?.value;
        final unit = type == HealthMeasurementType.weight ? 'kg' : 'cm';
        final color = Theme.of(context).colorScheme.primary;
        return [
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
          if (measurements.isEmpty)
            HealthEmptyState(
              title:
                  'Sin mediciones de ${type == HealthMeasurementType.weight ? 'peso' : 'talla'}',
              description:
                  'Registra la primera medición para comenzar a visualizar la evolución.',
              icon: type == HealthMeasurementType.weight
                  ? Icons.monitor_weight_outlined
                  : Icons.straighten_rounded,
            )
          else
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
                              value == null
                                  ? 'Sin mediciones'
                                  : '${value.toStringAsFixed(type == HealthMeasurementType.weight ? 2 : 1)} $unit',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          healthDateLabel(latest!.recordedAt),
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _GrowthTrendChart(
                    color: color,
                    unit: unit,
                    measurements: measurements.reversed.toList(growable: false),
                  ),
                ],
              ),
            ),
          if (measurements.isNotEmpty) ...[
            const SizedBox(height: 20),
            const HealthSectionHeading(title: 'Últimas mediciones'),
            const SizedBox(height: 12),
            HealthSurface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final item in measurements)
                    _MeasurementRow(
                      value: item.value,
                      unit: unit,
                      date: item.recordedAt,
                      status: item.syncStatus,
                      onTap: () {
                        widget.controller.selectMeasurement(item);
                        widget.openFlow(HealthFlowAction.detail);
                      },
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
                      'La curva muestra únicamente las mediciones registradas para este bebé.',
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        final consultations = controller.consultations;
        final now = DateTime.now();
        final upcoming = controller.controls
            .where(
              (event) =>
                  event.status == HealthEventStatus.scheduled &&
                  !event.startsAt.isBefore(now),
            )
            .firstOrNull;
        return [
          if (upcoming != null)
            HealthSurface(
              color: Theme.of(context).colorScheme.primaryContainer,
              onTap: () {
                controller.selectHealthEvent(upcoming);
                openFlow(HealthFlowAction.detail);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 38,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Próxima consulta',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${upcoming.title} · ${healthDateLabel(upcoming.startsAt)} · ${healthTimeLabel(upcoming.startsAt)}',
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            )
          else
            const HealthEmptyState(
              title: 'Sin próximas consultas',
              description:
                  'Cuando programes un control, lo verás destacado aquí.',
              icon: Icons.event_busy_outlined,
            ),
          const SizedBox(height: 24),
          HealthSectionHeading(
            title: 'Historial reciente',
            subtitle: consultations.isEmpty
                ? 'Aún no hay consultas guardadas'
                : '${consultations.length} consultas registradas',
          ),
          const SizedBox(height: 14),
          if (consultations.isEmpty)
            const HealthEmptyState(
              title: 'Aún no hay consultas guardadas',
              description:
                  'Registra una consulta para conservar sus indicaciones y seguimiento.',
              icon: Icons.medical_information_outlined,
            )
          else
            for (final consultation in consultations) ...[
              HealthActionRow(
                icon: Icons.medical_information_outlined,
                title: consultation.title,
                subtitle:
                    '${healthDateLabel(consultation.occurredAt)} · ${consultation.pediatrician}',
                trailing: HealthSyncBadge(
                  status: consultation.syncStatus,
                  compact: true,
                ),
                onTap: () {
                  controller.selectConsultation(consultation);
                  openFlow(HealthFlowAction.detail);
                },
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
      builder: (context) {
        final pediatricians = controller.pediatricians;
        return [
          HealthSectionHeading(
            title: 'Mis pediatras',
            subtitle: pediatricians.isEmpty
                ? 'No hay profesionales guardados'
                : '${pediatricians.length} profesionales vinculados al historial',
          ),
          const SizedBox(height: 16),
          if (pediatricians.isEmpty)
            const HealthEmptyState(
              title: 'Aún no hay pediatras',
              description:
                  'Guarda un profesional o registra una consulta para verlo aquí.',
              icon: Icons.medical_services_outlined,
            )
          else
            for (final pediatrician in pediatricians) ...[
              HealthSurface(
                onTap: () {
                  controller.selectPediatrician(pediatrician);
                  openFlow(HealthFlowAction.detail);
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colors.primaryContainer,
                      child: Text(
                        pediatrician.name.characters.first.toUpperCase(),
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pediatrician.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            pediatrician.specialty,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            pediatrician.consultationCount == 0
                                ? 'Sin consultas asociadas'
                                : '${pediatrician.consultationCount} ${pediatrician.consultationCount == 1 ? 'consulta' : 'consultas'} · Última ${healthDateLabel(pediatrician.lastConsultationAt!)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          if (pediatrician.place != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              pediatrician.place!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 8),
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
            onPressed: pediatricians.isEmpty
                ? null
                : () => openFlow(HealthFlowAction.compare),
          ),
        ];
      },
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
              onTap: () {
                controller.selectHealthEvent(event);
                openFlow(HealthFlowAction.detail);
              },
            ),
          for (final record in controller.reportableRecords.take(12))
            _HistoryItem(
              title: _historyTitle(record),
              subtitle: _historySubtitle(record),
              occurredAt: record.occurredAt,
              icon: _historyIcon(record.type),
              color: _historyColor(context, record.type),
              syncStatus: record.syncStatus,
              onTap: () {
                controller.selectRecord(record);
                openFlow(HealthFlowAction.detail);
              },
            ),
        ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
        return [
          const HealthSectionHeading(
            title: 'Historial clínico',
            subtitle: 'Vacunas, consultas, mediciones y observaciones',
          ),
          const SizedBox(height: 14),
          if (timeline.isEmpty)
            const HealthEmptyState(
              icon: Icons.folder_open_outlined,
              title: 'Aún no hay historial',
              description: 'Los registros de salud aparecerán aquí.',
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
                onTap: item.onTap,
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
        final report = controller.reportSnapshot;
        final feedings = report.feedings.length;
        final completedSleeps = report.completedSleeps.length;
        final activeSleeps = report.activeSleeps.length;
        final diapers = report.diapers.length;
        final totalFeedingMl = report.feedingVolumeMl;
        final totalSleepMinutes = report.sleepDurationMinutes;
        final clinicalNotesInRange = report.clinicalNotes;
        final feedingTrend = report.dailyCounts(RegisterEventType.feeding);
        final sleepTrend = report.dailyCounts(RegisterEventType.sleep);
        final diaperTrend = report.dailyCounts(RegisterEventType.diaper);
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
          if (report.records.isEmpty) ...[
            const HealthEmptyState(
              title: 'Sin actividad en este período',
              description:
                  'Cambia el rango o agrega registros para generar tendencias y totales.',
              icon: Icons.insights_outlined,
            ),
            const SizedBox(height: 18),
          ],
          BebeMetricsOverview(
            minimumItemWidth: 96,
            maximumColumnCount: 3,
            semanticLabel: 'Resumen del reporte',
            children: [
              BebeCompactMetricCard(
                label: 'Alimentación',
                value: totalFeedingMl == null
                    ? (feedings == 0 ? '—' : '$feedings')
                    : '${totalFeedingMl.round()}',
                unit: totalFeedingMl == null ? null : 'mL',
                supportingText: feedings == 0
                    ? 'Sin registros en este período'
                    : '$feedings tomas',
                icon: const Icon(Icons.local_drink_outlined),
                variant: BebeMetricCardVariant.feeding,
              ),
              BebeCompactMetricCard(
                label: 'Sueño',
                value: totalSleepMinutes == null
                    ? '—'
                    : _sleepDurationLabel(totalSleepMinutes),
                supportingText: completedSleeps == 0
                    ? activeSleeps == 0
                          ? 'Sin registros en este período'
                          : '$activeSleeps en curso · aún no sumado'
                    : '$completedSleeps sesiones finalizadas'
                          '${activeSleeps == 0 ? '' : ' · $activeSleeps en curso'}',
                icon: const Icon(Icons.bedtime_outlined),
                variant: BebeMetricCardVariant.sleep,
              ),
              BebeCompactMetricCard(
                label: 'Pañales',
                value: diapers == 0 ? '—' : '$diapers',
                supportingText: diapers == 0
                    ? 'Sin registros en este período'
                    : '$diapers cambios',
                icon: const Icon(Icons.water_drop_outlined),
                variant: BebeMetricCardVariant.diaper,
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (report.hasActivityTrendData)
            HealthSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tendencias del período',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  _ReportsTrendChart(
                    primary: colors.primary,
                    secondary: colors.secondary,
                    tertiary: colors.tertiary,
                    feeding: feedingTrend,
                    sleep: sleepTrend,
                    diaper: diaperTrend,
                    generatedAt: report.generatedAt,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _ChartLegend(
                        color: colors.primary,
                        label: 'Alimentación',
                      ),
                      _ChartLegend(color: colors.secondary, label: 'Sueño'),
                      _ChartLegend(color: colors.tertiary, label: 'Pañales'),
                    ],
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
          if (clinicalNotesInRange.isEmpty)
            HealthEmptyState(
              icon: Icons.note_alt_outlined,
              title: 'Sin observaciones en el período',
              description:
                  'Agrega una observación para incluirla en el reporte.',
              actionLabel: 'Nueva observación',
              onActionPressed: () => openFlow(HealthFlowAction.observation),
            )
          else
            for (final event in clinicalNotesInRange.take(3)) ...[
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
                onTap: () {
                  controller.selectRecord(event);
                  openFlow(HealthFlowAction.detail);
                },
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
    this.onTap,
  });

  final String title;
  final String subtitle;
  final DateTime occurredAt;
  final IconData icon;
  final Color color;
  final RegisterSyncStatus? syncStatus;
  final VoidCallback? onTap;
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

String _sleepDurationLabel(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) return '$remainder min';
  if (remainder == 0) return '$hours h';
  return '$hours h $remainder min';
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const SizedBox.square(dimension: 9),
      ),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}

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

class _GrowthTrendChart extends StatelessWidget {
  const _GrowthTrendChart({
    required this.color,
    required this.unit,
    required this.measurements,
  });

  final Color color;
  final String unit;
  final List<HealthMeasurementRecord> measurements;

  @override
  Widget build(BuildContext context) {
    final values = measurements.map((item) => item.value).toList();
    final minimum = values.reduce(math.min);
    final maximum = values.reduce(math.max);
    final spread = math
        .max(maximum - minimum, unit == 'kg' ? 0.5 : 2.0)
        .toDouble();
    final minY = math.max(0, minimum - spread * 0.35).toDouble();
    final maxY = maximum + spread * 0.35;
    final interval = math.max((maxY - minY) / 4, unit == 'kg' ? 0.1 : 1.0);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final labelStep = measurements.length <= 5
        ? 1
        : math.max(1, ((measurements.length - 1) / 4).ceil());

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1, measurements.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: colors.outlineVariant.withValues(alpha: 0.5)),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(unit, style: textTheme.labelSmall),
              axisNameSize: 20,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: interval,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(unit == 'kg' ? 1 : 0),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Text('Fecha', style: textTheme.labelSmall),
              axisNameSize: 20,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (value != index ||
                      index >= measurements.length ||
                      (index % labelStep != 0 &&
                          index != measurements.length - 1)) {
                    return const SizedBox.shrink();
                  }
                  final date = measurements[index].recordedAt.toLocal();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => colors.surfaceContainerHighest,
              getTooltipItems: (spots) => spots
                  .map((spot) {
                    final measurement = measurements[spot.x.round()];
                    return LineTooltipItem(
                      '${measurement.value.toStringAsFixed(unit == 'kg' ? 2 : 1)} $unit\n${healthDateLabel(measurement.recordedAt)}',
                      textTheme.labelSmall!.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var index = 0; index < measurements.length; index++)
                  FlSpot(index.toDouble(), measurements[index].value),
              ],
              isCurved: measurements.length > 2,
              preventCurveOverShooting: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.09),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsTrendChart extends StatelessWidget {
  const _ReportsTrendChart({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.feeding,
    required this.sleep,
    required this.diaper,
    required this.generatedAt,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final List<double> feeding;
  final List<double> sleep;
  final List<double> diaper;
  final DateTime generatedAt;

  @override
  Widget build(BuildContext context) {
    final seriesLength = math.max(
      feeding.length,
      math.max(sleep.length, diaper.length),
    );
    final allValues = [...feeding, ...sleep, ...diaper];
    final maximum = allValues.fold<double>(
      0,
      (current, value) => math.max(current, value),
    );
    if (seriesLength == 0 || maximum == 0) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'Sin datos para graficar en este período.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final yInterval = math.max(1, (maximum / 4).ceil()).toDouble();
    final maxY = math.max(yInterval * 4, maximum);
    final xStep = seriesLength <= 7
        ? 1
        : math.max(1, ((seriesLength - 1) / 5).ceil());
    const names = ['Alimentación', 'Sueño', 'Pañales'];

    String dayLabel(int index) {
      if (index < 0 || index >= seriesLength) return '';
      if (seriesLength == 1) return 'Hoy';
      final date = generatedAt.toLocal().subtract(
        Duration(days: seriesLength - index - 1),
      );
      return '${date.day}/${date.month}';
    }

    LineChartBarData bar(List<double> values, Color color) {
      return LineChartBarData(
        spots: [
          for (var index = 0; index < values.length; index++)
            FlSpot(index.toDouble(), values[index]),
        ],
        isCurved: values.length > 2,
        preventCurveOverShooting: true,
        color: color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: seriesLength <= 7),
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.08),
        ),
      );
    }

    return SizedBox(
      height: 240,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1, seriesLength - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colors.outlineVariant.withValues(alpha: 0.55),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text('Cantidad', style: textTheme.labelSmall),
              axisNameSize: 22,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: yInterval,
                getTitlesWidget: (value, meta) => Text(
                  value.round().toString(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Text('Día', style: textTheme.labelSmall),
              axisNameSize: 22,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (value != index ||
                      (index % xStep != 0 && index != seriesLength - 1)) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dayLabel(index),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => colors.surfaceContainerHighest,
              getTooltipItems: (spots) => spots
                  .map(
                    (spot) => LineTooltipItem(
                      '${names[spot.barIndex]}\n${spot.y.round()} registros',
                      textTheme.labelSmall!.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          lineBarsData: [
            bar(feeding, primary),
            bar(sleep, secondary),
            bar(diaper, tertiary),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}
