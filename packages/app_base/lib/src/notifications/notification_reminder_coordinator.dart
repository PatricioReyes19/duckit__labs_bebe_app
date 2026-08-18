import 'package:core/core.dart';
import 'package:notifications/notifications.dart';

class NotificationReminderCoordinator {
  const NotificationReminderCoordinator({
    required NotificationService notificationService,
    required GetCurrentSession getCurrentSession,
  })  : _notificationService = notificationService,
        _getCurrentSession = getCurrentSession;

  final NotificationService _notificationService;
  final GetCurrentSession _getCurrentSession;

  Future<NotificationPermissionState> permissionState() =>
      _notificationService.permissionState();

  Future<NotificationPermissionState> preparePermission() async {
    final state = await _notificationService.permissionState();
    if (state == NotificationPermissionState.notDetermined) {
      return _notificationService.requestPermission();
    }
    return state;
  }

  Future<bool> openSettings() =>
      _notificationService.openNotificationSettings();

  Future<void> scheduleAgenda(AgendaEventEntity event) async {
    final accountId = await _accountId();
    if (accountId == null) return;
    await _notificationService.replaceReminders(
      ownerId: agendaOwner(accountId, event.id),
      accountId: accountId,
      babyId: event.babyId,
      reminders: _agendaReminders(event),
    );
  }

  Future<void> cancelAgenda(String eventId) async {
    final accountId = await _accountId();
    if (accountId == null) return;
    await _notificationService.cancelReminders(
      agendaOwner(accountId, eventId),
    );
  }

  Future<void> scheduleHealth(HealthEventEntity event) async {
    final accountId = await _accountId();
    if (accountId == null) return;
    await _notificationService.replaceReminders(
      ownerId: healthOwner(accountId, event.id),
      accountId: accountId,
      babyId: event.babyId,
      reminders: _healthReminders(event),
    );
  }

  Future<void> scheduleRegister(RegisteredEvent event) async {
    final accountId = await _accountId();
    if (accountId == null) return;
    final reminders = _registerReminders(event);
    final ownerId = registerOwner(accountId, event.id);
    if (reminders.isEmpty) {
      await _notificationService.cancelReminders(ownerId);
      return;
    }
    await _notificationService.replaceReminders(
      ownerId: ownerId,
      accountId: accountId,
      babyId: event.babyId,
      reminders: reminders,
    );
  }

  Future<void> cancelRegister(String eventId) async {
    final accountId = await _accountId();
    if (accountId == null) return;
    await _notificationService.cancelReminders(
      registerOwner(accountId, eventId),
    );
  }

  /// Rebuilds the native schedule from the synchronized domain projection.
  /// This is the clean-install/login recovery path: Supabase hydrates SQLite,
  /// then this coordinator recreates only the active baby's local alarms.
  Future<bool> reconcileDomainReminders({
    required ActiveContextRepository activeContextRepository,
    required GetAgendaOverview getAgendaOverview,
    required GetHealthOverview getHealthOverview,
  }) async {
    final accountId = await _accountId();
    if (accountId == null ||
        !(await _notificationService.permissionState()).canDeliver) {
      return false;
    }
    final context = await activeContextRepository.read();
    if (context == null || context.userId != accountId) return false;
    await _notificationService.reconcileReminders();
    final overview = await getAgendaOverview(context.babyId);
    if (!overview.remindersEnabled) {
      await _notificationService.cancelRemindersForAccount(accountId);
      return true;
    }

    final retainedOwners = <String>{};
    final now = DateTime.now();
    final healthOverview = await getHealthOverview(context.babyId);
    final scheduledHealthEvents = healthOverview.events.where(
      (event) =>
          event.status == HealthEventStatus.scheduled &&
          event.startsAt.isAfter(now),
    );
    final healthOccurrenceKeys = <String>{};
    for (final event in scheduledHealthEvents) {
      healthOccurrenceKeys.add(_healthOccurrenceKey(event.type, event.startsAt));
      retainedOwners.add(healthOwner(accountId, event.id));
      await scheduleHealth(event);
    }
    for (final event in overview.events) {
      if (event.isDeleted ||
          event.isDerivedFromRegister ||
          !event.startsAt.isAfter(now) ||
          _duplicatesHealthEvent(event, healthOccurrenceKeys)) {
        continue;
      }
      retainedOwners.add(agendaOwner(accountId, event.id));
      await scheduleAgenda(event);
    }
    for (final event in overview.registerEvents) {
      if (event.isDeleted) continue;
      retainedOwners.add(registerOwner(accountId, event.id));
      await scheduleRegister(event);
    }
    await _notificationService.retainReminderOwners(
      accountId: accountId,
      babyId: context.babyId,
      ownerIds: retainedOwners,
    );
    return true;
  }

  Future<String?> _accountId() async => (await _getCurrentSession())?.user.id;

  static String agendaOwner(String accountId, String eventId) =>
      'account:$accountId|agenda:$eventId';

  static String healthOwner(String accountId, String eventId) =>
      'account:$accountId|health:$eventId';

  static String registerOwner(String accountId, String eventId) =>
      'account:$accountId|register:$eventId';

  static List<NotificationReminder> _registerReminders(
    RegisteredEvent event,
  ) {
    final details = event.details;
    if (event.type == RegisterEventType.medication &&
        details['schedule_next_doses'] == true) {
      final interval = switch (details['frequency']) {
        'Cada 4 horas' => const Duration(hours: 4),
        'Cada 6 horas' => const Duration(hours: 6),
        'Cada 8 horas' => const Duration(hours: 8),
        'Cada 12 horas' => const Duration(hours: 12),
        'Una vez al día' => const Duration(days: 1),
        _ => null,
      };
      if (interval == null) return const [];
      final explicitEnd = DateTime.tryParse(
        (details['end_date'] as String?) ?? '',
      )?.toLocal();
      final horizon =
          explicitEnd ?? DateTime.now().add(const Duration(days: 30));
      var next = event.occurredAt.toLocal().add(interval);
      while (!next.isAfter(DateTime.now())) {
        next = next.add(interval);
      }
      final reminders = <NotificationReminder>[];
      while (!next.isAfter(horizon) && reminders.length < 60) {
        reminders.add(
          NotificationReminder(
            id: 'dose:${next.millisecondsSinceEpoch}',
            title: 'Medicamento',
            body: _medicationBody(details),
            scheduledAt: next,
            route: '/agenda',
            type: NotificationReminderType.medication,
          ),
        );
        next = next.add(interval);
      }
      return reminders;
    }

    final shouldSchedule = switch (event.type) {
      RegisterEventType.feeding => details['schedule_next_feeding'] == true,
      RegisterEventType.diaper => details['schedule_reminder'] == true,
      _ => false,
    };
    final hours = (details['reminder_interval_hours'] as num?)?.toInt();
    if (!shouldSchedule || hours == null || hours <= 0) return const [];
    final scheduledAt = event.occurredAt.toLocal().add(Duration(hours: hours));
    final (title, body, route, type) = switch (event.type) {
      RegisterEventType.feeding => (
          'Próxima toma',
          'Revisa si corresponde una nueva alimentación.',
          '/register/feeding',
          NotificationReminderType.feeding,
        ),
      RegisterEventType.diaper => (
          'Próximo cambio de pañal',
          'Revisa si corresponde un nuevo cambio.',
          '/register/diaper',
          NotificationReminderType.custom,
        ),
      _ => (
          'Recordatorio',
          'Tienes una tarea pendiente.',
          '/agenda',
          NotificationReminderType.custom,
        ),
    };
    return [
      NotificationReminder(
        id: 'due',
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        route: route,
        type: type,
      ),
    ];
  }

  static List<NotificationReminder> _agendaReminders(
    AgendaEventEntity event,
  ) {
    final startsAt = event.startsAt.toLocal();
    final route = '/agenda/events/${Uri.encodeComponent(event.id)}';
    return switch (event.category) {
      AgendaCategory.controls => [
          NotificationReminder(
            id: 'agenda:${event.id}:24h',
            title: 'Control de salud mañana',
            body: event.title,
            scheduledAt: startsAt.subtract(const Duration(hours: 24)),
            route: route,
            type: NotificationReminderType.healthControl,
          ),
          NotificationReminder(
            id: 'agenda:${event.id}:2h',
            title: 'Control de salud en 2 horas',
            body: event.title,
            scheduledAt: startsAt.subtract(const Duration(hours: 2)),
            route: route,
            type: NotificationReminderType.healthControl,
          ),
        ],
      AgendaCategory.vaccines => [
          NotificationReminder(
            id: 'agenda:${event.id}:24h',
            title: 'Vacuna mañana',
            body: event.title,
            scheduledAt: startsAt.subtract(const Duration(hours: 24)),
            route: route,
            type: NotificationReminderType.vaccine,
          ),
          NotificationReminder(
            id: 'agenda:${event.id}:due',
            title: 'Vacuna programada',
            body: event.title,
            scheduledAt: startsAt,
            route: route,
            type: NotificationReminderType.vaccine,
          ),
        ],
      AgendaCategory.medication => [
          NotificationReminder(
            id: 'agenda:${event.id}:due',
            title: 'Medicamento',
            body: [event.title, event.description]
                .where((value) => value.trim().isNotEmpty)
                .join(' · '),
            scheduledAt: startsAt,
            route: route,
            type: NotificationReminderType.medication,
          ),
        ],
      AgendaCategory.exams => [
          NotificationReminder(
            id: 'agenda:${event.id}:due',
            title: 'Examen programado',
            body: event.title,
            scheduledAt: startsAt,
            route: route,
            type: NotificationReminderType.healthControl,
          ),
        ],
    };
  }

  static List<NotificationReminder> _healthReminders(HealthEventEntity event) {
    if (event.status != HealthEventStatus.scheduled) return const [];
    final startsAt = event.startsAt.toLocal();
    final route = '/health';
    if (event.type == HealthEventType.vaccine) {
      return [
        NotificationReminder(
          id: 'health:${event.id}:24h',
          title: 'Vacuna mañana',
          body: event.title,
          scheduledAt: startsAt.subtract(const Duration(hours: 24)),
          route: route,
          type: NotificationReminderType.vaccine,
        ),
        NotificationReminder(
          id: 'health:${event.id}:due',
          title: 'Vacuna programada',
          body: event.title,
          scheduledAt: startsAt,
          route: route,
          type: NotificationReminderType.vaccine,
        ),
      ];
    }
    return [
      NotificationReminder(
        id: 'health:${event.id}:24h',
        title: 'Control de salud mañana',
        body: event.title,
        scheduledAt: startsAt.subtract(const Duration(hours: 24)),
        route: route,
        type: NotificationReminderType.healthControl,
      ),
      NotificationReminder(
        id: 'health:${event.id}:2h',
        title: 'Control de salud en 2 horas',
        body: event.title,
        scheduledAt: startsAt.subtract(const Duration(hours: 2)),
        route: route,
        type: NotificationReminderType.healthControl,
      ),
    ];
  }

  static bool _duplicatesHealthEvent(
    AgendaEventEntity event,
    Set<String> healthOccurrenceKeys,
  ) {
    final healthType = switch (event.category) {
      AgendaCategory.vaccines => HealthEventType.vaccine,
      AgendaCategory.controls => HealthEventType.pediatricControl,
      AgendaCategory.medication || AgendaCategory.exams => null,
    };
    return healthType != null &&
        healthOccurrenceKeys.contains(
          _healthOccurrenceKey(healthType, event.startsAt),
        );
  }

  static String _healthOccurrenceKey(
    HealthEventType type,
    DateTime startsAt,
  ) {
    final category = type == HealthEventType.vaccine ? 'vaccine' : 'control';
    return '$category:${startsAt.toUtc().millisecondsSinceEpoch}';
  }

  static String _medicationBody(Map<String, Object?> details) {
    final name = details['name']?.toString().trim();
    final dose = details['dose'];
    final unit = details['unit']?.toString().trim();
    final doseText = dose is num
        ? (dose == dose.roundToDouble()
            ? dose.toInt().toString()
            : dose.toString().replaceAll('.', ','))
        : dose?.toString().trim();
    final medication = name?.isNotEmpty == true ? name! : 'medicamento';
    final formattedDose = [
      if (doseText?.isNotEmpty == true) doseText!,
      if (unit?.isNotEmpty == true) unit!,
    ].join(' ');
    return formattedDose.isEmpty
        ? 'Es hora de administrar $medication.'
        : '$medication · $formattedDose';
  }
}
