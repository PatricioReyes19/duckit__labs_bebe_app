import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'clinical_photo_loader_stub.dart'
    if (dart.library.io) 'clinical_photo_loader_io.dart';

class ClinicalReportPdfRenderer {
  const ClinicalReportPdfRenderer({this.loadAsset});

  final Future<ByteData> Function(String key)? loadAsset;

  Future<Uint8List> render(ClinicalReportData data) async {
    final fonts = await _loadFonts();
    final photos = <Uint8List>[];
    for (final path in data.photoPaths) {
      final bytes = await loadClinicalPhoto(path);
      if (bytes != null) photos.add(bytes);
    }
    final document = pw.Document(
      title: '${_typeLabel(data.request.type)} - ${data.babyName}',
      author: 'BebéApp',
      creator: 'BebéApp',
      subject:
          'Reporte ${data.reportId}; versión de datos ${data.dataVersion}; '
          'app ${data.appVersion}',
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 34, 36, 38),
        theme: pw.ThemeData.withFont(base: fonts.$1, bold: fonts.$2),
        build: (_) => _sections(data, photos),
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

  static pw.Widget _header(ClinicalReportData data) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 9),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.teal600, width: 1.4),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BebéApp',
                  style: pw.TextStyle(
                    color: PdfColors.blueGrey900,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  _typeLabel(data.request.type),
                  style: const pw.TextStyle(
                    color: PdfColors.teal800,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            pw.Text(
              'ID ${data.reportId}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
      );

  static pw.Widget _footer(ClinicalReportData data) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: PdfColors.grey400, width: .6),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                'Información registrada por cuidadores. No reemplaza una evaluación médica.',
                style: const pw.TextStyle(
                  fontSize: 7.5,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.Text(
              'ID ${data.reportId}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
          ],
        ),
      );

  static List<pw.Widget> _sections(
    ClinicalReportData data,
    List<Uint8List> photos,
  ) {
    final request = data.request;
    final widgets = <pw.Widget>[
      _header(data),
      pw.SizedBox(height: 16),
      pw.Text(
        data.babyName,
        style: pw.TextStyle(
          fontSize: 25,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        '${_age(data.birthDate, data.generatedAt)} · '
        '${_date(request.dateFrom.toLocal())} a ${_date(request.dateTo.toLocal())} · '
        'Generado ${_dateTime(data.generatedAt.toLocal())}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 14),
      _notice(data.summary),
      pw.SizedBox(height: 18),
    ];

    if (_show(request, ClinicalReportSection.growth) &&
        request.type != ClinicalReportType.medicationFollowUp) {
      widgets.addAll(_growthSection(data));
    }
    if (_show(request, ClinicalReportSection.feeding) &&
        request.type != ClinicalReportType.medicationFollowUp) {
      widgets.addAll(_feedingSection(data));
    }
    if (_show(request, ClinicalReportSection.medications) &&
        request.type != ClinicalReportType.growthNutrition) {
      widgets.addAll(_medicationSection(data));
    }
    if (_show(request, ClinicalReportSection.vaccines) &&
        request.type != ClinicalReportType.symptomConsultation &&
        request.type != ClinicalReportType.medicationFollowUp) {
      widgets.addAll(_itemsSection('Vacunas e inmunizaciones', data.vaccines));
    }
    if (_show(request, ClinicalReportSection.appointments) &&
        request.type != ClinicalReportType.medicationFollowUp) {
      widgets.addAll(_itemsSection('Controles y consultas', data.appointments));
    }
    if (_show(request, ClinicalReportSection.observations)) {
      widgets.addAll(_itemsSection('Observaciones y síntomas', data.observations));
    }
    if (_show(request, ClinicalReportSection.elimination) &&
        request.type != ClinicalReportType.medicationFollowUp &&
        request.type != ClinicalReportType.growthNutrition) {
      widgets.addAll(_eliminationSection(data));
    }
    if (_show(request, ClinicalReportSection.sleep) &&
        request.type != ClinicalReportType.medicationFollowUp &&
        request.type != ClinicalReportType.growthNutrition) {
      widgets.addAll(_sleepSection(data));
    }
    if (data.timeline.isNotEmpty) {
      widgets.addAll(_timelineSection(data));
    }
    if (data.photoPaths.isNotEmpty) {
      widgets.addAll([
        _sectionTitle('Fotografías seleccionadas'),
        if (photos.isEmpty)
          _empty('Las fotografías seleccionadas ya no están disponibles.')
        else
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final bytes in photos)
                pw.Container(
                  width: 150,
                  height: 110,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.grey500,
                      width: .5,
                    ),
                  ),
                  child: pw.Image(
                    pw.MemoryImage(bytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
            ],
          ),
        pw.SizedBox(height: 16),
      ]);
    }
    widgets.addAll([
      pw.SizedBox(height: 18),
      _footer(data),
    ]);
    return widgets;
  }

  static List<pw.Widget> _feedingSection(ClinicalReportData data) {
    final feeding = data.feeding;
    return [
      _sectionTitle('Alimentación resumida'),
      if (feeding.recordCount == 0)
        _empty('Sin registros de alimentación en este período.')
      else
        _keyValues([
          ('Tomas registradas', '${feeding.recordCount}'),
          ('Promedio diario', _decimal(feeding.averagePerDay)),
          (
            'Volumen promedio',
            feeding.averageVolumeMl == null
                ? 'Sin volumen registrado'
                : '${_decimal(feeding.averageVolumeMl!)} mL',
          ),
          (
            'Última toma',
            feeding.lastFeedingAt == null
                ? 'Sin registro'
                : _dateTime(feeding.lastFeedingAt!.toLocal()),
          ),
          (
            'Tipos',
            feeding.subtypes.entries
                .map((entry) => '${entry.key}: ${entry.value}')
                .join(' · '),
          ),
        ]),
      pw.SizedBox(height: 16),
    ];
  }

  static List<pw.Widget> _eliminationSection(ClinicalReportData data) {
    final value = data.elimination;
    final blood = switch (value.bloodOrMucusRecorded) {
      true => 'Sí, registrado',
      false => 'No registrado en campos específicos',
      null => 'Sin información específica',
    };
    return [
      _sectionTitle('Eliminación resumida'),
      _keyValues([
        ('Pañales húmedos', '${value.wetDiapers}'),
        ('Deposiciones', '${value.stools}'),
        ('Promedio húmedos/día', _decimal(value.averageWetPerDay)),
        ('Promedio deposiciones/día', _decimal(value.averageStoolsPerDay)),
        ('Consistencia predominante', value.predominantConsistency ?? 'Sin registro'),
        ('Color predominante', value.predominantColor ?? 'Sin registro'),
        ('Sangre o moco', blood),
        (
          'Episodios anómalos',
          value.anomalies.isEmpty ? 'Sin registro' : value.anomalies.join(' · '),
        ),
      ]),
      pw.SizedBox(height: 16),
    ];
  }

  static List<pw.Widget> _sleepSection(ClinicalReportData data) {
    final value = data.sleep;
    return [
      _sectionTitle('Sueño resumido'),
      if (value.completedSessions == 0 && value.activeSessions == 0)
        _empty('Sin registros de sueño en este período.')
      else
        _keyValues([
          ('Sesiones finalizadas', '${value.completedSessions}'),
          ('Sesiones en curso', '${value.activeSessions}'),
          ('Duración promedio', _duration(value.averageMinutes)),
          ('Sueño nocturno promedio', _duration(value.averageNightMinutes)),
          ('Siestas promedio/día', _decimal(value.averageNapsPerDay)),
        ]),
      pw.SizedBox(height: 16),
    ];
  }

  static List<pw.Widget> _medicationSection(ClinicalReportData data) => [
    _sectionTitle('Medicamentos'),
    if (data.medications.isEmpty)
      _empty('Sin administraciones registradas en este período.')
    else
      pw.TableHelper.fromTextArray(
        headers: const [
          'Medicamento',
          'Dosis',
          'Frecuencia',
          'Registradas',
          'Sin registro',
          'Última',
        ],
        data: [
          for (final item in data.medications)
            [
              item.name,
              [
                '${item.dose} ${item.unit}'.trim(),
                if (item.route?.trim().isNotEmpty ?? false)
                  'Vía: ${item.route}',
              ].join('\n'),
              [
                item.frequency,
                '${_date(item.startedAt.toLocal())} a '
                    '${_date(item.endedAt.toLocal())}',
              ].join('\n'),
              '${item.registeredAdministrations}',
              '${item.unregisteredAdministrations}',
              item.lastAdministrationAt == null
                  ? 'Sin registro'
                  : _dateTime(item.lastAdministrationAt!.toLocal()),
            ],
        ],
        columnWidths: const {
          0: pw.FlexColumnWidth(1.5),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(.8),
          4: pw.FlexColumnWidth(.9),
          5: pw.FlexColumnWidth(1.2),
        },
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        border: pw.TableBorder.all(color: PdfColors.grey500, width: .5),
        headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 7.5),
        cellPadding: const pw.EdgeInsets.all(5),
      ),
    if (data.medications.any((item) => item.adverseEvents.isNotEmpty)) ...[
      pw.SizedBox(height: 7),
      pw.NewPage(),
      pw.Text(
        'Eventos adversos consignados',
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 3),
      for (final item in data.medications.where(
        (item) => item.adverseEvents.isNotEmpty,
      ))
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Text(
            '${item.name}: ${item.adverseEvents.join('; ')}',
            style: const pw.TextStyle(fontSize: 8.5),
          ),
        ),
    ],
    pw.SizedBox(height: 16),
  ];

  static List<pw.Widget> _growthSection(ClinicalReportData data) {
    if (data.growth.isEmpty) {
      return [
        _sectionTitle('Crecimiento'),
        _empty('Sin mediciones en este período.'),
        pw.SizedBox(height: 16),
      ];
    }
    final byType = <String, List<ClinicalGrowthPoint>>{};
    for (final point in data.growth) {
      byType.putIfAbsent(point.type, () => []).add(point);
    }
    return [
      _sectionTitle('Crecimiento'),
      for (final entry in byType.entries) ...[
        pw.Text(
          _growthType(entry.key),
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        _barTrend(entry.value, data.request),
        if (entry.value.length > 1) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            _growthVariation(entry.value),
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
        pw.SizedBox(height: 10),
      ],
      pw.SizedBox(height: 6),
    ];
  }

  static String _growthVariation(List<ClinicalGrowthPoint> points) {
    final ordered = [...points]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final first = ordered.first;
    final last = ordered.last;
    final difference = last.value - first.value;
    final sign = difference > 0 ? '+' : '';
    return 'Variación del período: $sign${_decimal(difference)} ${last.unit} '
        '(${_date(first.recordedAt.toLocal())} a '
        '${_date(last.recordedAt.toLocal())}).';
  }

  static pw.Widget _barTrend(
    List<ClinicalGrowthPoint> source,
    ClinicalReportRequest request,
  ) {
    final points = source.length > 8 ? source.sublist(source.length - 8) : source;
    final maximum = points
        .map((point) => point.value)
        .reduce((first, second) => first > second ? first : second);
    final minimum = points
        .map((point) => point.value)
        .reduce((first, second) => first < second ? first : second);
    final spread = maximum - minimum;
    return pw.Container(
      height: 105,
      padding: const pw.EdgeInsets.fromLTRB(8, 8, 8, 5),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400, width: .5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          for (final point in points)
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      '${_decimal(point.value)} ${point.unit}',
                      style: const pw.TextStyle(fontSize: 6.5),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Container(
                      height: spread == 0
                          ? 42
                          : 24 + ((point.value - minimum) / spread * 34),
                      color: PdfColors.teal700,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      _axisLabel(point.recordedAt.toLocal(), request),
                      style: const pw.TextStyle(fontSize: 6.2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static List<pw.Widget> _itemsSection(
    String title,
    List<ClinicalReportItem> items,
  ) {
    if (items.isEmpty) {
      return [
        _sectionTitle(title),
        _empty('Sin registros en este período.'),
        pw.SizedBox(height: 16),
      ];
    }
    final chunks = _chunks(items, 4);
    return [
      for (var index = 0; index < chunks.length; index += 1) ...[
        pw.NewPage(freeSpace: 245),
        if (index == 0) _sectionTitle(title),
        _itemsTable(chunks[index]),
        pw.SizedBox(height: index == chunks.length - 1 ? 16 : 7),
      ],
    ];
  }

  static pw.Widget _itemsTable(List<ClinicalReportItem> items) =>
      pw.TableHelper.fromTextArray(
        headers: const ['Fecha', 'Registro', 'Detalle', 'Estado / profesional'],
        data: [
          for (final item in items)
            [
              _date(item.occurredAt.toLocal()),
              item.title,
              item.detail,
              [item.status, item.professional].whereType<String>().join(' · '),
            ],
        ],
        columnWidths: const {
          0: pw.FlexColumnWidth(.8),
          1: pw.FlexColumnWidth(1.25),
          2: pw.FlexColumnWidth(2.4),
          3: pw.FlexColumnWidth(1.2),
        },
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        border: pw.TableBorder.all(color: PdfColors.grey500, width: .5),
        headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 7.5),
        cellPadding: const pw.EdgeInsets.all(5),
      );

  static List<pw.Widget> _timelineSection(ClinicalReportData data) {
    final showCaregiver = data.timeline.any(
      (item) => item.caregiverName != null,
    );
    final chunks = _chunks(data.timeline, 9);
    return [
      for (var index = 0; index < chunks.length; index += 1) ...[
        if (index == 0 || index == 2)
          pw.NewPage()
        else
          pw.NewPage(freeSpace: 235),
        if (index == 0) ...[
          _sectionTitle('Timeline detallado'),
          if (data.request.type == ClinicalReportType.fullHistory)
            _notice('Este informe puede ser extenso.'),
        ],
        _timelineTable(chunks[index], showCaregiver),
        if (index != chunks.length - 1) pw.SizedBox(height: 7),
      ],
    ];
  }

  static pw.Widget _timelineTable(
    List<ClinicalTimelineItem> items,
    bool showCaregiver,
  ) => pw.TableHelper.fromTextArray(
      headers: [
        'Fecha y hora',
        'Tipo',
        'Detalle',
        if (showCaregiver) 'Cuidador',
      ],
      data: [
        for (final item in items)
          [
            _dateTime(item.occurredAt.toLocal()),
            item.type,
            item.detail,
            if (showCaregiver) item.caregiverName ?? 'Sin registro',
          ],
      ],
      columnWidths: {
        0: pw.FlexColumnWidth(1.1),
        1: pw.FlexColumnWidth(.9),
        2: pw.FlexColumnWidth(3),
        if (showCaregiver) 3: pw.FlexColumnWidth(1.1),
      },
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      border: pw.TableBorder.all(color: PdfColors.grey500, width: .5),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 7.2),
      cellPadding: const pw.EdgeInsets.all(5),
    );

  static List<List<T>> _chunks<T>(List<T> source, int size) => [
    for (var index = 0; index < source.length; index += size)
      source.sublist(
        index,
        index + size > source.length ? source.length : index + size,
      ),
  ];

  static pw.Widget _sectionTitle(String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 7),
    child: pw.Text(
      value,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blueGrey900,
      ),
    ),
  );

  static pw.Widget _notice(String value) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      border: pw.Border.all(color: PdfColors.grey400, width: .5),
    ),
    child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
  );

  static pw.Widget _empty(String value) => pw.Text(
    value,
    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
  );

  static pw.Widget _keyValues(List<(String, String)> values) => pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey400, width: .5),
    columnWidths: const {
      0: pw.FlexColumnWidth(1.2),
      1: pw.FlexColumnWidth(2.8),
    },
    children: [
      for (var index = 0; index < values.length; index += 1)
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: index.isEven ? PdfColors.grey100 : PdfColors.white,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                values[index].$1,
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                values[index].$2,
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
          ],
        ),
    ],
  );

  static bool _show(
    ClinicalReportRequest request,
    ClinicalReportSection section,
  ) => request.includes(section);

  static String _typeLabel(ClinicalReportType type) => switch (type) {
    ClinicalReportType.pediatricControl => 'Control pediátrico',
    ClinicalReportType.symptomConsultation => 'Consulta por síntomas',
    ClinicalReportType.medicationFollowUp => 'Seguimiento de medicamentos',
    ClinicalReportType.growthNutrition => 'Crecimiento y nutrición',
    ClinicalReportType.fullHistory => 'Historial completo',
  };

  static String _growthType(String value) => switch (value) {
    'weight' => 'Peso',
    'height' => 'Talla',
    'headCircumference' => 'Perímetro cefálico',
    _ => value,
  };

  static String _axisLabel(
    DateTime value,
    ClinicalReportRequest request,
  ) => request.dateTo.difference(request.dateFrom) <= const Duration(days: 1)
      ? _time(value)
      : '${value.day.toString().padLeft(2, '0')}/'
          '${value.month.toString().padLeft(2, '0')}';

  static String _age(DateTime birthDate, DateTime at) {
    final localBirth = birthDate.toLocal();
    final localAt = at.toLocal();
    var months = (localAt.year - localBirth.year) * 12 +
        localAt.month -
        localBirth.month;
    if (localAt.day < localBirth.day) months -= 1;
    if (months < 1) {
      final days = localAt.difference(localBirth).inDays.clamp(0, 31);
      return '$days días';
    }
    if (months < 24) return '$months meses';
    final years = months ~/ 12;
    final remaining = months % 12;
    return remaining == 0 ? '$years años' : '$years años $remaining meses';
  }

  static String _duration(double? minutes) {
    if (minutes == null) return 'Sin registro';
    final rounded = minutes.round();
    final hours = rounded ~/ 60;
    final remainder = rounded % 60;
    if (hours == 0) return '$remainder min';
    if (remainder == 0) return '$hours h';
    return '$hours h $remainder min';
  }

  static String _decimal(double value) => value
      .toStringAsFixed(value == value.roundToDouble() ? 0 : 1)
      .replaceAll('.', ',');

  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  static String _dateTime(DateTime value) => '${_date(value)} ${_time(value)}';
}
