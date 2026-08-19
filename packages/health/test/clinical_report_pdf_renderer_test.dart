import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/clinical_reports/clinical_report_pdf_renderer.dart';

void main() {
  test('renders a contextual multi-page clinical PDF', () async {
    final renderer = ClinicalReportPdfRenderer(loadAsset: _loadAsset);
    final bytes = await renderer.render(_fixture());

    expect(bytes.length, greaterThan(5000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');

    final outputPath = Platform.environment['BEBEAPP_PDF_QA_OUTPUT'];
    if (outputPath != null && outputPath.isNotEmpty) {
      final output = File(outputPath);
      output.parent.createSync(recursive: true);
      output.writeAsBytesSync(bytes, flush: true);
    }
  });
}

Future<ByteData> _loadAsset(String key) async {
  final candidates = [File(key), File('../../$key')];
  final file = candidates.firstWhere((candidate) => candidate.existsSync());
  final bytes = await file.readAsBytes();
  return ByteData.sublistView(bytes);
}

ClinicalReportData _fixture() {
  final generatedAt = DateTime.utc(2026, 8, 18, 20, 30);
  final from = generatedAt.subtract(const Duration(days: 30));
  return ClinicalReportData(
    reportId: 'qa-contextual-20260818',
    request: ClinicalReportRequest(
      babyId: 'baby-qa',
      type: ClinicalReportType.fullHistory,
      dateFrom: from,
      dateTo: generatedAt,
      includeRawTimeline: true,
    ),
    babyName: 'Mateo Reyes',
    birthDate: DateTime.utc(2026, 5, 18),
    generatedAt: generatedAt,
    summary:
        'Informe clínico contextual de 30 días. Los datos se presentan como '
        'registros de cuidadores y no reemplazan una evaluación médica.',
    feeding: ClinicalFeedingSummary(
      recordCount: 96,
      averagePerDay: 3.2,
      averageVolumeMl: 118.5,
      lastFeedingAt: generatedAt.subtract(const Duration(hours: 2)),
      subtypes: const {'Mamadera': 64, 'Lactancia': 32},
    ),
    elimination: const ClinicalEliminationSummary(
      wetDiapers: 142,
      stools: 34,
      averageWetPerDay: 4.7,
      averageStoolsPerDay: 1.1,
      predominantConsistency: 'Blanda',
      predominantColor: 'Amarillo',
      bloodOrMucusRecorded: false,
      anomalies: ['Dos registros consignaron irritación leve.'],
    ),
    sleep: const ClinicalSleepSummary(
      completedSessions: 82,
      activeSessions: 1,
      averageMinutes: 126,
      averageNightMinutes: 388,
      averageNapsPerDay: 2.1,
    ),
    medications: [
      ClinicalMedicationSummary(
        name: 'Paracetamol pediátrico',
        dose: '2,5',
        unit: 'mL',
        route: 'Oral',
        frequency: 'Cada 8 horas',
        registeredAdministrations: 8,
        unregisteredAdministrations: 1,
        startedAt: generatedAt.subtract(const Duration(days: 3)),
        endedAt: generatedAt,
        lastAdministrationAt: generatedAt.subtract(const Duration(hours: 6)),
        adverseEvents: const ['Somnolencia leve consignada por cuidador.'],
      ),
    ],
    growth: [
      ClinicalGrowthPoint(
        type: 'weight',
        value: 5.8,
        unit: 'kg',
        recordedAt: from,
      ),
      ClinicalGrowthPoint(
        type: 'weight',
        value: 6.1,
        unit: 'kg',
        recordedAt: from.add(const Duration(days: 14)),
      ),
      ClinicalGrowthPoint(
        type: 'weight',
        value: 6.35,
        unit: 'kg',
        recordedAt: generatedAt,
      ),
      ClinicalGrowthPoint(
        type: 'height',
        value: 59,
        unit: 'cm',
        recordedAt: from,
      ),
      ClinicalGrowthPoint(
        type: 'height',
        value: 61.5,
        unit: 'cm',
        recordedAt: generatedAt,
      ),
    ],
    vaccines: [
      ClinicalReportItem(
        occurredAt: from.add(const Duration(days: 5)),
        title: 'Vacuna hexavalente',
        detail: 'Primera dosis registrada.',
        status: 'Administrada',
      ),
      ClinicalReportItem(
        occurredAt: from.add(const Duration(days: 5)),
        title: 'Neumocócica conjugada',
        detail: 'Primera dosis registrada.',
        status: 'Administrada',
      ),
    ],
    appointments: [
      ClinicalReportItem(
        occurredAt: from.add(const Duration(days: 8)),
        title: 'Control pediátrico de los 2 meses',
        detail:
            'Evaluación general, alimentación, sueño y crecimiento. Se '
            'registraron indicaciones de seguimiento para el próximo control.',
        status: 'Realizado',
        professional: 'Dra. Valentina Pérez',
      ),
    ],
    observations: List.generate(
      14,
      (index) => ClinicalReportItem(
        occurredAt: from.add(Duration(days: index * 2)),
        title: index.isEven ? 'Observación de piel' : 'Estado general',
        detail:
            'Registro ${index + 1}: descripción contextual suficientemente '
            'extensa para comprobar saltos de línea, acentos, ñ y paginación '
            'sin recortes ni superposición de contenido.',
        status: index == 4 ? 'Seguimiento' : null,
      ),
    ),
    timeline: List.generate(
      34,
      (index) => ClinicalTimelineItem(
        occurredAt: from.add(Duration(hours: index * 19)),
        type: switch (index % 4) {
          0 => 'Alimentación',
          1 => 'Eliminación',
          2 => 'Sueño',
          _ => 'Observación',
        },
        detail:
            'Evento clínico contextual ${index + 1}. Información legible y '
            'acotada para validar tablas extensas.',
      ),
    ),
    photoPaths: const [],
    appVersion: '1.0.0-development',
    dataVersion: 1,
  );
}
