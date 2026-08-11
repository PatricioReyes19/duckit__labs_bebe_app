import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

enum HealthReportRange { day, week, month }

enum HealthFlowSaveKind { vaccine, measurement, consultation, observation }

class HealthFlowSaveResult {
  const HealthFlowSaveResult({required this.kind, required this.savedAt});

  final HealthFlowSaveKind kind;
  final DateTime savedAt;
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
    required HealthRepository healthRepository,
    required RegisterEventSyncService registerSyncService,
    Connectivity? connectivity,
  }) : _getFamilyOverview = getFamilyOverview,
       _getHealthOverview = getHealthOverview,
       _getRegisterEvents = getRegisterEvents,
       _saveRegisterEvent = saveRegisterEvent,
       _healthRepository = healthRepository,
       _registerSyncService = registerSyncService,
       _connectivity = connectivity ?? Connectivity(),
       _syncState = registerSyncService.state {
    _syncSubscription = _registerSyncService.states.listen((state) {
      _syncState = state;
      notifyListeners();
    });
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
      onError: (_) {},
    );
    unawaited(_refreshConnectivity());
  }

  final GetFamilyOverview _getFamilyOverview;
  final GetHealthOverview _getHealthOverview;
  final GetRegisterEvents _getRegisterEvents;
  final SaveRegisterEvent _saveRegisterEvent;
  final HealthRepository _healthRepository;
  final RegisterEventSyncService _registerSyncService;
  final Connectivity _connectivity;

  late final StreamSubscription<RegisterSyncState> _syncSubscription;
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
  Object? _error;

  FamilyOverviewEntity? get family => _family;
  BabyEntity? get activeBaby => _family?.activeBaby;
  HealthOverviewEntity? get overview => _overview;
  List<RegisteredEvent> get records => List.unmodifiable(_records);
  RegisterSyncState get syncState => _syncState;
  HealthReportRange get reportRange => _reportRange;
  bool get isLoading => _isLoading;
  bool get offlineMode => _manualOfflineMode || !_hasConnectivity;
  bool get networkUnavailable => !_hasConnectivity;
  Object? get error => _error;

  List<RegisteredEvent> get measurementRecords => _records
      .where((event) => event.type == RegisterEventType.measurement)
      .toList(growable: false);

  List<RegisteredEvent> get clinicalRecords => _records
      .where((event) => event.type == RegisterEventType.clinicalObservation)
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
    await _saveRegisterEvent(
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
    await _healthRepository.createEvent(
      HealthEventDraft(
        babyId: babyId,
        type: HealthEventType.vaccine,
        title: title,
        description: 'Aplicada en ${location.trim()}',
        startsAt: occurredAt,
        status: HealthEventStatus.completed,
      ),
    );
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
    await _saveRegisterEvent(
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
    await _saveRegisterEvent(
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
    unawaited(_connectivitySubscription?.cancel());
    super.dispose();
  }
}
