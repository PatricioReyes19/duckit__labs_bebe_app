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
  static Future<bool>? _domainReconciliationInFlight;

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
    if (accountId == null) {
      throw StateError(
        'No hay una sesión activa para programar el recordatorio.',
      );
    }
    await _replaceAgendaReminders(accountId, event, _agendaReminders(event));
  }

  Future<void> _replaceAgendaReminders(
    String accountId,
    AgendaEventEntity event,
    List<NotificationReminder> reminders,
  ) =>
      _notificationService.replaceReminders(
        ownerId: agendaOwner(accountId, event.id),
        accountId: accountId,
        babyId: event.babyId,
        reminders: reminders,
      );

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
    await _replaceHealthReminders(accountId, event, _healthReminders(event));
  }

  Future<void> cancelHealth(String eventId) async {
    final accountId = await _accountId();
    if (accountId == null) return;
    await _notificationService.cancelReminders(
      healthOwner(accountId, eventId),
    );
  }

  Future<void> _replaceHealthReminders(
    String accountId,
    HealthEventEntity event,
    List<NotificationReminder> reminders,
  ) =>
      _notificationService.replaceReminders(
        ownerId: healthOwner(accountId, event.id),
        accountId: accountId,
        babyId: event.babyId,
        reminders: reminders,
      );

  Future<void> scheduleRegister(RegisteredEvent event) async {
    final accountId = await _accountId();
    if (accountId == null) {
      throw StateError(
        'No hay una sesión activa para programar el recordatorio.',
      );
    }
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

  /// Requests permission only for records where the caregiver explicitly
  /// enabled an alarm. Records without an alarm still use [scheduleRegister]
  /// so an edited event can cancel its previous native schedule.
  bool hasRegisterReminders(RegisteredEvent event) =>
      _registerReminders(event).isNotEmpty;

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
  }) {
    final running = _domainReconciliationInFlight;
    if (running != null) return running;
    final operation = _reconcileDomainReminders(
      activeContextRepository: activeContextRepository,
      getAgendaOverview: getAgendaOverview,
      getHealthOverview: getHealthOverview,
    );
    _domainReconciliationInFlight = operation;
    return operation.whenComplete(() {
      if (identical(_domainReconciliationInFlight, operation)) {
        _domainReconciliationInFlight = null;
      }
    });
  }

  Future<bool> _reconcileDomainReminders({
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
    final overview = await getAgendaOverview(context.babyId);
    if (!overview.remindersEnabled) {
      await _notificationService.cancelRemindersForAccount(accountId);
      return true;
    }

    final retainedOwners = <String>{};
    final now = DateTime.now();
    final healthOverview = await getHealthOverview(context.babyId);
    final healthSchedules = <(HealthEventEntity, List<NotificationReminder>)>[];
    final agendaSchedules = <(AgendaEventEntity, List<NotificationReminder>)>[];
    final registerSchedules = <(RegisteredEvent, List<NotificationReminder>)>[];
    final scheduledHealthEvents = healthOverview.events.where(
      (event) =>
          event.status == HealthEventStatus.scheduled &&
          event.startsAt.isAfter(now),
    );
    final healthOccurrenceKeys = <String>{};
    for (final event in scheduledHealthEvents) {
      final reminders = _futureReminders(_healthReminders(event), now);
      if (reminders.isEmpty) continue;
      healthOccurrenceKeys
          .add(_healthOccurrenceKey(event.type, event.startsAt));
      retainedOwners.add(healthOwner(accountId, event.id));
      healthSchedules.add((event, reminders));
    }
    for (final event in overview.events) {
      if (event.isDeleted ||
          event.isDerivedFromRegister ||
          _isLegacyGeneratedDose(event) ||
          !event.startsAt.isAfter(now) ||
          _duplicatesHealthEvent(event, healthOccurrenceKeys)) {
        continue;
      }
      final reminders = _futureReminders(_agendaReminders(event), now);
      if (reminders.isEmpty) continue;
      retainedOwners.add(agendaOwner(accountId, event.id));
      agendaSchedules.add((event, reminders));
    }
    for (final event in overview.registerEvents) {
      if (event.isDeleted) continue;
      final reminders = _futureReminders(_registerReminders(event), now);
      if (reminders.isEmpty) continue;
      retainedOwners.add(registerOwner(accountId, event.id));
      registerSchedules.add((event, reminders));
    }

    // Prune first. Legacy recurring-dose owners can number in the hundreds;
    // keeping them until after scheduling makes every small replacement rewrite
    // an unnecessarily large preference snapshot.
    await _notificationService.retainReminderOwners(
      accountId: accountId,
      babyId: context.babyId,
      ownerIds: retainedOwners,
    );
    // Restore only the desired schedules that survived pruning. Running this
    // before the domain projection is known can replay hundreds of legacy
    // alarms after an app update and delay the actual cleanup for minutes.
    await _notificationService.reconcileReminders();
    for (final schedule in healthSchedules) {
      await _replaceHealthReminders(accountId, schedule.$1, schedule.$2);
    }
    for (final schedule in agendaSchedules) {
      await _replaceAgendaReminders(accountId, schedule.$1, schedule.$2);
    }
    for (final schedule in registerSchedules) {
      final event = schedule.$1;
      await _notificationService.replaceReminders(
        ownerId: registerOwner(accountId, event.id),
        accountId: accountId,
        babyId: event.babyId,
        reminders: schedule.$2,
      );
    }
    return true;
  }

  static bool _isLegacyGeneratedDose(AgendaEventEntity event) =>
      event.category == AgendaCategory.medication &&
      event.id.startsWith('dose-');

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
      final explicitEnd = _inclusiveLocalEndDate(details['end_date']);
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
          NotificationReminderType.diaper,
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
    if (event.isImmunization) {
      final label =
          event.immunizationItemType == ImmunizationItemType.monoclonalAntibody
              ? 'Inmunización'
              : 'Vacuna';
      return [
        NotificationReminder(
          id: 'health:${event.id}:24h',
          title: '$label mañana',
          body: event.title,
          scheduledAt: startsAt.subtract(const Duration(hours: 24)),
          route: route,
          type: NotificationReminderType.vaccine,
        ),
        NotificationReminder(
          id: 'health:${event.id}:due',
          title: '$label programada',
          body: event.title,
          scheduledAt: startsAt,
          route: route,
          type: NotificationReminderType.vaccine,
        ),
      ];
    }
    final appointmentLabel =
        event.appointmentKind == HealthAppointmentKind.consultation
            ? 'Consulta pediátrica'
            : 'Control de salud';
    return [
      NotificationReminder(
        id: 'health:${event.id}:24h',
        title: '$appointmentLabel mañana',
        body: event.title,
        scheduledAt: startsAt.subtract(const Duration(hours: 24)),
        route: route,
        type: NotificationReminderType.healthControl,
      ),
      NotificationReminder(
        id: 'health:${event.id}:2h',
        title: '$appointmentLabel en 2 horas',
        body: event.title,
        scheduledAt: startsAt.subtract(const Duration(hours: 2)),
        route: route,
        type: NotificationReminderType.healthControl,
      ),
    ];
  }

  static List<NotificationReminder> _futureReminders(
    List<NotificationReminder> reminders,
    DateTime now,
  ) =>
      reminders
          .where((reminder) => reminder.scheduledAt.isAfter(now))
          .toList(growable: false);

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
    final category = switch (type) {
      HealthEventType.vaccine || HealthEventType.immunization => 'vaccine',
      _ => 'control',
    };
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

  static DateTime? _inclusiveLocalEndDate(Object? value) {
    final parsed = switch (value) {
      final DateTime date => date.toLocal(),
      final String text => DateTime.tryParse(text)?.toLocal(),
      _ => null,
    };
    if (parsed == null) return null;
    return DateTime(
      parsed.year,
      parsed.month,
      parsed.day,
      23,
      59,
      59,
      999,
      999,
    );
  }
}
