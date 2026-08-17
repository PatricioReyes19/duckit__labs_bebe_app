import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

enum HealthReportRange { day, week, month }

extension HealthReportRangeWindow on HealthReportRange {
  int get days => switch (this) {
    HealthReportRange.day => 1,
    HealthReportRange.week => 7,
    HealthReportRange.month => 30,
  };
}

class HealthReportSnapshot {
  HealthReportSnapshot._({
    required this.range,
    required this.generatedAt,
    required this.startsAt,
    required this.records,
  });

  factory HealthReportSnapshot.project({
    required Iterable<RegisteredEvent> records,
    required String babyId,
    required HealthReportRange range,
    required DateTime now,
  }) {
    final end = now.toUtc();
    final start = end.subtract(Duration(days: range.days));
    final visible =
        records
            .where(
              (event) =>
                  event.babyId == babyId &&
                  !event.isDeleted &&
                  event.details['observation_type'] != 'pediatrician_profile' &&
                  !event.occurredAt.toUtc().isBefore(start) &&
                  !event.occurredAt.toUtc().isAfter(end),
            )
            .toList(growable: false)
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return HealthReportSnapshot._(
      range: range,
      generatedAt: end,
      startsAt: start,
      records: List.unmodifiable(visible),
    );
  }

  final HealthReportRange range;
  final DateTime generatedAt;
  final DateTime startsAt;
  final List<RegisteredEvent> records;

  List<RegisteredEvent> ofType(RegisterEventType type) =>
      records.where((event) => event.type == type).toList(growable: false);

  List<RegisteredEvent> get feedings => ofType(RegisterEventType.feeding);
  List<RegisteredEvent> get diapers => ofType(RegisterEventType.diaper);
  List<RegisteredEvent> get activeSleeps => ofType(
    RegisterEventType.sleep,
  ).where((event) => event.isActive).toList(growable: false);
  List<RegisteredEvent> get completedSleeps => ofType(
    RegisterEventType.sleep,
  ).where((event) => event.isFinished).toList(growable: false);
  List<RegisteredEvent> get clinicalNotes => records
      .where(
        (event) =>
            event.type == RegisterEventType.clinicalObservation &&
            (event.details['observation_type'] == null ||
                event.details['observation_type'] == 'clinical_note'),
      )
      .toList(growable: false);

  double? get feedingVolumeMl {
    final amounts = feedings
        .map((event) => event.details['amount_ml'])
        .whereType<num>()
        .map((value) => value.toDouble())
        .where((value) => value.isFinite && value >= 0)
        .toList(growable: false);
    if (amounts.isEmpty) return null;
    return amounts.fold<double>(0, (total, value) => total + value);
  }

  int? get sleepDurationMinutes {
    final durations = <int>[];
    for (final event in completedSleeps) {
      final stored = event.details['duration_minutes'];
      if (stored is num && stored.isFinite && stored >= 0) {
        durations.add(stored.round());
        continue;
      }
      final endedAt = event.endedAt;
      if (endedAt != null && !endedAt.isBefore(event.startedAt)) {
        durations.add(endedAt.difference(event.startedAt).inMinutes);
      }
    }
    if (durations.isEmpty) return null;
    return durations.fold<int>(0, (total, value) => total + value);
  }

  bool get hasActivityTrendData =>
      feedings.isNotEmpty || completedSleeps.isNotEmpty || diapers.isNotEmpty;

  List<double> dailyCounts(RegisterEventType type) {
    final source = type == RegisterEventType.sleep
        ? completedSleeps
        : ofType(type);
    final localEnd = generatedAt.toLocal();
    final visibleDays = range.days.clamp(1, 30);
    return List<double>.generate(visibleDays, (index) {
      final date = DateTime(
        localEnd.year,
        localEnd.month,
        localEnd.day,
      ).subtract(Duration(days: visibleDays - index - 1));
      return source
          .where((event) {
            final local = event.occurredAt.toLocal();
            return local.year == date.year &&
                local.month == date.month &&
                local.day == date.day;
          })
          .length
          .toDouble();
    });
  }
}

enum HealthFlowSaveKind {
  vaccine,
  measurement,
  consultation,
  observation,
  pediatrician,
}

class HealthFlowSaveResult {
  const HealthFlowSaveResult({required this.kind, required this.savedAt});

  final HealthFlowSaveKind kind;
  final DateTime savedAt;
}

class HealthMeasurementRecord {
  const HealthMeasurementRecord({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
    required this.source,
    required this.syncStatus,
  });

  final String id;
  final HealthMeasurementType type;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String source;
  final RegisterSyncStatus syncStatus;
}

class HealthConsultationRecord {
  const HealthConsultationRecord({
    required this.id,
    required this.title,
    required this.summary,
    required this.pediatrician,
    required this.occurredAt,
    required this.treatment,
    required this.followUp,
    required this.vigilance,
    required this.notes,
    required this.syncStatus,
  });

  final String id;
  final String title;
  final String summary;
  final String pediatrician;
  final DateTime occurredAt;
  final String? treatment;
  final String? followUp;
  final String? vigilance;
  final String? notes;
  final RegisterSyncStatus syncStatus;
}

class HealthPediatricianSummary {
  const HealthPediatricianSummary({
    required this.name,
    required this.specialty,
    required this.consultationCount,
    this.phone,
    this.place,
    this.notes,
    this.lastConsultationAt,
    this.latestReason,
    this.syncStatus,
  });

  final String name;
  final String specialty;
  final String? phone;
  final String? place;
  final String? notes;
  final int consultationCount;
  final DateTime? lastConsultationAt;
  final String? latestReason;
  final RegisterSyncStatus? syncStatus;
}

/// Estado compartido por los recorridos secundarios de Salud.
///
/// Los formularios guardan primero en la fuente local de registros. La cola de
/// sincronización existente se ejecuta después, salvo cuando el usuario activa
/// explícitamente el modo sin conexión.
class HealthFlowController extends ChangeNotifier {
  HealthFlowController({
    required GetFamilyOverview getFamilyOverview,
    required GetHealthOverview getHealthOverview,
    required GetRegisterEvents getRegisterEvents,
    required SaveRegisterEvent saveRegisterEvent,
    required DeleteRegisterEvent deleteRegisterEvent,
    required HealthRepository healthRepository,
    required RegisterEventSyncService registerSyncService,
    InitialDataSyncCoordinator? initialDataSyncCoordinator,
    Connectivity? connectivity,
    DateTime Function()? clock,
  }) : _getFamilyOverview = getFamilyOverview,
       _getHealthOverview = getHealthOverview,
       _getRegisterEvents = getRegisterEvents,
       _saveRegisterEvent = saveRegisterEvent,
       _deleteRegisterEvent = deleteRegisterEvent,
       _healthRepository = healthRepository,
       _registerSyncService = registerSyncService,
       _initialDataSyncCoordinator = initialDataSyncCoordinator,
       _connectivity = connectivity ?? Connectivity(),
       _clock = clock ?? DateTime.now,
       _syncState = registerSyncService.state {
    _syncSubscription = _registerSyncService.states.listen((state) {
      _syncState = state;
      notifyListeners();
    });
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
      onError: (_) {},
    );
    _activeBabySubscription = _getFamilyOverview.activeBabyChanges.listen((_) {
      if (_isLoading) {
        _reloadAfterCurrentLoad = true;
      } else {
        unawaited(load(force: true));
      }
    });
    _domainHydrationSubscription = _initialDataSyncCoordinator
        ?.domainHydrationStates
        .listen((ready) {
          if (!ready) {
            _loadedOnce = false;
            _error = null;
            notifyListeners();
          } else if (!_isLoading) {
            unawaited(load(force: true));
          }
        });
    unawaited(_refreshConnectivity());
  }

  final GetFamilyOverview _getFamilyOverview;
  final GetHealthOverview _getHealthOverview;
  final GetRegisterEvents _getRegisterEvents;
  final SaveRegisterEvent _saveRegisterEvent;
  final DeleteRegisterEvent _deleteRegisterEvent;
  final HealthRepository _healthRepository;
  final RegisterEventSyncService _registerSyncService;
  final InitialDataSyncCoordinator? _initialDataSyncCoordinator;
  final Connectivity _connectivity;
  final DateTime Function() _clock;

  late final StreamSubscription<RegisterSyncState> _syncSubscription;
  late final StreamSubscription<String> _activeBabySubscription;
  StreamSubscription<bool>? _domainHydrationSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  FamilyOverviewEntity? _family;
  HealthOverviewEntity? _overview;
  List<RegisteredEvent> _records = const [];
  RegisterSyncState _syncState;
  HealthReportRange _reportRange = HealthReportRange.week;
  bool _isLoading = false;
  bool _loadedOnce = false;
  bool _manualOfflineMode = false;
  bool _hasConnectivity = true;
  bool _reloadAfterCurrentLoad = false;
  Object? _error;
  String? _selectedHealthEventId;
  String? _selectedRecordId;
  String? _selectedPediatricianName;

  FamilyOverviewEntity? get family => _family;
  BabyEntity? get activeBaby => _family?.activeBaby;
  HealthOverviewEntity? get overview => _overview;
  List<RegisteredEvent> get records => List.unmodifiable(_records);
  RegisterSyncState get syncState => _syncState;
  HealthReportRange get reportRange => _reportRange;
  HealthReportSnapshot get reportSnapshot => HealthReportSnapshot.project(
    records: _records,
    babyId: activeBaby?.id ?? '',
    range: _reportRange,
    now: _clock(),
  );
  bool get isLoading =>
      _isLoading ||
      (_initialDataSyncCoordinator != null &&
          !_initialDataSyncCoordinator.hasHydratedDomains);
  bool get offlineMode => _manualOfflineMode || !_hasConnectivity;
  bool get networkUnavailable => !_hasConnectivity;
  Object? get error => _error;

  List<HealthEventEntity> get vaccines {
    final result =
        _overview?.events
            .where((event) => event.type == HealthEventType.vaccine)
            .toList(growable: false) ??
        const <HealthEventEntity>[];
    return _sortedHealthEvents(result);
  }

  List<HealthEventEntity> get controls {
    final result =
        _overview?.events
            .where(
              (event) =>
                  event.type == HealthEventType.pediatricControl ||
                  event.type == HealthEventType.growthControl,
            )
            .toList(growable: false) ??
        const <HealthEventEntity>[];
    return _sortedHealthEvents(result);
  }

  List<HealthMeasurementRecord> get measurements {
    final result = <HealthMeasurementRecord>[
      for (final event in measurementRecords)
        if (_measurementType(event) case final type?)
          if (event.details['value'] case final num value)
            HealthMeasurementRecord(
              id: event.id,
              type: type,
              value: value.toDouble(),
              unit:
                  _text(event.details['unit']) ??
                  (type == HealthMeasurementType.weight ? 'kg' : 'cm'),
              recordedAt: event.occurredAt,
              source: _text(event.details['source']) ?? 'Registro de actividad',
              syncStatus: event.syncStatus,
            ),
      for (final measurement in _overview?.measurements ?? const [])
        HealthMeasurementRecord(
          id: measurement.id,
          type: measurement.type,
          value: measurement.value,
          unit: measurement.unit,
          recordedAt: measurement.recordedAt,
          source: measurement.source.trim().isEmpty
              ? 'Registro de salud'
              : measurement.source.trim(),
          syncStatus: RegisterSyncStatus.synced,
        ),
    ];
    result.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return List.unmodifiable(result);
  }

  List<HealthConsultationRecord> get consultations {
    final result = <HealthConsultationRecord>[
      for (final event in clinicalRecords)
        if (event.details['observation_type'] == 'medical_consultation')
          HealthConsultationRecord(
            id: event.id,
            title: _text(event.details['title']) ?? 'Consulta pediátrica',
            summary: _text(event.details['description']) ?? '',
            pediatrician:
                _text(event.details['pediatrician']) ??
                'Profesional no especificado',
            occurredAt: event.occurredAt,
            treatment: _text(event.details['treatment']),
            followUp: _text(event.details['follow_up']),
            vigilance: _text(event.details['vigilance']),
            notes: _text(event.notes),
            syncStatus: event.syncStatus,
          ),
    ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List.unmodifiable(result);
  }

  List<RegisteredEvent> get clinicalNotes {
    final result =
        clinicalRecords
            .where((event) {
              final kind = event.details['observation_type'];
              return kind == null || kind == 'clinical_note';
            })
            .toList(growable: false)
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List.unmodifiable(result);
  }

  List<HealthPediatricianSummary> get pediatricians {
    final profiles = <String, RegisteredEvent>{};
    for (final event in clinicalRecords) {
      if (event.details['observation_type'] != 'pediatrician_profile') continue;
      final name = _text(event.details['name']);
      if (name == null) continue;
      final key = name.toLowerCase();
      final current = profiles[key];
      if (current == null || event.occurredAt.isAfter(current.occurredAt)) {
        profiles[key] = event;
      }
    }

    final groupedConsultations = <String, List<HealthConsultationRecord>>{};
    for (final consultation in consultations) {
      final key = consultation.pediatrician.toLowerCase();
      groupedConsultations.putIfAbsent(key, () => []).add(consultation);
    }

    final keys = <String>{...profiles.keys, ...groupedConsultations.keys};
    final result =
        <HealthPediatricianSummary>[
          for (final key in keys)
            _pediatricianSummary(
              profiles[key],
              groupedConsultations[key] ?? const [],
            ),
        ]..sort((a, b) {
          final byDate = (b.lastConsultationAt ?? DateTime(0)).compareTo(
            a.lastConsultationAt ?? DateTime(0),
          );
          return byDate != 0 ? byDate : a.name.compareTo(b.name);
        });
    return List.unmodifiable(result);
  }

  HealthEventEntity? get selectedHealthEvent => _firstWhereOrNull(
    _overview?.events ?? const [],
    (event) => event.id == _selectedHealthEventId,
  );

  HealthMeasurementRecord? get selectedMeasurement => _firstWhereOrNull(
    measurements,
    (measurement) => measurement.id == _selectedRecordId,
  );

  HealthConsultationRecord? get selectedConsultation => _firstWhereOrNull(
    consultations,
    (consultation) => consultation.id == _selectedRecordId,
  );

  RegisteredEvent? get selectedRecord =>
      _firstWhereOrNull(_records, (record) => record.id == _selectedRecordId);

  bool get selectedRecordCanBeManaged => selectedRecord != null;
  bool get selectedRecordCanBeEdited {
    final record = selectedRecord;
    if (record == null) return false;
    if (record.type == RegisterEventType.measurement) return true;
    if (record.type != RegisterEventType.clinicalObservation) return false;
    final observationType = record.details['observation_type'];
    return observationType == null || observationType == 'clinical_note';
  }

  HealthPediatricianSummary? get selectedPediatrician => _firstWhereOrNull(
    pediatricians,
    (pediatrician) =>
        pediatrician.name.toLowerCase() == _selectedPediatricianName,
  );

  List<RegisteredEvent> get measurementRecords => _records
      .where((event) => event.type == RegisterEventType.measurement)
      .toList(growable: false);

  List<RegisteredEvent> get clinicalRecords => _records
      .where((event) => event.type == RegisterEventType.clinicalObservation)
      .toList(growable: false);

  List<RegisteredEvent> get reportableRecords => _records
      .where(
        (event) => event.details['observation_type'] != 'pediatrician_profile',
      )
      .toList(growable: false);

  List<RegisteredEvent> get feedingRecords => _records
      .where((event) => event.type == RegisterEventType.feeding)
      .toList(growable: false);

  List<RegisteredEvent> get sleepRecords => _records
      .where((event) => event.type == RegisterEventType.sleep)
      .toList(growable: false);

  List<RegisteredEvent> get diaperRecords => _records
      .where((event) => event.type == RegisterEventType.diaper)
      .toList(growable: false);

  void selectHealthEvent(HealthEventEntity event) {
    _selectedHealthEventId = event.id;
    _selectedRecordId = null;
  }

  void selectMeasurement(HealthMeasurementRecord measurement) {
    _selectedRecordId = measurement.id;
    _selectedHealthEventId = null;
  }

  void selectConsultation(HealthConsultationRecord consultation) {
    _selectedRecordId = consultation.id;
    _selectedHealthEventId = null;
  }

  void selectRecord(RegisteredEvent record) {
    _selectedRecordId = record.id;
    _selectedHealthEventId = null;
  }

  void selectPediatrician(HealthPediatricianSummary pediatrician) {
    _selectedPediatricianName = pediatrician.name.toLowerCase();
    final profile = _firstWhereOrNull(
      clinicalRecords,
      (event) =>
          event.details['observation_type'] == 'pediatrician_profile' &&
          _text(event.details['name'])?.toLowerCase() ==
              _selectedPediatricianName,
    );
    _selectedRecordId = profile?.id;
  }

  int get pendingSyncCount => _records
      .where(
        (event) =>
            event.syncStatus == RegisterSyncStatus.pending ||
            event.syncStatus == RegisterSyncStatus.failed,
      )
      .length;

  Future<void> load({bool force = false}) async {
    if (_isLoading || (_loadedOnce && !force)) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final coordinator = _initialDataSyncCoordinator;
      if (coordinator != null && !coordinator.hasHydratedDomains) {
        await coordinator.domainHydrationStates.firstWhere((ready) => ready);
      }
      final family = await _getFamilyOverview();
      final results = await Future.wait<Object>([
        _getHealthOverview(family.activeBabyId),
        _getRegisterEvents(family.activeBabyId),
      ]);
      _family = family;
      _overview = results[0] as HealthOverviewEntity;
      _records = results[1] as List<RegisteredEvent>;
      _loadedOnce = true;
    } on Object catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
      if (_reloadAfterCurrentLoad) {
        _reloadAfterCurrentLoad = false;
        unawaited(load(force: true));
      }
    }
  }

  void selectReportRange(HealthReportRange value) {
    if (_reportRange == value) return;
    _reportRange = value;
    notifyListeners();
  }

  void setOfflineMode(bool value) {
    if (_manualOfflineMode == value) return;
    _manualOfflineMode = value;
    notifyListeners();
    if (!value && _hasConnectivity) unawaited(retrySync());
  }

  Future<HealthFlowSaveResult> saveMeasurement({
    required HealthMeasurementType type,
    required double value,
    required DateTime occurredAt,
    String? notes,
  }) async {
    final babyId = await _requireBabyId();
    final saved = await _saveRegisterEvent(
      RegisterEventDraft(
        babyId: babyId,
        type: RegisterEventType.measurement,
        occurredAt: occurredAt,
        notes: notes,
        details: {
          'measurement_type': type.name,
          'value': value,
          'unit': type == HealthMeasurementType.weight ? 'kg' : 'cm',
          'source': 'health_flow',
        },
      ),
    );
    _selectedRecordId = saved.id;
    await _refreshAfterSave();
    return HealthFlowSaveResult(
      kind: HealthFlowSaveKind.measurement,
      savedAt: DateTime.now(),
    );
  }

  Future<HealthFlowSaveResult> saveVaccination({
    required String vaccineName,
    required String dose,
    required DateTime occurredAt,
    required String location,
    String? professional,
    String? lot,
    String? notes,
  }) async {
    final babyId = await _requireBabyId();
    final title = dose.trim().isEmpty
        ? vaccineName.trim()
        : '${vaccineName.trim()} (${dose.trim()})';
    final saved = await _healthRepository.createEvent(
      HealthEventDraft(
        babyId: babyId,
        type: HealthEventType.vaccine,
        title: title,
        description: 'Aplicada en ${location.trim()}',
        startsAt: occurredAt,
        status: HealthEventStatus.completed,
      ),
    );
    _selectedHealthEventId = saved.id;
    await _saveRegisterEvent(
      RegisterEventDraft(
        babyId: babyId,
        type: RegisterEventType.clinicalObservation,
        occurredAt: occurredAt,
        notes: notes,
        details: {
          'observation_type': 'vaccination',
          'title': title,
          'description': 'Vacuna aplicada',
          'location': location.trim(),
          if (professional?.trim().isNotEmpty ?? false)
            'professional': professional!.trim(),
          if (lot?.trim().isNotEmpty ?? false) 'lot': lot!.trim(),
          'severity': 'none',
          'share_with_pediatrician': true,
        },
      ),
    );
    await _refreshAfterSave();
    return HealthFlowSaveResult(
      kind: HealthFlowSaveKind.vaccine,
      savedAt: DateTime.now(),
    );
  }

  Future<HealthFlowSaveResult> saveConsultation({
    required DateTime occurredAt,
    required String pediatrician,
    required String reason,
    required String summary,
    required String treatment,
    required String followUp,
    required String vigilance,
    String? notes,
  }) async {
    final babyId = await _requireBabyId();
    final saved = await _saveRegisterEvent(
      RegisterEventDraft(
        babyId: babyId,
        type: RegisterEventType.clinicalObservation,
        occurredAt: occurredAt,
        caregiverId: 'mother',
        notes: notes,
        schemaVersion: 2,
        details: {
          'observation_type': 'medical_consultation',
          'title': reason.trim(),
          'description': summary.trim(),
          'pediatrician': pediatrician.trim(),
          'treatment': treatment.trim(),
          'follow_up': followUp.trim(),
          'vigilance': vigilance.trim(),
          'share_with_pediatrician': true,
        },
      ),
    );
    _selectedRecordId = saved.id;
    await _refreshAfterSave();
    return HealthFlowSaveResult(
      kind: HealthFlowSaveKind.consultation,
      savedAt: DateTime.now(),
    );
  }

  Future<HealthFlowSaveResult> saveObservation({
    required String title,
    required String description,
    required String severity,
  }) async {
    final babyId = await _requireBabyId();
    final saved = await _saveRegisterEvent(
      RegisterEventDraft(
        babyId: babyId,
        type: RegisterEventType.clinicalObservation,
        occurredAt: DateTime.now(),
        caregiverId: 'mother',
        details: {
          'observation_type': 'clinical_note',
          'title': title.trim(),
          'description': description.trim(),
          'severity': severity,
          'share_with_pediatrician': true,
        },
      ),
    );
    _selectedRecordId = saved.id;
    await _refreshAfterSave();
    return HealthFlowSaveResult(
      kind: HealthFlowSaveKind.pediatrician,
      savedAt: DateTime.now(),
    );
  }

  Future<HealthFlowSaveResult> savePediatrician({
    required String name,
    required String specialty,
    String? phone,
    String? place,
    String? notes,
  }) async {
    final babyId = await _requireBabyId();
    final saved = await _saveRegisterEvent(
      RegisterEventDraft(
        babyId: babyId,
        type: RegisterEventType.clinicalObservation,
        occurredAt: DateTime.now(),
        schemaVersion: 2,
        notes: notes,
        details: {
          'observation_type': 'pediatrician_profile',
          'name': name.trim(),
          'specialty': specialty.trim(),
          if (phone?.trim().isNotEmpty ?? false) 'phone': phone!.trim(),
          if (place?.trim().isNotEmpty ?? false) 'place': place!.trim(),
          'share_with_pediatrician': false,
        },
      ),
    );
    _selectedRecordId = saved.id;
    _selectedPediatricianName = name.trim().toLowerCase();
    await _refreshAfterSave();
    return HealthFlowSaveResult(
      kind: HealthFlowSaveKind.observation,
      savedAt: DateTime.now(),
    );
  }

  Future<void> retrySync() async {
    if (offlineMode) return;
    await _registerSyncService.synchronize();
    await load(force: true);
  }

  Future<bool> deleteSelectedRecord() async {
    final record = selectedRecord;
    if (record == null) return false;
    await _deleteRegisterEvent(record.id);
    _selectedRecordId = null;
    await load(force: true);
    if (!offlineMode) unawaited(_registerSyncService.synchronize());
    return true;
  }

  Future<String> _requireBabyId() async {
    if (_family == null) await load();
    final value = _family?.activeBabyId;
    if (value == null || value.isEmpty) {
      throw StateError('No hay un bebé activo para guardar el registro.');
    }
    return value;
  }

  Future<void> _refreshAfterSave() async {
    await load(force: true);
    if (!offlineMode) unawaited(_registerSyncService.synchronize());
  }

  Future<void> _refreshConnectivity() async {
    try {
      _handleConnectivityChanged(await _connectivity.checkConnectivity());
    } on Object {
      // El estado de la cola de sincronización sigue siendo la fuente final
      // cuando el sistema operativo no expone información de conectividad.
    }
  }

  void _handleConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnectivity =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);
    if (_hasConnectivity == hasConnectivity) return;
    _hasConnectivity = hasConnectivity;
    notifyListeners();
    if (hasConnectivity && !_manualOfflineMode && _loadedOnce) {
      unawaited(retrySync());
    }
  }

  @override
  void dispose() {
    unawaited(_syncSubscription.cancel());
    unawaited(_activeBabySubscription.cancel());
    unawaited(_domainHydrationSubscription?.cancel());
    unawaited(_connectivitySubscription?.cancel());
    super.dispose();
  }

  static List<HealthEventEntity> _sortedHealthEvents(
    List<HealthEventEntity> events,
  ) =>
      List<HealthEventEntity>.of(events)
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  static HealthMeasurementType? _measurementType(RegisteredEvent event) {
    final value = event.details['measurement_type'];
    for (final type in HealthMeasurementType.values) {
      if (type.name == value) return type;
    }
    return null;
  }

  static HealthPediatricianSummary _pediatricianSummary(
    RegisteredEvent? profile,
    List<HealthConsultationRecord> consultations,
  ) {
    final latest = consultations.isEmpty ? null : consultations.first;
    return HealthPediatricianSummary(
      name: _text(profile?.details['name']) ?? latest!.pediatrician,
      specialty:
          _text(profile?.details['specialty']) ?? 'Pediatría no especificada',
      phone: _text(profile?.details['phone']),
      place: _text(profile?.details['place']),
      notes: _text(profile?.notes),
      consultationCount: consultations.length,
      lastConsultationAt: latest?.occurredAt,
      latestReason: latest?.title,
      syncStatus: profile?.syncStatus ?? latest?.syncStatus,
    );
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T) test) {
    for (final value in values) {
      if (test(value)) return value;
    }
    return null;
  }
}
