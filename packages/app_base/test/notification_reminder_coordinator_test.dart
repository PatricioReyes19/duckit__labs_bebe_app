import 'dart:async';

import 'package:app_base/src/notifications/notification_reminder_coordinator.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications/notifications.dart';

void main() {
  late _RecordingNotificationService notifications;
  late NotificationReminderCoordinator coordinator;

  setUp(() {
    notifications = _RecordingNotificationService();
    coordinator = NotificationReminderCoordinator(
      notificationService: notifications,
      getCurrentSession: GetCurrentSession(_SessionRepository()),
    );
  });

  test('controls create preventive reminders 24h and 2h before', () async {
    final startsAt = DateTime.now().add(const Duration(days: 3));
    await coordinator.scheduleAgenda(
      AgendaEventEntity(
        id: 'control-1',
        babyId: 'baby-1',
        category: AgendaCategory.controls,
        title: 'Control pediátrico',
        description: '',
        startsAt: startsAt,
        syncStatus: AgendaSyncStatus.synced,
      ),
    );

    final reminders = notifications.replacements.single.reminders;
    expect(reminders, hasLength(2));
    expect(
      reminders.map((reminder) => reminder.type),
      everyElement(NotificationReminderType.healthControl),
    );
    expect(
      reminders.map((reminder) => reminder.scheduledAt),
      containsAll([
        startsAt.toLocal().subtract(const Duration(hours: 24)),
        startsAt.toLocal().subtract(const Duration(hours: 2)),
      ]),
    );
  });

  test('medication reminder includes medicine and normalized dose', () async {
    final now = DateTime.now();
    await coordinator.scheduleRegister(
      RegisteredEvent(
        id: 'medication-1',
        babyId: 'baby-1',
        type: RegisterEventType.medication,
        occurredAt: now,
        createdAt: now,
        details: {
          'name': 'Paracetamol',
          'dose': 2.5,
          'unit': 'mL',
          'frequency': 'Cada 12 horas',
          'end_date': now.add(const Duration(hours: 13)).toIso8601String(),
          'schedule_next_doses': true,
        },
      ),
    );

    final reminder = notifications.replacements.single.reminders.first;
    expect(reminder.type, NotificationReminderType.medication);
    expect(reminder.body, 'Paracetamol · 2,5 mL');
  });

  test('medication end date includes doses later on the selected day',
      () async {
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 1));
    await coordinator.scheduleRegister(
      RegisteredEvent(
        id: 'medication-inclusive-end',
        babyId: 'baby-1',
        type: RegisterEventType.medication,
        occurredAt: now,
        createdAt: now,
        details: {
          'name': 'Vitamina D',
          'dose': 1,
          'unit': 'gota',
          'frequency': 'Cada 4 horas',
          'end_date': DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
          ).toIso8601String(),
          'schedule_next_doses': true,
        },
      ),
    );

    final reminders = notifications.replacements.single.reminders;
    expect(
      reminders.any(
        (reminder) =>
            reminder.scheduledAt.day == endDate.day &&
            reminder.scheduledAt.hour > 0,
      ),
      isTrue,
    );
  });

  test('feeding does not schedule unless the caregiver opts in', () async {
    final now = DateTime.now();
    await coordinator.scheduleRegister(
      RegisteredEvent(
        id: 'feeding-1',
        babyId: 'baby-1',
        type: RegisterEventType.feeding,
        occurredAt: now,
        createdAt: now,
        details: const {},
      ),
    );

    expect(notifications.replacements, isEmpty);
    expect(
      notifications.cancelledOwners,
      ['account:user-1|register:feeding-1'],
    );
  });

  test('breastfeeding opt-in schedules an exact feeding reminder', () async {
    final now = DateTime.now();
    final event = RegisteredEvent(
      id: 'feeding-breast-reminder',
      babyId: 'baby-1',
      type: RegisterEventType.feeding,
      occurredAt: now,
      createdAt: now,
      details: const {
        'subtype': 'breast',
        'schedule_next_feeding': true,
        'reminder_interval_hours': 3,
      },
    );

    expect(coordinator.hasRegisterReminders(event), isTrue);
    await coordinator.scheduleRegister(event);

    final reminder = notifications.replacements.single.reminders.single;
    expect(reminder.type, NotificationReminderType.feeding);
    expect(reminder.scheduledAt, now.add(const Duration(hours: 3)));
  });

  test('diaper opt-in uses the diaper reminder category', () async {
    final now = DateTime.now();
    await coordinator.scheduleRegister(
      RegisteredEvent(
        id: 'diaper-reminder',
        babyId: 'baby-1',
        type: RegisterEventType.diaper,
        occurredAt: now,
        createdAt: now,
        details: const {
          'schedule_reminder': true,
          'reminder_interval_hours': 4,
        },
      ),
    );

    expect(
      notifications.replacements.single.reminders.single.type,
      NotificationReminderType.diaper,
    );
  });

  test('vaccines create one preventive and one due reminder', () async {
    final startsAt = DateTime.now().add(const Duration(days: 4));
    await coordinator.scheduleHealth(
      HealthEventEntity(
        id: 'vaccine-1',
        babyId: 'baby-1',
        type: HealthEventType.vaccine,
        title: 'Vacuna hexavalente',
        description: '',
        startsAt: startsAt,
        status: HealthEventStatus.scheduled,
      ),
    );

    final replacement = notifications.replacements.single;
    expect(replacement.ownerId, 'account:user-1|health:vaccine-1');
    expect(replacement.reminders, hasLength(2));
    expect(
      replacement.reminders.map((reminder) => reminder.type),
      everyElement(NotificationReminderType.vaccine),
    );
  });

  test('reconciliation ignores history without a future alarm', () async {
    final now = DateTime.now();
    final service = _RecordingNotificationService();
    final coordinator = NotificationReminderCoordinator(
      notificationService: service,
      getCurrentSession: GetCurrentSession(_SessionRepository()),
    );
    final agenda = GetAgendaOverview(
      _AgendaRepository([
        AgendaEventEntity(
          id: 'dose-event-legacy-1787201316685',
          babyId: 'baby-1',
          category: AgendaCategory.medication,
          title: 'Próxima dosis: medicamento',
          description: 'Cada 12 horas',
          startsAt: now.add(const Duration(days: 2)),
          syncStatus: AgendaSyncStatus.synced,
        ),
      ]),
      _RegisterRepository([
        RegisteredEvent(
          id: 'feeding-without-alarm',
          babyId: 'baby-1',
          type: RegisterEventType.feeding,
          occurredAt: now.subtract(const Duration(days: 1)),
          createdAt: now.subtract(const Duration(days: 1)),
          details: const {'schedule_next_feeding': false},
        ),
        RegisteredEvent(
          id: 'expired-medication',
          babyId: 'baby-1',
          type: RegisterEventType.medication,
          occurredAt: now.subtract(const Duration(days: 2)),
          createdAt: now.subtract(const Duration(days: 2)),
          details: {
            'schedule_next_doses': true,
            'frequency': 'Cada 12 horas',
            'end_date': now.subtract(const Duration(days: 1)).toIso8601String(),
          },
        ),
        RegisteredEvent(
          id: 'diaper-with-alarm',
          babyId: 'baby-1',
          type: RegisterEventType.diaper,
          occurredAt: now,
          createdAt: now,
          details: const {
            'schedule_reminder': true,
            'reminder_interval_hours': 4,
          },
        ),
      ]),
    );

    final reconciled = await coordinator.reconcileDomainReminders(
      activeContextRepository: _ActiveContextRepository(),
      getAgendaOverview: agenda,
      getHealthOverview: GetHealthOverview(_HealthRepository()),
    );

    expect(reconciled, isTrue);
    expect(service.replacements, hasLength(1));
    expect(
      service.replacements.single.ownerId,
      'account:user-1|register:diaper-with-alarm',
    );
    expect(
      service.retainedOwners,
      {'account:user-1|register:diaper-with-alarm'},
    );
    expect(service.operations, [
      'retain',
      'reconcile',
      'replace:account:user-1|register:diaper-with-alarm',
    ]);
  });
}

class _Replacement {
  const _Replacement({required this.ownerId, required this.reminders});

  final String ownerId;
  final List<NotificationReminder> reminders;
}

class _RecordingNotificationService implements NotificationService {
  final replacements = <_Replacement>[];
  final cancelledOwners = <String>[];
  final operations = <String>[];
  Set<String> retainedOwners = const {};

  @override
  Future<NotificationPermissionState> permissionState() async =>
      NotificationPermissionState.granted;

  @override
  Future<void> reconcileReminders() async {
    operations.add('reconcile');
  }

  @override
  Future<void> retainReminderOwners({
    required String accountId,
    required String babyId,
    required Set<String> ownerIds,
  }) async {
    operations.add('retain');
    retainedOwners = Set.unmodifiable(ownerIds);
  }

  @override
  Future<void> replaceReminders({
    required String ownerId,
    required String accountId,
    required String babyId,
    required List<NotificationReminder> reminders,
  }) async {
    operations.add('replace:$ownerId');
    replacements.add(_Replacement(ownerId: ownerId, reminders: reminders));
  }

  @override
  Future<void> cancelReminders(String ownerId) async {
    cancelledOwners.add(ownerId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SessionRepository implements SessionRepository {
  @override
  Future<AuthSession?> currentSession() async => const AuthSession(
        user: AuthUser(
          id: 'user-1',
          email: 'caregiver@example.com',
          displayName: 'Caregiver',
          emailVerification: true,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ActiveContextRepository implements ActiveContextRepository {
  @override
  Future<ActiveContext?> read() async => const ActiveContext(
        userId: 'user-1',
        circleId: 'family-1',
        babyId: 'baby-1',
      );

  @override
  Future<void> clear() async {}

  @override
  Future<void> save(ActiveContext context) async {}
}

class _AgendaRepository implements AgendaRepository {
  const _AgendaRepository([this.events = const []]);

  final List<AgendaEventEntity> events;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<AgendaOverviewEntity> getOverview(String babyId) async =>
      AgendaOverviewEntity(
        events: events,
        remindersEnabled: true,
        isOffline: false,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RegisterRepository implements RegisterEventRepository {
  _RegisterRepository(this.events);

  final List<RegisteredEvent> events;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async =>
      events;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _HealthRepository implements HealthRepository {
  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<HealthOverviewEntity> getOverview(String babyId) async =>
      const HealthOverviewEntity(events: [], measurements: []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
