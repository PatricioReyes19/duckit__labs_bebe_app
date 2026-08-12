import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late BebeDatabase database;
  late SqliteRegisterEventRepository registerRepository;
  late SqliteAgendaRepository agendaRepository;
  late SqliteFamilyRepository familyRepository;
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
    familyRepository = SqliteFamilyRepository(database);
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
      familyRepository: familyRepository,
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
    await coordinator.reconcile();
    final thirdPass = await agendaRepository.listDerivedBySource(medication.id);

    expect(firstPass, isNotEmpty);
    expect(firstPass.first.startsAt, now.add(const Duration(hours: 8)));
    expect(
      firstPass.last.startsAt.isAfter(now.add(const Duration(days: 80))),
      isTrue,
      reason:
          'Una pauta sin fecha de término debe mantener una ventana móvil '
          'amplia, no cortarse después de dos semanas.',
    );
    expect(firstPass.first.title, 'Próxima dosis: Paracetamol');
    expect(
      secondPass.map((event) => event.id).toSet(),
      firstPass.map((event) => event.id).toSet(),
    );
    expect(
      thirdPass.map((event) => event.id).toSet(),
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

  test('skips an out-of-order register until its baby is hydrated', () async {
    final freshDatabase = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    final freshFamilies = SqliteFamilyRepository(freshDatabase);
    final freshAgenda = SqliteAgendaRepository(freshDatabase, clock: () => now);
    final freshAgendaSync = AgendaEventSyncService(
      freshAgenda,
      _MemoryAgendaRemote(),
      clock: () => now,
    );
    final medication = RegisteredEvent(
      id: 'remote-medication-before-baby',
      babyId: 'baby-late',
      type: RegisterEventType.medication,
      occurredAt: now,
      createdAt: now,
      updatedAt: now,
      details: const {
        'name': 'Vitamina D',
        'frequency': 'Cada 8 horas',
        'schedule_next_doses': true,
        'end_date': '2026-08-10T20:00:00.000Z',
      },
      syncStatus: RegisterSyncStatus.synced,
    );
    final outOfOrderRegisters = _StaticRegisterRepository(
      freshDatabase,
      medication,
    );
    final guardedCoordinator = RegisterAgendaCoordinator(
      outOfOrderRegisters,
      freshAgenda,
      freshAgendaSync,
      familyRepository: freshFamilies,
      clock: () => now,
    );
    addTearDown(guardedCoordinator.close);
    addTearDown(freshAgendaSync.close);
    addTearDown(freshDatabase.close);

    expect(await guardedCoordinator.reconcile(), isFalse);
    expect(await freshAgenda.listDerivedBySource(medication.id), isEmpty);

    await freshFamilies.joinCareCircle(
      JoinedCareCircleDraft(
        familyId: 'family-late',
        familyName: 'Familia tardía',
        babyId: 'baby-late',
        babyName: 'Emma',
        babyBirthDate: DateTime.utc(2026, 1, 1),
        memberId: 'member-late',
        memberName: 'Paula',
        memberEmail: 'paula@example.com',
      ),
    );
    final hydratedRegisters = SqliteRegisterEventRepository(
      database: freshDatabase,
    );
    await hydratedRegisters.mergeRemote(medication);
    final convergingCoordinator = RegisterAgendaCoordinator(
      hydratedRegisters,
      freshAgenda,
      freshAgendaSync,
      familyRepository: freshFamilies,
      clock: () => now,
    );
    addTearDown(convergingCoordinator.close);
    addTearDown(hydratedRegisters.close);

    expect(await convergingCoordinator.reconcile(), isTrue);
    expect(await freshAgenda.listDerivedBySource(medication.id), hasLength(1));
  });
}

class _StaticRegisterRepository extends SqliteRegisterEventRepository {
  _StaticRegisterRepository(BebeDatabase database, this.event)
    : super(database: database);

  final RegisteredEvent event;

  @override
  Stream<void> get changes => const Stream<void>.empty();

  @override
  Future<List<RegisteredEvent>> listByTypeIncludingDeleted(
    RegisterEventType type,
  ) async => type == RegisterEventType.medication ? [event] : const [];
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
