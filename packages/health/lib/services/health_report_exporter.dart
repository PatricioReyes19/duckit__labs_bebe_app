import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:health/models/health_flow_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class HealthReportExporter {
  const HealthReportExporter({this.loadAsset});

  final Future<ByteData> Function(String key)? loadAsset;

  Future<void> sharePdf(HealthFlowController controller) async {
    final bytes = await buildPdf(controller);
    await SharePlus.instance.share(
      ShareParams(
        title: 'Reporte de salud',
        subject: 'Reporte de salud de ${controller.activeBaby?.name ?? 'Bebé'}',
        text: 'Resumen de salud generado por BebéApp.',
        files: [XFile.fromData(bytes, mimeType: 'application/pdf')],
        fileNameOverrides: [_fileName(controller, 'pdf')],
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
        fileNameOverrides: [_fileName(controller, 'csv')],
      ),
    );
  }

  Future<Uint8List> buildPdf(HealthFlowController controller) async {
    final (regularFont, boldFont) = await _loadFonts();
    final document = pw.Document(
      title: 'Reporte de salud',
      author: 'BebéApp',
      creator: 'BebéApp',
    );
    final report = controller.reportSnapshot;
    final records = report.records;
    final events = (controller.overview?.events ?? const <HealthEventEntity>[])
        .where(
          (event) =>
              event.babyId == controller.activeBaby?.id &&
              _inRange(event.startsAt, report),
        )
        .toList(growable: false);
    final measurements = controller.measurements
        .where((item) => _inRange(item.recordedAt, report))
        .toList(growable: false);
    final babyName = controller.activeBaby?.name ?? 'Bebé';
    final rangeLabel = _rangeLabel(controller.reportRange);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.teal400, width: 1.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'BebéApp · Reporte de salud',
                style: pw.TextStyle(
                  color: PdfColors.teal700,
                  fontSize: 17,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Página ${context.pageNumber}'),
            ],
          ),
        ),
        footer: (_) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            'Documento generado localmente. Verifica la información con el profesional de salud.',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (_) => [
          pw.SizedBox(height: 18),
          pw.Text(
            babyName,
            style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '$rangeLabel · Generado el ${_date(report.generatedAt.toLocal())}',
            style: const pw.TextStyle(color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 22),
          _summary(report),
          pw.SizedBox(height: 24),
          _sectionTitle('Vacunas y controles'),
          _eventsTable(events),
          pw.SizedBox(height: 20),
          _sectionTitle('Crecimiento'),
          _measurementsTable(measurements),
          pw.SizedBox(height: 20),
          _sectionTitle('Actividad y observaciones'),
          _recordsTable(records),
        ],
      ),
    );
    return document.save();
  }

  Future<(pw.Font, pw.Font)> _loadFonts() async {
    final loader = loadAsset ?? rootBundle.load;
    final regular = await loader(
      'packages/design_system/assets/fonts/PlusJakartaSans-Regular.ttf',
    );
    final bold = await loader(
      'packages/design_system/assets/fonts/PlusJakartaSans-Bold.ttf',
    );
    return (pw.Font.ttf(regular), pw.Font.ttf(bold));
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

  static pw.Widget _summary(HealthReportSnapshot report) {
    final totalMl = report.feedingVolumeMl;
    final sleepMinutes = report.sleepDurationMinutes;
    final feedingValue = totalMl != null
        ? '${totalMl.round()} mL'
        : report.feedings.isEmpty
        ? 'Sin datos'
        : '${report.feedings.length} tomas';
    final sleepValue = sleepMinutes != null
        ? _sleepDuration(sleepMinutes)
        : report.activeSleeps.isNotEmpty
        ? 'En curso'
        : report.completedSleeps.isNotEmpty
        ? '${report.completedSleeps.length} sesiones'
        : 'Sin datos';
    final diaperValue = report.diapers.isEmpty
        ? 'Sin datos'
        : '${report.diapers.length} cambios';
    final observationCount = report.records
        .where((event) => event.type == RegisterEventType.clinicalObservation)
        .length;
    return pw.Column(
      children: [
        pw.Row(
          children: [
            _summaryItem('Alimentación', feedingValue),
            pw.SizedBox(width: 10),
            _summaryItem('Sueño', sleepValue),
            pw.SizedBox(width: 10),
            _summaryItem('Pañales', diaperValue),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            _summaryItem(
              'Observaciones',
              observationCount == 0 ? 'Sin datos' : '$observationCount',
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _summaryItem(String label, String value) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.teal50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 16,
                  color: PdfColors.teal700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

  static pw.Widget _sectionTitle(String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(
      value,
      style: pw.TextStyle(
        fontSize: 15,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.teal800,
      ),
    ),
  );

  static pw.Widget _eventsTable(List<HealthEventEntity> events) {
    if (events.isEmpty) return pw.Text('Sin registros.');
    return pw.TableHelper.fromTextArray(
      headers: const ['Fecha', 'Registro', 'Estado'],
      data: [
        for (final event in events)
          [_date(event.startsAt), event.title, _healthStatus(event.status)],
      ],
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal100),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  static pw.Widget _measurementsTable(
    List<HealthMeasurementRecord> measurements,
  ) {
    if (measurements.isEmpty) return pw.Text('Sin mediciones.');
    return pw.TableHelper.fromTextArray(
      headers: const ['Fecha', 'Tipo', 'Valor', 'Fuente'],
      data: [
        for (final item in measurements)
          [
            _date(item.recordedAt),
            item.type == HealthMeasurementType.weight ? 'Peso' : 'Talla',
            '${item.value.toStringAsFixed(2)} ${item.unit}',
            item.source,
          ],
      ],
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal100),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  static pw.Widget _recordsTable(List<RegisteredEvent> records) {
    if (records.isEmpty) return pw.Text('Sin actividad para este período.');
    return pw.TableHelper.fromTextArray(
      headers: const ['Fecha', 'Tipo', 'Detalle', 'Estado'],
      data: [
        for (final item in records)
          [
            '${_date(item.occurredAt)} ${_time(item.occurredAt)}',
            _registerTypeLabel(item.type),
            _detail(item),
            item.syncStatus.name,
          ],
      ],
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal100),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  static bool _inRange(DateTime value, HealthReportSnapshot report) {
    final utc = value.toUtc();
    return !utc.isBefore(report.startsAt) &&
        !utc.isAfter(report.generatedAt);
  }

  static String _sleepDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '$remainder min';
    if (remainder == 0) return '$hours h';
    return '$hours h $remainder min';
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

  static String _healthStatus(HealthEventStatus status) => switch (status) {
    HealthEventStatus.scheduled => 'Programada',
    HealthEventStatus.completed => 'Aplicada',
    HealthEventStatus.cancelled => 'Cancelada',
  };

  static String _rangeLabel(HealthReportRange range) => switch (range) {
    HealthReportRange.day => 'Último día',
    HealthReportRange.week => 'Últimos 7 días',
    HealthReportRange.month => 'Últimos 30 días',
  };

  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  static String _escapeCsv(String value) =>
      '"${value.replaceAll('"', '""').replaceAll('\r', ' ').replaceAll('\n', ' ')}"';

  static String _fileName(HealthFlowController controller, String extension) {
    final baby = (controller.activeBaby?.name ?? 'bebe')
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '_');
    final now = controller.reportSnapshot.generatedAt.toLocal();
    return 'reporte_salud_${baby}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.$extension';
  }
}
