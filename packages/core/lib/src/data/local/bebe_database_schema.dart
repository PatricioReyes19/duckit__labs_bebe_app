import 'package:sqflite/sqflite.dart';

abstract final class BebeDatabaseSchema {
  static const version = 2;

  static const registerEvents = 'register_events';
  static const families = 'families';
  static const babies = 'babies';
  static const familyMembers = 'family_members';
  static const agendaEvents = 'agenda_events';
  static const healthEvents = 'health_events';
  static const healthMeasurements = 'health_measurements';
  static const appSettings = 'app_settings';

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
  caregiver_id TEXT,
  notes TEXT,
  details_json TEXT NOT NULL,
  schema_version INTEGER NOT NULL DEFAULT 1
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
  FOREIGN KEY (family_id) REFERENCES $families(id) ON DELETE CASCADE
)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_family_members_family
ON $familyMembers (family_id)
''');
    await database.execute('''
CREATE TABLE IF NOT EXISTS $agendaEvents (
  id TEXT PRIMARY KEY,
  baby_id TEXT NOT NULL,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  starts_at INTEGER NOT NULL,
  caregiver_id TEXT,
  sync_status TEXT NOT NULL,
  FOREIGN KEY (baby_id) REFERENCES $babies(id) ON DELETE CASCADE,
  FOREIGN KEY (caregiver_id) REFERENCES $familyMembers(id) ON DELETE SET NULL
)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_agenda_baby_starts
ON $agendaEvents (baby_id, starts_at)
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
  FOREIGN KEY (baby_id) REFERENCES $babies(id) ON DELETE CASCADE,
  FOREIGN KEY (caregiver_id) REFERENCES $familyMembers(id) ON DELETE SET NULL
)
''');
    await database.execute('''
CREATE INDEX IF NOT EXISTS idx_health_events_baby_starts
ON $healthEvents (baby_id, starts_at)
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
  text_size TEXT NOT NULL
)
''');
  }
}
