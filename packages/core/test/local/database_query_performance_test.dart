import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  for (final rowCount in [100, 1000, 10000]) {
    test('PERF-DB pending queue plan with $rowCount rows', () async {
      final database = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      addTearDown(database.close);
      final raw = await database.database;
      await _seed(raw, rowCount);

      await raw.execute('DROP INDEX idx_register_events_pending_updated');
      await raw.execute('DROP INDEX idx_agenda_events_pending_updated');
      await raw.execute('DROP INDEX idx_health_events_pending_updated');

      final before = await _measurePlans(raw);
      await BebeDatabaseSchema.upgradePendingSyncIndexesV8(raw);
      final after = await _measurePlans(raw);

      expect(
        after.registerPlan,
        contains('idx_register_events_pending_updated'),
      );
      expect(after.agendaPlan, contains('idx_agenda_events_pending_updated'));
      expect(after.healthPlan, contains('idx_health_events_pending_updated'));

      debugPrint(
        'BDD014_LOCAL rows=$rowCount '
        'before_us=${before.elapsed.inMicroseconds} '
        'after_us=${after.elapsed.inMicroseconds} '
        'register_after="${after.registerPlan}" '
        'agenda_after="${after.agendaPlan}" '
        'health_after="${after.healthPlan}"',
      );
    });
  }
}

Future<void> _seed(Database database, int rowCount) async {
  await database.insert(BebeDatabaseSchema.families, {
    'id': 'family-performance',
    'name': 'Performance',
    'active_baby_id': 'baby-performance',
  });
  await database.insert(BebeDatabaseSchema.babies, {
    'id': 'baby-performance',
    'family_id': 'family-performance',
    'name': 'Baby',
    'birth_date': 0,
  });

  final batch = database.batch();
  for (var index = 0; index < rowCount; index++) {
    final syncStatus = index % 100 == 0 ? 'pending' : 'synced';
    batch.insert(BebeDatabaseSchema.registerEvents, {
      'id': 'register-$index',
      'baby_id': 'baby-performance',
      'event_type': 'feeding',
      'occurred_at': index,
      'created_at': index,
      'updated_at': index,
      'details_json': '{}',
      'sync_status': syncStatus,
      'schema_version': 1,
    });
    batch.insert(BebeDatabaseSchema.agendaEvents, {
      'id': 'agenda-$index',
      'baby_id': 'baby-performance',
      'category': 'medication',
      'title': 'Dose $index',
      'description': '',
      'starts_at': index,
      'created_at': index,
      'updated_at': index,
      'sync_status': syncStatus,
    });
    batch.insert(BebeDatabaseSchema.healthEvents, {
      'id': 'health-$index',
      'baby_id': 'baby-performance',
      'event_type': 'pediatricControl',
      'title': 'Control $index',
      'description': '',
      'starts_at': index,
      'status': 'scheduled',
      'created_at': index,
      'updated_at': index,
      'sync_status': syncStatus,
    });
  }
  await batch.commit(noResult: true);
}

Future<_PlanMeasurement> _measurePlans(Database database) async {
  const registerQuery =
      "SELECT * FROM register_events WHERE sync_status != 'synced' "
      'ORDER BY updated_at ASC LIMIT 100';
  const agendaQuery =
      "SELECT * FROM agenda_events WHERE sync_status != 'synced' "
      'ORDER BY updated_at ASC LIMIT 100';
  const healthQuery =
      "SELECT * FROM health_events WHERE sync_status != 'synced' "
      'ORDER BY updated_at ASC LIMIT 100';

  final registerPlan = await _plan(database, registerQuery);
  final agendaPlan = await _plan(database, agendaQuery);
  final healthPlan = await _plan(database, healthQuery);
  final stopwatch = Stopwatch()..start();
  for (var iteration = 0; iteration < 20; iteration++) {
    await database.rawQuery(registerQuery);
    await database.rawQuery(agendaQuery);
    await database.rawQuery(healthQuery);
  }
  stopwatch.stop();
  return _PlanMeasurement(
    registerPlan: registerPlan,
    agendaPlan: agendaPlan,
    healthPlan: healthPlan,
    elapsed: stopwatch.elapsed,
  );
}

Future<String> _plan(Database database, String query) async {
  final rows = await database.rawQuery('EXPLAIN QUERY PLAN $query');
  return rows.map((row) => row['detail']).join(' | ');
}

class _PlanMeasurement {
  const _PlanMeasurement({
    required this.registerPlan,
    required this.agendaPlan,
    required this.healthPlan,
    required this.elapsed,
  });

  final String registerPlan;
  final String agendaPlan;
  final String healthPlan;
  final Duration elapsed;
}
