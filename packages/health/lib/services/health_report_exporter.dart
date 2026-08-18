import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:health/clinical_reports/clinical_report_engine.dart';
import 'package:health/clinical_reports/clinical_report_pdf_renderer.dart';
import 'package:health/models/health_flow_controller.dart';
import 'package:share_plus/share_plus.dart';

class HealthReportExporter {
  const HealthReportExporter({
    this.loadAsset,
    this.engine = const ClinicalReportEngine(),
  });

  final Future<ByteData> Function(String key)? loadAsset;
  final ClinicalReportEngine engine;

  Future<void> sharePdf(
    HealthFlowController controller, {
    ClinicalReportRequest? request,
  }) async {
    final resolvedRequest = request ?? defaultRequest(controller);
    final bytes = await buildPdf(controller, request: resolvedRequest);
    await SharePlus.instance.share(
      ShareParams(
        title: 'Informe clínico',
        subject:
            '${_typeLabel(resolvedRequest.type)} de '
            '${controller.activeBaby?.name ?? 'Bebé'}',
        text:
            'Este PDF contiene información personal y de salud del bebé. '
            'Compártelo sólo con personas autorizadas.',
        files: [XFile.fromData(bytes, mimeType: 'application/pdf')],
        fileNameOverrides: [_fileName(controller, resolvedRequest.type, 'pdf')],
      ),
    );
  }

  Future<void> shareCsv(HealthFlowController controller) async {
    final bytes = buildCsv(controller);
    await SharePlus.instance.share(
      ShareParams(
        title: 'Datos de salud',
        subject: 'Datos de salud de ${controller.activeBaby?.name ?? 'Bebé'}',
        files: [XFile.fromData(bytes, mimeType: 'text/csv')],
        fileNameOverrides: [
          _fileName(controller, ClinicalReportType.fullHistory, 'csv'),
        ],
      ),
    );
  }

  Future<Uint8List> buildPdf(
    HealthFlowController controller, {
    ClinicalReportRequest? request,
  }) async {
    final data = buildData(
      controller,
      request: request ?? defaultRequest(controller),
    );
    return ClinicalReportPdfRenderer(loadAsset: loadAsset).render(data);
  }

  ClinicalReportData buildData(
    HealthFlowController controller, {
    required ClinicalReportRequest request,
  }) {
    final baby = controller.activeBaby;
    if (baby == null || baby.id != request.babyId) {
      throw StateError('No existe un bebé activo válido para el informe.');
    }
    return engine.generate(
      request: request,
      baby: baby,
      registerEvents: controller.records,
      healthEvents: controller.overview?.events ?? const [],
      growthPoints: [
        for (final measurement in controller.measurements)
          ClinicalGrowthPoint(
            type: measurement.type.name,
            value: measurement.value,
            unit: measurement.unit,
            recordedAt: measurement.recordedAt,
          ),
      ],
      caregiverNames: {
        for (final member in controller.family?.members ?? const [])
          member.id: member.name,
      },
      generatedAt: request.dateTo,
    );
  }

  ClinicalReportRequest defaultRequest(HealthFlowController controller) {
    final snapshot = controller.reportSnapshot;
    return ClinicalReportRequest(
      babyId: controller.activeBaby?.id ?? '',
      type: ClinicalReportType.pediatricControl,
      dateFrom: snapshot.startsAt,
      dateTo: snapshot.generatedAt,
    );
  }

  Uint8List buildCsv(HealthFlowController controller) {
    final rows = <List<String>>[
      ['fecha', 'hora', 'tipo', 'detalle', 'notas', 'sincronizacion'],
      for (final event in controller.reportSnapshot.records)
        [
          _date(event.occurredAt),
          _time(event.occurredAt),
          _registerTypeLabel(event.type),
          _detail(event),
          event.notes ?? '',
          event.syncStatus.name,
        ],
    ];
    final csv = rows.map((row) => row.map(_escapeCsv).join(',')).join('\r\n');
    return Uint8List.fromList(utf8.encode('\uFEFF$csv'));
  }

  static String _detail(RegisteredEvent event) {
    final amountMl = event.details['amount_ml'];
    if (amountMl != null) return '$amountMl mL';
    for (final key in const ['title', 'description', 'value', 'amount']) {
      final value = event.details[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return event.notes ?? 'Registro de salud';
  }

  static String _registerTypeLabel(RegisterEventType type) => switch (type) {
    RegisterEventType.feeding => 'Alimentación',
    RegisterEventType.sleep => 'Sueño',
    RegisterEventType.diaper => 'Pañal',
    RegisterEventType.clinicalObservation => 'Observación clínica',
    RegisterEventType.medication => 'Medicamento',
    RegisterEventType.measurement => 'Medición',
  };

  static String _typeLabel(ClinicalReportType type) => switch (type) {
    ClinicalReportType.pediatricControl => 'Control pediátrico',
    ClinicalReportType.symptomConsultation => 'Consulta por síntomas',
    ClinicalReportType.medicationFollowUp => 'Seguimiento de medicamentos',
    ClinicalReportType.growthNutrition => 'Crecimiento y nutrición',
    ClinicalReportType.fullHistory => 'Historial completo',
  };

  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  static String _escapeCsv(String value) =>
      '"${value.replaceAll('"', '""').replaceAll('\r', ' ').replaceAll('\n', ' ')}"';

  static String _fileName(
    HealthFlowController controller,
    ClinicalReportType type,
    String extension,
  ) {
    final baby = (controller.activeBaby?.name ?? 'bebe')
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '_');
    final typeName = type.name.replaceAllMapped(
      RegExp('[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
    final now = controller.reportSnapshot.generatedAt.toLocal();
    return 'informe_${typeName}_${baby}_${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}.$extension';
  }
}
