import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:notifications/notifications.dart';

import '../dependencies/dependencies.dart';
import '../notifications/notification_reminder_coordinator.dart';
import 'app_listeners.dart';
import '../startup/authenticated_startup_coordinator.dart';

/// Aplica preferencias que deben alcanzar a toda la aplicación.
class AppWrappers extends StatefulWidget {
  const AppWrappers({required this.child, super.key});

  final Widget child;

  @override
  State<AppWrappers> createState() => _AppWrappersState();
}

class _AppWrappersState extends State<AppWrappers> {
  StreamSubscription<void>? _settingsSubscription;
  StreamSubscription<SyncUxState>? _syncUxSubscription;
  StreamSubscription<AuthenticatedStartupStatus>? _startupStatusSubscription;
  final _syncAlertDeduplicator = SyncErrorAlertDeduplicator();
  bool _use24HourFormat = true;
  bool _reduceMotion = false;
  bool _highContrast = false;
  double _textScaleFactor = 1;
  String? _lastReminderReconciliationKey;
  bool _reconcilingReminders = false;
  bool _startupReady = false;
  SyncUxState? _lastSyncUxState;
  Timer? _persistentSyncAlertTimer;
  String? _persistentSyncErrorKey;
  bool _persistentSyncAlertScheduled = false;

  @override
  void initState() {
    super.initState();
    final repository = getIt<AppSettingsRepository>();
    final syncCoordinator = getIt<InitialDataSyncCoordinator>();
    final startupCoordinator = getIt<AuthenticatedStartupCoordinator>();
    _startupReady =
        startupCoordinator.status == AuthenticatedStartupStatus.ready;
    _settingsSubscription = repository.changes.listen((_) => _loadSettings());
    _syncUxSubscription = syncCoordinator.syncUxStates.listen(_syncChanged);
    _startupStatusSubscription = startupCoordinator.statuses.listen(
      _startupStatusChanged,
    );
    _syncChanged(syncCoordinator.syncUxState);
    unawaited(_loadSettings());
  }

  void _syncChanged(SyncUxState state) {
    _lastSyncUxState = state;
    _updatePersistentSyncAlert(state);
    _reconcileRemindersIfReady(state);
    if (!_syncAlertDeduplicator.shouldAlert(state)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = appScaffoldMessengerKey.currentState;
      if (messenger == null) return;
      BebeInAppSnackbar.showOn(
        messenger,
        title: 'Error de sincronización',
        message: state.hasLocallyPersistedChanges
            ? 'Tus cambios siguen guardados en este dispositivo. Reintenta desde Familia.'
            : 'No pudimos actualizar algunos datos. Reintenta desde Familia.',
        variant: BebeInAppSnackbarVariant.error,
        actionLabel: 'Reintentar',
        onActionPressed: () =>
            unawaited(getIt<InitialDataSyncCoordinator>().retry()),
      );
    });
  }

  void _startupStatusChanged(AuthenticatedStartupStatus status) {
    _startupReady = status == AuthenticatedStartupStatus.ready;
    final state = _lastSyncUxState;
    if (_startupReady && state != null) _reconcileRemindersIfReady(state);
  }

  void _reconcileRemindersIfReady(SyncUxState state) {
    if (!_startupReady) return;
    final reminderKey = '${state.status.name}:'
        '${state.lastSuccessfulSyncAt?.microsecondsSinceEpoch}:'
        '${state.pendingOperations}';
    if ((state.status == SyncUxStatus.synced ||
            state.status == SyncUxStatus.pending) &&
        reminderKey != _lastReminderReconciliationKey) {
      unawaited(_reconcileReminders(reminderKey));
    }
  }

  void _updatePersistentSyncAlert(SyncUxState state) {
    if (state.status != SyncUxStatus.error) {
      _persistentSyncAlertTimer?.cancel();
      _persistentSyncAlertTimer = null;
      _persistentSyncErrorKey = null;
      if (_persistentSyncAlertScheduled) {
        _persistentSyncAlertScheduled = false;
        unawaited(
          getIt<NotificationService>().cancelReminders('sync-failure'),
        );
      }
      return;
    }

    final errorKey = state.errorKey ?? state.errorScopes.join(',');
    if (_persistentSyncErrorKey == errorKey &&
        (_persistentSyncAlertTimer != null || _persistentSyncAlertScheduled)) {
      return;
    }
    _persistentSyncAlertTimer?.cancel();
    _persistentSyncErrorKey = errorKey;
    _persistentSyncAlertTimer = Timer(const Duration(seconds: 30), () {
      _persistentSyncAlertTimer = null;
      unawaited(_schedulePersistentSyncAlert());
    });
  }

  Future<void> _schedulePersistentSyncAlert() async {
    if (_persistentSyncErrorKey == null) return;
    try {
      final service = getIt<NotificationService>();
      if (!(await service.permissionState()).canDeliver ||
          _persistentSyncErrorKey == null) {
        return;
      }
      await service.scheduleReminder(
        id: 'sync-failure',
        title: 'Revisa la sincronización',
        body: 'Algunos datos necesitan que abras BebéApp y reintentes.',
        scheduledAt: DateTime.now().add(const Duration(seconds: 2)),
        route: '/family',
        type: NotificationReminderType.syncFailure,
      );
      _persistentSyncAlertScheduled = true;
    } on Object catch (error, stackTrace) {
      debugPrint('Persistent sync notification failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _reconcileReminders(String reconciliationKey) async {
    if (_reconcilingReminders) return;
    _reconcilingReminders = true;
    try {
      final reconciled = await NotificationReminderCoordinator(
        notificationService: getIt<NotificationService>(),
        getCurrentSession: getIt<GetCurrentSession>(),
      ).reconcileDomainReminders(
        activeContextRepository: getIt<ActiveContextRepository>(),
        getAgendaOverview: getIt<GetAgendaOverview>(),
        getHealthOverview: getIt<GetHealthOverview>(),
      );
      if (reconciled) _lastReminderReconciliationKey = reconciliationKey;
    } on Object catch (error, stackTrace) {
      debugPrint('Notification domain reconciliation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _reconcilingReminders = false;
    }
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await getIt<AppSettingsRepository>().get();
      if (!mounted) return;
      final use24HourFormat = settings.timeFormat != '12 horas';
      final reduceMotion = settings.reduceMotion;
      final highContrast = settings.highContrast;
      final textScaleFactor = switch (settings.textSize.toLowerCase()) {
        'pequeño' || 'pequeña' => .9,
        'grande' => 1.15,
        _ => 1,
      };
      // Los cambios de tema y de sincronización también notifican este
      // repositorio. No deben reconstruir todo MaterialApp/MediaQuery cuando
      // ninguna preferencia que este wrapper aplica ha cambiado.
      if (_use24HourFormat == use24HourFormat &&
          _reduceMotion == reduceMotion &&
          _highContrast == highContrast &&
          _textScaleFactor == textScaleFactor) {
        return;
      }
      setState(() {
        _use24HourFormat = use24HourFormat;
        _reduceMotion = reduceMotion;
        _highContrast = highContrast;
        _textScaleFactor = textScaleFactor.toDouble();
      });
    } on Object {
      // Antes de autenticar no existe un ámbito de base local. Se mantienen
      // preferencias accesibles por defecto y se reintentará tras un cambio.
    }
  }

  @override
  void dispose() {
    _persistentSyncAlertTimer?.cancel();
    unawaited(_settingsSubscription?.cancel());
    unawaited(_syncUxSubscription?.cancel());
    unawaited(_startupStatusSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        alwaysUse24HourFormat: _use24HourFormat,
        disableAnimations: media.disableAnimations || _reduceMotion,
        highContrast: media.highContrast || _highContrast,
        textScaler: TextScaler.linear(
          media.textScaler.scale(1) * _textScaleFactor,
        ),
      ),
      child: widget.child,
    );
  }
}
