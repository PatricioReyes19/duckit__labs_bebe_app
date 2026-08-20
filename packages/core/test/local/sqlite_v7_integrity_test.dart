import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'bebeapp-sqlite-v7-',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('new databases reject register rows for a missing baby', () async {
    final database = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: '${temporaryDirectory.path}/fresh.sqlite',
    );
    addTearDown(database.close);
    final sqlite = await database.database;

    await expectLater(
      sqlite.insert(BebeDatabaseSchema.registerEvents, {
        'id': 'orphan-register',
        'baby_id': 'missing-baby',
        'event_type': 'medication',
        'occurred_at': 1,
        'created_at': 1,
        'updated_at': 1,
        'details_json': '{}',
        'sync_status': 'pending',
        'schema_version': 1,
      }),
      throwsA(isA<DatabaseException>()),
    );

    await _insertFamilyGraph(sqlite);
    await _insertRegister(sqlite, id: 'valid-register', babyId: 'baby-1');
    expect(
      await sqlite.query(
        BebeDatabaseSchema.registerEvents,
        where: 'id = ?',
        whereArgs: ['valid-register'],
      ),
      hasLength(1),
    );
  });

  test('v6 to v7 preserves valid pending events and adds both FKs', () async {
    final path = '${temporaryDirectory.path}/valid-v6.sqlite';
    final fixture = await _openV6Fixture(path);
    await _insertFamilyGraph(fixture);
    await _insertRegister(fixture, id: 'pending-register', babyId: 'baby-1');
    await _insertAgenda(
      fixture,
      id: 'pending-agenda',
      babyId: 'baby-1',
      sourceRegisterEventId: 'pending-register',
    );
    await fixture.close();

    final database = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: path,
    );
    addTearDown(database.close);
    final upgraded = await database.database;

    expect(await upgraded.getVersion(), BebeDatabaseSchema.version);
    expect(
      await upgraded.query(
        BebeDatabaseSchema.registerEvents,
        where: 'id = ?',
        whereArgs: ['pending-register'],
      ),
      hasLength(1),
    );
    expect(
      await upgraded.query(
        BebeDatabaseSchema.agendaEvents,
        where: 'id = ?',
        whereArgs: ['pending-agenda'],
      ),
      hasLength(1),
    );
    final registerRows = await upgraded.query(
      BebeDatabaseSchema.registerEvents,
      columns: ['sync_status'],
    );
    final agendaRows = await upgraded.query(
      BebeDatabaseSchema.agendaEvents,
      columns: ['sync_status'],
    );
    expect(registerRows.single['sync_status'], 'pending');
    expect(agendaRows.single['sync_status'], 'pending');

    final registerForeignKeys = await upgraded.rawQuery(
      'PRAGMA foreign_key_list(${BebeDatabaseSchema.registerEvents})',
    );
    final agendaForeignKeys = await upgraded.rawQuery(
      'PRAGMA foreign_key_list(${BebeDatabaseSchema.agendaEvents})',
    );
    expect(registerForeignKeys.any((row) => row['table'] == 'babies'), isTrue);
    expect(
      agendaForeignKeys.any((row) => row['table'] == 'register_events'),
      isTrue,
    );
    final indexRows = await upgraded.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index'",
    );
    final indexNames = indexRows.map((row) => row['name']).toSet();
    expect(
      indexNames,
      containsAll({
        'idx_register_events_baby_occurred',
        'idx_register_events_type',
        'idx_register_events_sync',
        'idx_agenda_baby_starts',
        'idx_agenda_sync',
        'idx_agenda_source_register',
      }),
    );
    final familyMemberColumns = await upgraded.rawQuery(
      'PRAGMA table_info(${BebeDatabaseSchema.familyMembers})',
    );
    expect(
      familyMemberColumns.map((row) => row['name']),
      contains('can_write'),
    );
    expect(await upgraded.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });

  test('v7 preflight aborts without deleting an orphaned v6 row', () async {
    final path = '${temporaryDirectory.path}/orphan-v6.sqlite';
    final fixture = await _openV6Fixture(path);
    await _insertRegister(
      fixture,
      id: 'offline-orphan',
      babyId: 'missing-baby',
    );
    await fixture.close();

    final database = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: path,
    );
    await expectLater(
      database.database,
      throwsA(
        predicate<Object>(
          (error) =>
              error.toString().contains('offline-orphan') &&
              error.toString().contains('migration aborted'),
        ),
      ),
    );
    await database.close();

    final preserved = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(readOnly: true),
    );
    addTearDown(preserved.close);
    expect(await preserved.getVersion(), 6);
    expect(
      await preserved.query(
        BebeDatabaseSchema.registerEvents,
        where: 'id = ?',
        whereArgs: ['offline-orphan'],
      ),
      hasLength(1),
    );
  });
}

Future<Database> _openV6Fixture(String path) => databaseFactoryFfi.openDatabase(
  path,
  options: OpenDatabaseOptions(
    version: 6,
    onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
    onCreate: (database, _) async {
      await database.execute('''
CREATE TABLE families (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  active_baby_id TEXT NOT NULL
)
''');
      await database.execute('''
CREATE TABLE babies (
  id TEXT PRIMARY KEY,
  family_id TEXT NOT NULL,
  name TEXT NOT NULL,
  birth_date INTEGER NOT NULL,
  avatar_asset_path TEXT,
  FOREIGN KEY (family_id) REFERENCES families(id) ON DELETE CASCADE
)
''');
      await database.execute('''
CREATE TABLE family_members (
  id TEXT PRIMARY KEY,
  family_id TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  access_description TEXT NOT NULL,
  status TEXT NOT NULL,
  contact TEXT NOT NULL,
  invited_at INTEGER,
  invitation_code TEXT,
  invitation_expires_at INTEGER,
  FOREIGN KEY (family_id) REFERENCES families(id) ON DELETE CASCADE
)
''');
      await database.execute('''
CREATE TABLE register_events (
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
  schema_version INTEGER NOT NULL DEFAULT 1
)
''');
      await database.execute('''
CREATE TABLE agenda_events (
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
  FOREIGN KEY (baby_id) REFERENCES babies(id) ON DELETE CASCADE,
  FOREIGN KEY (caregiver_id) REFERENCES family_members(id) ON DELETE SET NULL
)
''');
    },
  ),
);

Future<void> _insertFamilyGraph(Database database) async {
  await database.insert('families', {
    'id': 'family-1',
    'name': 'Familia',
    'active_baby_id': 'baby-1',
  });
  await database.insert('babies', {
    'id': 'baby-1',
    'family_id': 'family-1',
    'name': 'Emma',
    'birth_date': 1,
    'avatar_asset_path': null,
  });
}

Future<void> _insertRegister(
  Database database, {
  required String id,
  required String babyId,
}) => database.insert('register_events', {
  'id': id,
  'baby_id': babyId,
  'event_type': 'medication',
  'occurred_at': 1,
  'created_at': 1,
  'updated_at': 1,
  'details_json': '{}',
  'sync_status': 'pending',
  'schema_version': 1,
});

Future<void> _insertAgenda(
  Database database, {
  required String id,
  required String babyId,
  required String sourceRegisterEventId,
}) => database.insert('agenda_events', {
  'id': id,
  'baby_id': babyId,
  'category': 'medications',
  'title': 'Dosis',
  'description': '',
  'starts_at': 2,
  'created_at': 1,
  'updated_at': 1,
  'source_register_event_id': sourceRegisterEventId,
  'sync_status': 'pending',
});
