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
      reminders: [
        NotificationReminder(
          id: 'agenda:${event.id}',
          title: 'Recordatorio de Agenda',
          body: 'Tienes un recordatorio programado en BebéApp.',
          scheduledAt: event.startsAt.toLocal(),
          route: '/agenda/events/${Uri.encodeComponent(event.id)}',
        ),
      ],
    );
  }

  Future<void> cancelAgenda(String eventId) async {
    final accountId = await _accountId();
    if (accountId == null) return;
    await _notificationService.cancelReminders(
      agendaOwner(accountId, eventId),
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

  Future<String?> _accountId() async => (await _getCurrentSession())?.user.id;

  static String agendaOwner(String accountId, String eventId) =>
      'account:$accountId|agenda:$eventId';

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
            title: 'Recordatorio de medicamento',
            body: 'Es hora de revisar un medicamento programado.',
            scheduledAt: next,
            route: '/agenda',
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
    final (title, body, route) = switch (event.type) {
      RegisterEventType.feeding => (
          'Próxima toma',
          'Revisa si corresponde una nueva alimentación.',
          '/register/feeding',
        ),
      RegisterEventType.diaper => (
          'Próximo cambio de pañal',
          'Revisa si corresponde un nuevo cambio.',
          '/register/diaper',
        ),
      _ => ('Recordatorio', 'Tienes una tarea pendiente.', '/agenda'),
    };
    return [
      NotificationReminder(
        id: 'due',
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        route: route,
      ),
    ];
  }
}
