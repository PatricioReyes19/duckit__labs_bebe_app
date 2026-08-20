import 'dart:convert';

import 'package:sqflite/sqflite.dart';

abstract final class BebeDatabaseSchema {
  static const version = 11;

  static const registerEvents = 'register_events';
  static const families = 'families';
  static const babies = 'babies';
  static const familyMembers = 'family_members';
  static const agendaEvents = 'agenda_events';
  static const healthEvents = 'health_events';
  static const healthMeasurements = 'health_measurements';
  static const appSettings = 'app_settings';
  static const syncMetadata = 'sync_metadata';

  static Future<void> create(Database database) async {
    await createRegisterEvents(database);
    await createApplicationData(database);
  }

  static Future<void> createRegisterEvents(Database database) async {
    await database.execute('''
CREATE TABLE IF NOT EXISTS $registerEvents (
  id TEXT PRIMARY KEY,
  baby_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  occurred_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  caregiver_id TEXT,
  notes TEXT,
  details_json TEXT NOT NULL,
  sync_status TEXT NOT NULL DEFAULT 'pending',
  sync_error TEXT,
  schema_version INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (baby_id) REFERENCES $babies(id) ON DELETE CASCADE
)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_register_events_baby_occurred
ON $registerEvents (baby_id, occurred_at DESC)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_register_events_type
ON $registerEvents (event_type)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_register_events_sync
ON $registerEvents (sync_status, updated_at)
''');
    await database.execute('''
CREATE TABLE IF NOT EXISTS $syncMetadata (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
''');
  }

  static Future<void> upgradeRegisterEventsForSync(Database database) async {
    final columns = (await database.rawQuery(
      'PRAGMA table_info($registerEvents)',
    )).map((row) => row['name']).whereType<String>().toSet();
    if (!columns.contains('updated_at')) {
      await database.execute(
        'ALTER TABLE $registerEvents '
        'ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      );
      await database.execute(
        'UPDATE $registerEvents SET updated_at = created_at '
        'WHERE updated_at = 0',
      );
    }
    if (!columns.contains('deleted_at')) {
      await database.execute(
        'ALTER TABLE $registerEvents ADD COLUMN deleted_at INTEGER',
      );
    }
    if (!columns.contains('sync_status')) {
      await database.execute(
        "ALTER TABLE $registerEvents ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'pending'",
      );
    }
    if (!columns.contains('sync_error')) {
      await database.execute(
        'ALTER TABLE $registerEvents ADD COLUMN sync_error TEXT',
      );
    }
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_register_events_sync
ON $registerEvents (sync_status, updated_at)
''');
    await database.execute('''
CREATE TABLE IF NOT EXISTS $syncMetadata (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
''');
  }

  static Future<void> upgradeAgendaEventsForSync(Database database) async {
    final columns = (await database.rawQuery(
      'PRAGMA table_info($agendaEvents)',
    )).map((row) => row['name']).whereType<String>().toSet();
    if (!columns.contains('created_at')) {
      await database.execute(
        'ALTER TABLE $agendaEvents '
        'ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0',
      );
      await database.execute(
        'UPDATE $agendaEvents SET created_at = starts_at WHERE created_at = 0',
      );
    }
    if (!columns.contains('updated_at')) {
      await database.execute(
        'ALTER TABLE $agendaEvents '
        'ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      );
      await database.execute(
        'UPDATE $agendaEvents SET updated_at = starts_at WHERE updated_at = 0',
      );
    }
    if (!columns.contains('deleted_at')) {
      await database.execute(
        'ALTER TABLE $agendaEvents ADD COLUMN deleted_at INTEGER',
      );
    }
    if (!columns.contains('sync_error')) {
      await database.execute(
        'ALTER TABLE $agendaEvents ADD COLUMN sync_error TEXT',
      );
    }
    if (!columns.contains('source_register_event_id')) {
      await database.execute(
        'ALTER TABLE $agendaEvents ADD COLUMN source_register_event_id TEXT',
      );
    }
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_agenda_sync
ON $agendaEvents (sync_status, updated_at)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_agenda_source_register
ON $agendaEvents (source_register_event_id)
''');
  }

  static Future<void> createApplicationData(Database database) async {
    await database.execute('''
CREATE TABLE IF NOT EXISTS $families (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  active_baby_id TEXT NOT NULL
)
''');
    await database.execute('''
CREATE TABLE IF NOT EXISTS $babies (
  id TEXT PRIMARY KEY,
  family_id TEXT NOT NULL,
  name TEXT NOT NULL,
  birth_date INTEGER NOT NULL,
  avatar_asset_path TEXT,
  is_premature INTEGER NOT NULL DEFAULT 0,
  lives_in_rapa_nui INTEGER NOT NULL DEFAULT 0,
  has_rsv_risk INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (family_id) REFERENCES $families(id) ON DELETE CASCADE
)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_babies_family ON $babies (family_id)
''');
    await database.execute('''
CREATE TABLE IF NOT EXISTS $familyMembers (
  id TEXT PRIMARY KEY,
  family_id TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  access_description TEXT NOT NULL,
  status TEXT NOT NULL,
  can_write INTEGER NOT NULL DEFAULT 0,
  appointment_kind TEXT,
  appointment_json TEXT NOT NULL DEFAULT '{}',
  contact TEXT,
  invitation_code TEXT,
  invited_at INTEGER,
  invitation_expires_at INTEGER,
  FOREIGN KEY (family_id) REFERENCES $families(id) ON DELETE CASCADE
)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_family_members_family
ON $familyMembers (family_id)
''');
    await database.execute('''
CREATE UNIQUE INDEX IF NOT EXISTS idx_family_members_invitation_code
ON $familyMembers (invitation_code)
WHERE invitation_code IS NOT NULL
''');
    await database.execute('''
CREATE TABLE IF NOT EXISTS $agendaEvents (
  id TEXT PRIMARY KEY,
  baby_id TEXT NOT NULL,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  starts_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  caregiver_id TEXT,
  source_register_event_id TEXT,
  sync_status TEXT NOT NULL DEFAULT 'pending',
  sync_error TEXT,
  FOREIGN KEY (baby_id) REFERENCES $babies(id) ON DELETE CASCADE,
  FOREIGN KEY (caregiver_id) REFERENCES $familyMembers(id) ON DELETE SET NULL,
  FOREIGN KEY (source_register_event_id)
    REFERENCES $registerEvents(id) ON DELETE SET NULL
)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_agenda_baby_starts
ON $agendaEvents (baby_id, starts_at)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_agenda_sync
ON $agendaEvents (sync_status, updated_at)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_agenda_source_register
ON $agendaEvents (source_register_event_id)
''');
    await database.execute('''
CREATE TABLE IF NOT EXISTS $healthEvents (
  id TEXT PRIMARY KEY,
  baby_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  starts_at INTEGER NOT NULL,
  caregiver_id TEXT,
  status TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  sync_status TEXT NOT NULL DEFAULT 'pending',
  sync_error TEXT,
  FOREIGN KEY (baby_id) REFERENCES $babies(id) ON DELETE CASCADE,
  FOREIGN KEY (caregiver_id) REFERENCES $familyMembers(id) ON DELETE SET NULL
)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_health_events_baby_starts
ON $healthEvents (baby_id, starts_at)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_health_events_sync
ON $healthEvents (sync_status, updated_at)
''');
    await database.execute('''
CREATE TABLE IF NOT EXISTS $healthMeasurements (
  id TEXT PRIMARY KEY,
  baby_id TEXT NOT NULL,
  measurement_type TEXT NOT NULL,
  value REAL NOT NULL,
  unit TEXT NOT NULL,
  recorded_at INTEGER NOT NULL,
  source TEXT NOT NULL,
  FOREIGN KEY (baby_id) REFERENCES $babies(id) ON DELETE CASCADE
)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_health_measurements_baby_recorded
ON $healthMeasurements (baby_id, recorded_at DESC)
''');
    await upgradePendingSyncIndexesV8(database);
    await upgradeHealthAppointmentsV9(database);
    await database.execute('''
CREATE TABLE IF NOT EXISTS $appSettings (
  id TEXT PRIMARY KEY,
  theme_mode TEXT NOT NULL,
  high_contrast INTEGER NOT NULL,
  personal_reminders INTEGER NOT NULL,
  family_activity INTEGER NOT NULL,
  daily_summary INTEGER NOT NULL,
  reduce_motion INTEGER NOT NULL,
  wifi_only INTEGER NOT NULL,
  account_name TEXT NOT NULL,
  account_email TEXT NOT NULL,
  language TEXT NOT NULL,
  time_format TEXT NOT NULL,
  text_size TEXT NOT NULL,
  updated_at INTEGER NOT NULL DEFAULT 0,
  sync_status TEXT NOT NULL DEFAULT 'pending',
  sync_error TEXT
)
''');
  }

  /// Pending rows are a small, ordered subset of each offline-first table.
  /// These partial indexes keep synchronized history out of the queue scan.
  static Future<void> upgradePendingSyncIndexesV8(Database database) async {
    final existingTables = (await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    )).map((row) => row['name']).whereType<String>().toSet();
    if (existingTables.contains(registerEvents)) {
      await database.execute('''
CREATE INDEX IF NOT EXISTS idx_register_events_pending_updated
ON $registerEvents (updated_at)
WHERE sync_status != 'synced'
''');
    }
    if (existingTables.contains(agendaEvents)) {
      await database.execute('''
CREATE INDEX IF NOT EXISTS idx_agenda_events_pending_updated
ON $agendaEvents (updated_at)
WHERE sync_status != 'synced'
''');
    }
    if (existingTables.contains(healthEvents)) {
      await database.execute('''
CREATE INDEX IF NOT EXISTS idx_health_events_pending_updated
ON $healthEvents (updated_at)
WHERE sync_status != 'synced'
''');
    }
  }

  /// Amplía `health_events` de forma aditiva y conserva los IDs existentes.
  /// Los controles previos pasan a ser citas de control de niño sano; vacunas
  /// y filas desconocidas permanecen sin `appointment_kind`.
  static Future<void> upgradeHealthAppointmentsV9(Database database) async {
    final existingTables = (await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    )).map((row) => row['name']).whereType<String>().toSet();
    if (!existingTables.contains(healthEvents)) return;
    final columns = (await database.rawQuery(
      'PRAGMA table_info($healthEvents)',
    )).map((row) => row['name']).whereType<String>().toSet();
    if (!columns.contains('appointment_kind')) {
      await database.execute(
        'ALTER TABLE $healthEvents ADD COLUMN appointment_kind TEXT',
      );
    }
    if (!columns.contains('appointment_json')) {
      await database.execute(
        "ALTER TABLE $healthEvents ADD COLUMN appointment_json TEXT NOT NULL DEFAULT '{}'",
      );
    }
    await database.execute('''
UPDATE $healthEvents
SET appointment_kind = 'wellChildControl'
WHERE appointment_kind IS NULL
  AND event_type IN ('pediatricControl', 'growthControl')
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_health_appointments_baby_kind_starts
ON $healthEvents (baby_id, appointment_kind, starts_at)
WHERE appointment_kind IS NOT NULL
''');
    if (existingTables.contains(registerEvents)) {
      await _migrateLegacyMedicalConsultations(database);
    }
  }

  /// Persists the explicit write grant returned by `baby_caregivers` and care
  /// invitation RPCs. Existing rows deliberately start read-only until their
  /// next authenticated family pull confirms otherwise.
  static Future<void> upgradeFamilyMemberPermissionsV10(
    Database database,
  ) async {
    final existingTables = (await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    )).map((row) => row['name']).whereType<String>().toSet();
    if (!existingTables.contains(familyMembers)) return;
    final columns = (await database.rawQuery(
      'PRAGMA table_info($familyMembers)',
    )).map((row) => row['name']).whereType<String>().toSet();
    if (!columns.contains('can_write')) {
      await database.execute(
        'ALTER TABLE $familyMembers '
        'ADD COLUMN can_write INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  /// Adds explicit eligibility facts. They are opt-in flags: unknown data is
  /// false, which prevents risk-only immunizations from being suggested.
  static Future<void> upgradeBabyImmunizationEligibilityV11(
    Database database,
  ) async {
    final tables = (await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    )).map((row) => row['name']).whereType<String>().toSet();
    if (!tables.contains(babies)) return;
    final columns = (await database.rawQuery(
      'PRAGMA table_info($babies)',
    )).map((row) => row['name']).whereType<String>().toSet();
    for (final column in const [
      'is_premature',
      'lives_in_rapa_nui',
      'has_rsv_risk',
    ]) {
      if (!columns.contains(column)) {
        await database.execute(
          'ALTER TABLE $babies ADD COLUMN $column INTEGER NOT NULL DEFAULT 0',
        );
      }
    }
  }

  /// Migrates legacy JSON payloads in Dart so this upgrade is compatible with
  /// every SQLite build supported by Android, including builds without JSON1.
  static Future<void> _migrateLegacyMedicalConsultations(
    Database database,
  ) async {
    final legacyEvents = await database.query(
      registerEvents,
      columns: const [
        'id',
        'baby_id',
        'occurred_at',
        'created_at',
        'updated_at',
        'caregiver_id',
        'notes',
        'details_json',
      ],
      where: "event_type = ? AND deleted_at IS NULL",
      whereArgs: const ['clinical_observation'],
    );
    final batch = database.batch();

    for (final event in legacyEvents) {
      final rawDetails = event['details_json'];
      if (rawDetails is! String || rawDetails.trim().isEmpty) continue;

      final Map<String, dynamic> details;
      try {
        final decoded = jsonDecode(rawDetails);
        if (decoded is! Map) continue;
        details = Map<String, dynamic>.from(decoded);
      } on FormatException {
        continue;
      }
      if (details['observation_type'] != 'medical_consultation') continue;

      final occurredAt = event['occurred_at'];
      if (occurredAt is! num) continue;
      final timestamp = occurredAt.toInt();
      final occurredAtIso = DateTime.fromMillisecondsSinceEpoch(
        timestamp,
        isUtc: true,
      ).toIso8601String();
      final title = _nonEmptyString(details['title']) ?? 'Consulta pediátrica';
      final description = _stringOrEmpty(details['description']);
      final indications = [
        _nonEmptyString(details['treatment']),
        _nonEmptyString(details['follow_up']),
        _nonEmptyString(details['vigilance']),
      ].whereType<String>().join(' ');

      batch.insert(healthEvents, {
        'id': event['id'],
        'baby_id': event['baby_id'],
        'event_type': 'consultation',
        'title': title,
        'description': description,
        'starts_at': timestamp,
        'caregiver_id': null,
        'status': 'completed',
        'appointment_kind': 'consultation',
        'appointment_json': jsonEncode({
          'reason': _stringOrEmpty(details['title']),
          'timezone': 'UTC',
          'attended_at': occurredAtIso,
          'completed_at': occurredAtIso,
          'professional_name': _stringOrEmpty(details['pediatrician']),
          'clinical_summary': description,
          'indications': indications,
          'notes_before_visit': _stringOrEmpty(event['notes']),
          'created_by': _stringOrEmpty(event['caregiver_id']),
        }),
        'created_at': event['created_at'],
        'updated_at': event['updated_at'],
        'sync_status': 'pending',
        'sync_error': null,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  static String _stringOrEmpty(Object? value) => value is String ? value : '';

  static String? _nonEmptyString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static Future<void> upgradeHealthAndSettingsForSync(Database database) async {
    final healthColumns = (await database.rawQuery(
      'PRAGMA table_info($healthEvents)',
    )).map((row) => row['name']).whereType<String>().toSet();
    if (!healthColumns.contains('created_at')) {
      await database.execute(
        'ALTER TABLE $healthEvents ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0',
      );
      await database.execute(
        'UPDATE $healthEvents SET created_at = starts_at WHERE created_at = 0',
      );
    }
    if (!healthColumns.contains('updated_at')) {
      await database.execute(
        'ALTER TABLE $healthEvents ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      );
      await database.execute(
        'UPDATE $healthEvents SET updated_at = starts_at WHERE updated_at = 0',
      );
    }
    if (!healthColumns.contains('sync_status')) {
      await database.execute(
        "ALTER TABLE $healthEvents ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'pending'",
      );
    }
    if (!healthColumns.contains('sync_error')) {
      await database.execute(
        'ALTER TABLE $healthEvents ADD COLUMN sync_error TEXT',
      );
    }
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_health_events_sync
ON $healthEvents (sync_status, updated_at)
''');

    final settingsColumns = (await database.rawQuery(
      'PRAGMA table_info($appSettings)',
    )).map((row) => row['name']).whereType<String>().toSet();
    if (!settingsColumns.contains('updated_at')) {
      await database.execute(
        'ALTER TABLE $appSettings ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      );
      await database.update(appSettings, {
        'updated_at': DateTime.now().toUtc().millisecondsSinceEpoch,
      }, where: 'updated_at = 0');
    }
    if (!settingsColumns.contains('sync_status')) {
      await database.execute(
        "ALTER TABLE $appSettings ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'pending'",
      );
    }
    if (!settingsColumns.contains('sync_error')) {
      await database.execute(
        'ALTER TABLE $appSettings ADD COLUMN sync_error TEXT',
      );
    }
  }

  static Future<void> upgradeFamilyInvitations(Database database) async {
    final columns = (await database.rawQuery(
      'PRAGMA table_info($familyMembers)',
    )).map((row) => row['name']).whereType<String>().toSet();
    if (!columns.contains('contact')) {
      await database.execute(
        'ALTER TABLE $familyMembers ADD COLUMN contact TEXT',
      );
    }
    if (!columns.contains('invitation_code')) {
      await database.execute(
        'ALTER TABLE $familyMembers ADD COLUMN invitation_code TEXT',
      );
    }
    if (!columns.contains('invited_at')) {
      await database.execute(
        'ALTER TABLE $familyMembers ADD COLUMN invited_at INTEGER',
      );
    }
    if (!columns.contains('invitation_expires_at')) {
      await database.execute(
        'ALTER TABLE $familyMembers ADD COLUMN invitation_expires_at INTEGER',
      );
    }
    await database.execute('''
CREATE UNIQUE INDEX IF NOT EXISTS idx_family_members_invitation_code
ON $familyMembers (invitation_code)
WHERE invitation_code IS NOT NULL
''');
  }

  /// Rebuilds the two event tables because SQLite cannot add foreign-key
  /// constraints with `ALTER TABLE ... ADD CONSTRAINT`.
  ///
  /// `onUpgrade` is executed by sqflite inside its schema transaction. Every
  /// preflight runs before the first destructive statement, so an orphan
  /// aborts the upgrade and preserves the complete v6 database, including
  /// pending offline mutations.
  static Future<void> upgradeCoreRelationsV7(Database database) async {
    final orphanRegisters = await database.rawQuery('''
SELECT event.id, event.baby_id AS missing_reference
FROM $registerEvents event
LEFT JOIN $babies baby ON baby.id = event.baby_id
WHERE baby.id IS NULL
LIMIT 20
''');
    final orphanAgendaBabies = await database.rawQuery('''
SELECT event.id, event.baby_id AS missing_reference
FROM $agendaEvents event
LEFT JOIN $babies baby ON baby.id = event.baby_id
WHERE baby.id IS NULL
LIMIT 20
''');
    final orphanAgendaSources = await database.rawQuery('''
SELECT event.id, event.source_register_event_id AS missing_reference
FROM $agendaEvents event
LEFT JOIN $registerEvents source
  ON source.id = event.source_register_event_id
WHERE event.source_register_event_id IS NOT NULL
  AND source.id IS NULL
LIMIT 20
''');

    final integrityErrors = <String>[
      if (orphanRegisters.isNotEmpty)
        'register_events.baby_id: ${_orphanSummary(orphanRegisters)}',
      if (orphanAgendaBabies.isNotEmpty)
        'agenda_events.baby_id: ${_orphanSummary(orphanAgendaBabies)}',
      if (orphanAgendaSources.isNotEmpty)
        'agenda_events.source_register_event_id: '
            '${_orphanSummary(orphanAgendaSources)}',
    ];
    if (integrityErrors.isNotEmpty) {
      throw StateError(
        'SQLite v7 migration aborted; orphan references must be repaired '
        'without deleting offline data. ${integrityErrors.join(' | ')}',
      );
    }

    const registerEventsV7 = 'register_events_v7';
    const agendaEventsV7 = 'agenda_events_v7';
    await database.execute('''
CREATE TABLE $registerEventsV7 (
  id TEXT PRIMARY KEY,
  baby_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  occurred_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  caregiver_id TEXT,
  notes TEXT,
  details_json TEXT NOT NULL,
  sync_status TEXT NOT NULL DEFAULT 'pending',
  sync_error TEXT,
  schema_version INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (baby_id) REFERENCES $babies(id) ON DELETE CASCADE
)
''');
    await database.execute('''
INSERT INTO $registerEventsV7 (
  id, baby_id, event_type, occurred_at, created_at, updated_at, deleted_at,
  caregiver_id, notes, details_json, sync_status, sync_error, schema_version
)
SELECT
  id, baby_id, event_type, occurred_at, created_at, updated_at, deleted_at,
  caregiver_id, notes, details_json, sync_status, sync_error, schema_version
FROM $registerEvents
''');

    await database.execute('''
CREATE TABLE $agendaEventsV7 (
  id TEXT PRIMARY KEY,
  baby_id TEXT NOT NULL,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  starts_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  caregiver_id TEXT,
  source_register_event_id TEXT,
  sync_status TEXT NOT NULL DEFAULT 'pending',
  sync_error TEXT,
  FOREIGN KEY (baby_id) REFERENCES $babies(id) ON DELETE CASCADE,
  FOREIGN KEY (caregiver_id) REFERENCES $familyMembers(id) ON DELETE SET NULL,
  FOREIGN KEY (source_register_event_id)
    REFERENCES $registerEventsV7(id) ON DELETE SET NULL
)
''');
    await database.execute('''
INSERT INTO $agendaEventsV7 (
  id, baby_id, category, title, description, starts_at, created_at, updated_at,
  deleted_at, caregiver_id, source_register_event_id, sync_status, sync_error
)
SELECT
  id, baby_id, category, title, description, starts_at, created_at, updated_at,
  deleted_at, caregiver_id, source_register_event_id, sync_status, sync_error
FROM $agendaEvents
''');

    await database.execute('DROP TABLE $agendaEvents');
    await database.execute('DROP TABLE $registerEvents');
    await database.execute(
      'ALTER TABLE $registerEventsV7 RENAME TO $registerEvents',
    );
    await database.execute(
      'ALTER TABLE $agendaEventsV7 RENAME TO $agendaEvents',
    );

    await database.execute('''
CREATE INDEX idx_register_events_baby_occurred
ON $registerEvents (baby_id, occurred_at DESC)
''');
    await database.execute('''
CREATE INDEX idx_register_events_type ON $registerEvents (event_type)
''');
    await database.execute('''
CREATE INDEX idx_register_events_sync
ON $registerEvents (sync_status, updated_at)
''');
    await database.execute('''
CREATE INDEX idx_agenda_baby_starts ON $agendaEvents (baby_id, starts_at)
''');
    await database.execute('''
CREATE INDEX idx_agenda_sync ON $agendaEvents (sync_status, updated_at)
''');
    await database.execute('''
CREATE INDEX idx_agenda_source_register
ON $agendaEvents (source_register_event_id)
''');

    final violations = await database.rawQuery('PRAGMA foreign_key_check');
    if (violations.isNotEmpty) {
      throw StateError(
        'SQLite v7 migration failed foreign_key_check: $violations',
      );
    }
  }

  static String _orphanSummary(List<Map<String, Object?>> rows) =>
      rows.map((row) => '${row['id']}->${row['missing_reference']}').join(', ');
}
