import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late BebeDatabase database;
  late SqliteRegisterEventRepository registerRepository;
  late SqliteAgendaRepository agendaRepository;
  late AgendaEventSyncService agendaSyncService;
  late RegisterAgendaCoordinator coordinator;
  late _MemoryAgendaRemote remote;
  final now = DateTime.utc(2026, 8, 10, 12);

  setUp(() {
    database = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
      seedDemoData: true,
    );
    registerRepository = SqliteRegisterEventRepository(
      database: database,
      idGenerator: () => 'medication-1',
      clock: () => now,
    );
    agendaRepository = SqliteAgendaRepository(database, clock: () => now);
    remote = _MemoryAgendaRemote();
    agendaSyncService = AgendaEventSyncService(
      agendaRepository,
      remote,
      clock: () => now,
    );
    coordinator = RegisterAgendaCoordinator(
      registerRepository,
      agendaRepository,
      agendaSyncService,
      clock: () => now,
    );
  });

  tearDown(() async {
    await coordinator.close();
    await agendaSyncService.synchronize();
    await agendaSyncService.close();
    await registerRepository.close();
    await database.close();
  });

  test('projects future medication doses without duplicating them', () async {
    final medication = await registerRepository.save(
      RegisterEventDraft(
        babyId: BebeSeedData.activeBabyId,
        type: RegisterEventType.medication,
        occurredAt: now,
        details: const {
          'name': 'Paracetamol',
          'dose': 2.5,
          'unit': 'mL',
          'frequency': 'Cada 8 horas',
          'schedule_next_doses': true,
        },
      ),
    );

    await coordinator.reconcile();
    final firstPass = await agendaRepository.listDerivedBySource(medication.id);
    await coordinator.reconcile();
    final secondPass = await agendaRepository.listDerivedBySource(
      medication.id,
    );

    expect(firstPass, isNotEmpty);
    expect(firstPass.first.startsAt, now.add(const Duration(hours: 8)));
    expect(firstPass.first.title, 'Próxima dosis: Paracetamol');
    expect(
      secondPass.map((event) => event.id).toSet(),
      firstPass.map((event) => event.id).toSet(),
    );
  });

  test('uploads a user-created agenda reminder and marks it synced', () async {
    final reminder = await agendaRepository.create(
      AgendaEventDraft(
        babyId: BebeSeedData.activeBabyId,
        category: AgendaCategory.controls,
        title: 'Control pediátrico',
        description: 'Llevar carnet',
        startsAt: now.add(const Duration(days: 2)),
      ),
    );

    final result = await agendaSyncService.synchronize();

    expect(result.phase, RegisterSyncPhase.synced);
    expect(remote.rows, contains(reminder.id));
    expect(
      (await agendaRepository.findById(reminder.id))?.syncStatus,
      AgendaSyncStatus.synced,
    );
  });

  test('removes future doses when the source register is deleted', () async {
    final medication = await registerRepository.save(
      RegisterEventDraft(
        babyId: BebeSeedData.activeBabyId,
        type: RegisterEventType.medication,
        occurredAt: now,
        details: const {
          'name': 'Vitamina D',
          'dose': 4,
          'unit': 'gotas',
          'frequency': 'Una vez al día',
          'schedule_next_doses': true,
        },
      ),
    );
    await coordinator.reconcile();

    await registerRepository.delete(medication.id);
    await coordinator.reconcile();

    final derived = await agendaRepository.listDerivedBySource(medication.id);
    expect(derived, isNotEmpty);
    expect(
      derived.every((event) => event.isDeleted),
      isTrue,
      reason: derived
          .where((event) => !event.isDeleted)
          .map(
            (event) =>
                '${event.id}:${event.syncStatus.name}:${event.updatedAt.toIso8601String()}',
          )
          .join(', '),
    );
    final overview = await agendaRepository.getOverview(
      BebeSeedData.activeBabyId,
    );
    expect(
      overview.events.where(
        (event) => event.sourceRegisterEventId == medication.id,
      ),
      isEmpty,
    );
  });
}

class _MemoryAgendaRemote implements AgendaEventRemoteDataSource {
  final rows = <String, AgendaEventEntity>{};

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<List<AgendaEventEntity>> pull({DateTime? updatedAfter}) async => rows
      .values
      .where(
        (event) =>
            updatedAfter == null || event.updatedAt.isAfter(updatedAfter),
      )
      .toList(growable: false);

  @override
  Future<AgendaEventEntity> push(AgendaEventEntity event) async {
    final synced = AgendaEventEntity(
      id: event.id,
      babyId: event.babyId,
      category: event.category,
      title: event.title,
      description: event.description,
      startsAt: event.startsAt,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      deletedAt: event.deletedAt,
      sourceRegisterEventId: event.sourceRegisterEventId,
      syncStatus: AgendaSyncStatus.synced,
    );
    rows[event.id] = synced;
    return synced;
  }
}
