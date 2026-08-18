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

    final reminder = notifications.replacements.single.reminders.single;
    expect(reminder.type, NotificationReminderType.medication);
    expect(reminder.body, 'Paracetamol · 2,5 mL');
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
}

class _Replacement {
  const _Replacement({required this.ownerId, required this.reminders});

  final String ownerId;
  final List<NotificationReminder> reminders;
}

class _RecordingNotificationService implements NotificationService {
  final replacements = <_Replacement>[];
  final cancelledOwners = <String>[];

  @override
  Future<void> replaceReminders({
    required String ownerId,
    required String accountId,
    required String babyId,
    required List<NotificationReminder> reminders,
  }) async {
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
