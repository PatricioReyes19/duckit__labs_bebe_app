import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late BebeDatabase database;
  late SqliteHealthRepository health;
  late List<String> ids;

  setUp(() {
    ids = ['appointment-1', 'appointment-2'];
    database = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
      seedDemoData: true,
    );
    health = SqliteHealthRepository(
      database,
      idGenerator: () => ids.removeAt(0),
      clock: () => DateTime.utc(2026, 8, 19, 12),
    );
  });

  tearDown(() async {
    await health.close();
    await database.close();
  });

  test('UT-HEALTH-APPT-001 future appointment persists as scheduled', () async {
    final created = await health.createEvent(
      HealthEventDraft(
        babyId: BebeSeedData.activeBabyId,
        type: HealthEventType.consultation,
        title: 'Consulta respiratoria',
        description: 'Tos nocturna',
        startsAt: DateTime.utc(2026, 8, 24, 15, 30),
        status: HealthEventStatus.scheduled,
        appointmentKind: HealthAppointmentKind.consultation,
        reason: 'Tos nocturna',
        timezone: 'America/Santiago',
        professionalName: 'Dra. Soto',
        questionsToAsk: const ['¿Necesita control?'],
      ),
    );

    final restored = await health.getEvent(created.id);
    expect(restored?.id, 'appointment-1');
    expect(restored?.appointmentKind, HealthAppointmentKind.consultation);
    expect(restored?.status, HealthEventStatus.scheduled);
    expect(restored?.professionalName, 'Dra. Soto');
    expect(restored?.questionsToAsk, ['¿Necesita control?']);
  });

  test('UT-HEALTH-APPT-002 due never becomes not-attended implicitly', () {
    final today = HealthEventEntity(
      id: 'today',
      babyId: 'baby',
      type: HealthEventType.pediatricControl,
      title: 'Control',
      description: '',
      startsAt: DateTime(2026, 8, 19, 9),
      status: HealthEventStatus.scheduled,
      appointmentKind: HealthAppointmentKind.wellChildControl,
    );
    final yesterday = HealthEventEntity(
      id: 'yesterday',
      babyId: 'baby',
      type: HealthEventType.pediatricControl,
      title: 'Control',
      description: '',
      startsAt: DateTime(2026, 8, 18, 9),
      status: HealthEventStatus.scheduled,
      appointmentKind: HealthAppointmentKind.wellChildControl,
    );

    expect(
      today.effectiveStatus(DateTime(2026, 8, 19, 18)),
      HealthEventStatus.due,
    );
    expect(
      yesterday.effectiveStatus(DateTime(2026, 8, 19, 18)),
      HealthEventStatus.attendancePending,
    );
  });

  test('UT-HEALTH-APPT-003 update and completion preserve identity', () async {
    final created = await health.createEvent(
      HealthEventDraft(
        babyId: BebeSeedData.activeBabyId,
        type: HealthEventType.consultation,
        title: 'Consulta',
        description: '',
        startsAt: DateTime.utc(2026, 8, 19, 10),
        status: HealthEventStatus.attendedPendingSummary,
        appointmentKind: HealthAppointmentKind.consultation,
      ),
    );
    final completed = await health.updateEvent(
      created.id,
      HealthEventPatch(
        status: HealthEventStatus.completed,
        attendedAt: DateTime.utc(2026, 8, 19, 10),
        completedAt: DateTime.utc(2026, 8, 19, 12),
        clinicalSummary: 'Evolución normal',
        indications: 'Control en un mes',
      ),
    );

    expect(completed?.id, created.id);
    expect(completed?.status, HealthEventStatus.completed);
    expect(completed?.clinicalSummary, 'Evolución normal');
  });

  test('UT-HEALTH-APPT-004 reschedule retains traceability', () async {
    final original = await health.createEvent(
      HealthEventDraft(
        babyId: BebeSeedData.activeBabyId,
        type: HealthEventType.pediatricControl,
        title: 'Control de 6 meses',
        description: '',
        startsAt: DateTime.utc(2026, 8, 21, 14),
        appointmentKind: HealthAppointmentKind.wellChildControl,
      ),
    );
    final replacement = await health.rescheduleEvent(
      original.id,
      DateTime.utc(2026, 8, 28, 14),
    );
    final previous = await health.getEvent(original.id);

    expect(previous?.id, original.id);
    expect(previous?.status, HealthEventStatus.rescheduled);
    expect(previous?.nextAppointmentId, replacement?.id);
    expect(replacement?.id, 'appointment-2');
    expect(replacement?.status, HealthEventStatus.scheduled);
  });

  test(
    'IT-HEALTH-APPT-001 Agenda projects the canonical appointment',
    () async {
      final agenda = SqliteAgendaRepository(database);
    final register = SqliteRegisterEventRepository(database: database);
      final settings = SqliteAppSettingsRepository(database);
    addTearDown(register.close);
      await health.createEvent(
        HealthEventDraft(
          babyId: BebeSeedData.activeBabyId,
          type: HealthEventType.consultation,
          title: 'Consulta respiratoria',
          description: '',
          startsAt: DateTime.utc(2026, 8, 24, 15, 30),
          appointmentKind: HealthAppointmentKind.consultation,
        ),
      );
      await health.createEvent(
        HealthEventDraft(
          babyId: BebeSeedData.activeBabyId,
          type: HealthEventType.pediatricControl,
          title: 'Control completado',
          description: '',
          startsAt: DateTime.utc(2026, 8, 19, 10),
          status: HealthEventStatus.completed,
          appointmentKind: HealthAppointmentKind.wellChildControl,
        ),
      );

      final overview = await GetAgendaOverview(
        agenda,
        register,
        settings,
        health,
      )(BebeSeedData.activeBabyId);
      final projected = overview.events.singleWhere(
        (event) => event.id == 'health:appointment-1',
      );

      expect(projected.category, AgendaCategory.controls);
      expect(projected.title, 'Consulta respiratoria');
      expect(projected.description, startsWith('Consulta · Programado'));
      expect(
        overview.events.where((event) => event.id == 'health:appointment-2'),
        isEmpty,
      );
    },
  );

  test('UT-HEALTH-APPT-005 v9 backfills legacy consultation ID', () async {
    final raw = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(raw.close);
    await raw.execute('''
CREATE TABLE register_events (
  id TEXT PRIMARY KEY, baby_id TEXT NOT NULL, event_type TEXT NOT NULL,
  occurred_at INTEGER NOT NULL, created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, deleted_at INTEGER, caregiver_id TEXT,
  notes TEXT, details_json TEXT NOT NULL, sync_status TEXT,
  sync_error TEXT, schema_version INTEGER NOT NULL
)
''');
    await raw.execute('''
CREATE TABLE health_events (
  id TEXT PRIMARY KEY, baby_id TEXT NOT NULL, event_type TEXT NOT NULL,
  title TEXT NOT NULL, description TEXT NOT NULL, starts_at INTEGER NOT NULL,
  caregiver_id TEXT, status TEXT NOT NULL, created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, sync_status TEXT, sync_error TEXT
)
''');
    final timestamp = DateTime.utc(2026, 8, 18, 10).millisecondsSinceEpoch;
    await raw.insert('register_events', {
      'id': 'legacy-consultation',
      'baby_id': 'baby-legacy',
      'event_type': 'clinical_observation',
      'occurred_at': timestamp,
      'created_at': timestamp,
      'updated_at': timestamp,
      'details_json':
          '{"observation_type":"medical_consultation",'
          '"title":"Fiebre","description":"Sin alarma",'
          '"pediatrician":"Dra. Paz"}',
      'sync_status': 'synced',
      'schema_version': 2,
    });

    await BebeDatabaseSchema.upgradeHealthAppointmentsV9(raw);
    final migrated = await raw.query(
      'health_events',
      where: 'id = ?',
      whereArgs: ['legacy-consultation'],
    );

    expect(migrated, hasLength(1));
    expect(migrated.single['appointment_kind'], 'consultation');
    expect(migrated.single['event_type'], 'consultation');
    expect(migrated.single['status'], 'completed');
  });

  test('UT-HEALTH-APPT-006 v9 ignores corrupt JSON and keeps migrating', () async {
    final raw = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(raw.close);
    await raw.execute('''
CREATE TABLE register_events (
  id TEXT PRIMARY KEY, baby_id TEXT NOT NULL, event_type TEXT NOT NULL,
  occurred_at INTEGER NOT NULL, created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, deleted_at INTEGER, caregiver_id TEXT,
  notes TEXT, details_json TEXT NOT NULL, sync_status TEXT,
  sync_error TEXT, schema_version INTEGER NOT NULL
)
''');
    await raw.execute('''
CREATE TABLE health_events (
  id TEXT PRIMARY KEY, baby_id TEXT NOT NULL, event_type TEXT NOT NULL,
  title TEXT NOT NULL, description TEXT NOT NULL, starts_at INTEGER NOT NULL,
  caregiver_id TEXT, status TEXT NOT NULL, created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, sync_status TEXT, sync_error TEXT
)
''');
    const timestamp = 1787047200000;
    await raw.insert('register_events', {
      'id': 'corrupt',
      'baby_id': 'baby',
      'event_type': 'clinical_observation',
      'occurred_at': timestamp,
      'created_at': timestamp,
      'updated_at': timestamp,
      'details_json': '{not-json',
      'schema_version': 2,
    });
    await raw.insert('register_events', {
      'id': 'valid',
      'baby_id': 'baby',
      'event_type': 'clinical_observation',
      'occurred_at': timestamp,
      'created_at': timestamp,
      'updated_at': timestamp,
      'details_json': '{"observation_type":"medical_consultation"}',
      'schema_version': 2,
    });

    await BebeDatabaseSchema.upgradeHealthAppointmentsV9(raw);
    await BebeDatabaseSchema.upgradeHealthAppointmentsV9(raw);

    final migrated = await raw.query('health_events');
    expect(migrated, hasLength(1));
    expect(migrated.single['id'], 'valid');
    expect(migrated.single['title'], 'Consulta pediátrica');
    expect(migrated.single['appointment_json'], contains('"timezone":"UTC"'));
  });
}
