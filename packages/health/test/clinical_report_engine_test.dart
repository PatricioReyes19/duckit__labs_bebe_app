import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/clinical_reports/clinical_report_engine.dart';

void main() {
  final now = DateTime.utc(2026, 8, 18, 12);
  final baby = BabyEntity(
    id: 'baby-1',
    familyId: 'family-1',
    name: 'Mateo',
    birthDate: DateTime.utc(2026, 5, 18),
  );
  const engine = ClinicalReportEngine();

  ClinicalReportRequest request(
    ClinicalReportType type, {
    bool includePhotos = false,
    bool includeRawTimeline = false,
    bool includePrivateNotes = false,
    bool includeCaregiverNames = false,
    int days = 1,
  }) => ClinicalReportRequest(
    babyId: baby.id,
    type: type,
    dateFrom: now.subtract(Duration(days: days)),
    dateTo: now,
    includePhotos: includePhotos,
    includeRawTimeline: includeRawTimeline,
    includePrivateNotes: includePrivateNotes,
    includeCaregiverNames: includeCaregiverNames,
  );

  test('feeding aggregates a seven-day period and supports empty data', () {
    final events = List.generate(
      14,
      (index) => _event(
        'feeding-$index',
        now.subtract(Duration(hours: index * 10)),
        RegisterEventType.feeding,
        const {'subtype': 'bottle', 'amount_ml': 120},
      ),
    );
    final populated = engine.generate(
      request: request(ClinicalReportType.pediatricControl, days: 7),
      baby: baby,
      registerEvents: events,
      healthEvents: const [],
      growthPoints: const [],
      generatedAt: now,
    );
    final empty = engine.generate(
      request: request(ClinicalReportType.pediatricControl, days: 7),
      baby: baby,
      registerEvents: const [],
      healthEvents: const [],
      growthPoints: const [],
      generatedAt: now,
    );

    expect(populated.feeding.recordCount, 14);
    expect(populated.feeding.averagePerDay, 2);
    expect(populated.feeding.averageVolumeMl, 120);
    expect(empty.feeding.recordCount, 0);
    expect(empty.feeding.averageVolumeMl, isNull);
  });

  test('pediatric report aggregates diapers without a raw timeline', () {
    final data = engine.generate(
      request: request(ClinicalReportType.pediatricControl),
      baby: baby,
      registerEvents: [
        _event(
          'wet',
          now.subtract(const Duration(hours: 5)),
          RegisterEventType.diaper,
          const {'subtype': 'wet'},
        ),
        _event(
          'mixed',
          now.subtract(const Duration(hours: 3)),
          RegisterEventType.diaper,
          const {
            'subtype': 'mixed',
            'appearance': 'liquid',
            'color': 'yellow',
          },
        ),
      ],
      healthEvents: const [],
      growthPoints: const [],
      generatedAt: now,
    );

    expect(data.elimination.wetDiapers, 2);
    expect(data.elimination.stools, 1);
    expect(data.elimination.predominantConsistency, 'liquid');
    expect(data.timeline, isEmpty);
  });

  test('symptom report can include contextual elimination detail', () {
    final data = engine.generate(
      request: request(ClinicalReportType.symptomConsultation),
      baby: baby,
      registerEvents: [
        _event(
          'diaper',
          now.subtract(const Duration(hours: 2)),
          RegisterEventType.diaper,
          const {'subtype': 'dirty', 'symptoms': 'Moco visible'},
        ),
      ],
      healthEvents: const [],
      growthPoints: const [],
      generatedAt: now,
    );

    expect(data.timeline, hasLength(1));
    expect(data.timeline.single.type, 'Eliminación');
    expect(data.elimination.bloodOrMucusRecorded, isTrue);
  });

  test('medication uses sin registro semantics instead of omitted dose', () {
    final data = engine.generate(
      request: request(ClinicalReportType.medicationFollowUp),
      baby: baby,
      registerEvents: [
        _event(
          'medication',
          now.subtract(const Duration(days: 1)),
          RegisterEventType.medication,
          {
            'name': 'Paracetamol',
            'dose': 2.5,
            'unit': 'mL',
            'frequency': 'Cada 8 horas',
            'schedule_next_doses': true,
            'end_date': now.toIso8601String(),
          },
        ),
      ],
      healthEvents: const [],
      growthPoints: const [],
      generatedAt: now,
    );

    expect(data.medications.single.registeredAdministrations, 1);
    expect(data.medications.single.unregisteredAdministrations, 3);
    expect(data.summary, contains('sin registro'));
    expect(data.summary, isNot(contains('omitida')));
  });

  test('sleep reports averages and excludes an active duration', () {
    final data = engine.generate(
      request: request(ClinicalReportType.pediatricControl),
      baby: baby,
      registerEvents: [
        _sleep('sleep-1', now.subtract(const Duration(hours: 8)), 60),
        _sleep('sleep-2', now.subtract(const Duration(hours: 5)), 120),
        _event(
          'active',
          now.subtract(const Duration(hours: 2)),
          RegisterEventType.sleep,
          const {'sleep_status': 'ongoing', 'end_at': null},
        ),
      ],
      healthEvents: const [],
      growthPoints: const [],
      generatedAt: now,
    );

    expect(data.sleep.averageMinutes, 90);
    expect(data.sleep.completedSessions, 2);
    expect(data.sleep.activeSessions, 1);
  });

  test('photos and private notes are excluded by default', () {
    final observation = RegisteredEvent(
      id: 'observation',
      babyId: baby.id,
      type: RegisterEventType.clinicalObservation,
      occurredAt: now,
      createdAt: now,
      notes: 'Nota privada',
      details: const {
        'observation_type': 'skin',
        'description': 'Irritación leve',
        'photo_paths': ['private/photo.jpg'],
      },
    );
    final data = engine.generate(
      request: request(ClinicalReportType.pediatricControl),
      baby: baby,
      registerEvents: [observation],
      healthEvents: const [],
      growthPoints: const [],
      generatedAt: now,
    );

    expect(data.photoPaths, isEmpty);
    expect(data.observations.single.detail, isNot(contains('Nota privada')));
  });

  test('growth points remain ordered for the renderer trend', () {
    final data = engine.generate(
      request: request(ClinicalReportType.growthNutrition),
      baby: baby,
      registerEvents: const [],
      healthEvents: const [],
      growthPoints: [
        ClinicalGrowthPoint(
          type: 'weight',
          value: 6.4,
          unit: 'kg',
          recordedAt: now.subtract(const Duration(hours: 2)),
        ),
        ClinicalGrowthPoint(
          type: 'weight',
          value: 6.2,
          unit: 'kg',
          recordedAt: now.subtract(const Duration(hours: 8)),
        ),
      ],
      generatedAt: now,
    );

    expect(data.growth.map((point) => point.value), [6.2, 6.4]);
  });

  test('full history includes timeline and caregiver names only by opt-in', () {
    final event = RegisteredEvent(
      id: 'feeding-caregiver',
      babyId: baby.id,
      type: RegisterEventType.feeding,
      occurredAt: now.subtract(const Duration(hours: 2)),
      createdAt: now.subtract(const Duration(hours: 2)),
      caregiverId: 'caregiver-1',
      details: const {'subtype': 'bottle', 'amount_ml': 90},
    );
    final private = engine.generate(
      request: request(ClinicalReportType.fullHistory),
      baby: baby,
      registerEvents: [event],
      healthEvents: const [],
      growthPoints: const [],
      caregiverNames: const {'caregiver-1': 'Mamá'},
      generatedAt: now,
    );
    final identified = engine.generate(
      request: request(
        ClinicalReportType.fullHistory,
        includeCaregiverNames: true,
      ),
      baby: baby,
      registerEvents: [event],
      healthEvents: const [],
      growthPoints: const [],
      caregiverNames: const {'caregiver-1': 'Mamá'},
      generatedAt: now,
    );

    expect(private.timeline, hasLength(1));
    expect(private.timeline.single.caregiverName, isNull);
    expect(identified.timeline.single.caregiverName, 'Mamá');
  });
}

RegisteredEvent _event(
  String id,
  DateTime occurredAt,
  RegisterEventType type,
  Map<String, Object?> details,
) => RegisteredEvent(
  id: id,
  babyId: 'baby-1',
  type: type,
  occurredAt: occurredAt,
  createdAt: occurredAt,
  details: details,
  syncStatus: RegisterSyncStatus.synced,
);

RegisteredEvent _sleep(String id, DateTime occurredAt, int minutes) => _event(
  id,
  occurredAt,
  RegisterEventType.sleep,
  {
    'sleep_status': 'completed',
    'duration_minutes': minutes,
    'end_at': occurredAt.add(Duration(minutes: minutes)).toIso8601String(),
  },
);
