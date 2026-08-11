import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../dependencies/dependencies.dart';
import 'app_listeners.dart';

/// Aplica preferencias que deben alcanzar a toda la aplicación.
class AppWrappers extends StatefulWidget {
  const AppWrappers({required this.child, super.key});

  final Widget child;

  @override
  State<AppWrappers> createState() => _AppWrappersState();
}

class _AppWrappersState extends State<AppWrappers> {
  StreamSubscription<void>? _settingsSubscription;
  StreamSubscription<RegisterSyncState>? _registerSyncSubscription;
  StreamSubscription<RegisterSyncState>? _agendaSyncSubscription;
  bool _use24HourFormat = true;
  bool _reduceMotion = false;
  bool _highContrast = false;
  double _textScaleFactor = 1;
  late RegisterSyncState _registerSyncState;
  late RegisterSyncState _agendaSyncState;

  @override
  void initState() {
    super.initState();
    final repository = getIt<AppSettingsRepository>();
    _registerSyncState = getIt<RegisterEventSyncService>().state;
    _agendaSyncState = getIt<AgendaEventSyncService>().state;
    _settingsSubscription = repository.changes.listen((_) => _loadSettings());
    _registerSyncSubscription = getIt<RegisterEventSyncService>().states.listen(
          (state) => _syncChanged(register: state),
        );
    _agendaSyncSubscription = getIt<AgendaEventSyncService>().states.listen(
          (state) => _syncChanged(agenda: state),
        );
    unawaited(_loadSettings());
  }

  void _syncChanged({RegisterSyncState? register, RegisterSyncState? agenda}) {
    final wasSyncing = _isSyncing;
    setState(() {
      if (register != null) _registerSyncState = register;
      if (agenda != null) _agendaSyncState = agenda;
    });
    if (wasSyncing && !_isSyncing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final failed = _hasSyncFailure;
        final messenger = appScaffoldMessengerKey.currentState;
        if (messenger != null) {
          BebeInAppSnackbar.showOn(
            messenger,
            title: failed ? 'Error de sincronización' : 'Sincronización lista',
            message: failed
                ? 'Algunos datos no pudieron sincronizarse. Se reintentará automáticamente.'
                : 'Datos sincronizados y actualizados.',
            variant: failed
                ? BebeInAppSnackbarVariant.error
                : BebeInAppSnackbarVariant.syncing,
          );
        }
      });
    }
  }

  bool get _isSyncing =>
      _registerSyncState.phase == RegisterSyncPhase.syncing ||
      _agendaSyncState.phase == RegisterSyncPhase.syncing;

  bool get _hasSyncFailure =>
      _registerSyncState.phase == RegisterSyncPhase.failed ||
      _agendaSyncState.phase == RegisterSyncPhase.failed;

  int get _pendingSyncCount =>
      _registerSyncState.pendingCount + _agendaSyncState.pendingCount;

  Future<void> _loadSettings() async {
    try {
      final settings = await getIt<AppSettingsRepository>().get();
      if (!mounted) return;
      setState(() {
        _use24HourFormat = settings.timeFormat != '12 horas';
        _reduceMotion = settings.reduceMotion;
        _highContrast = settings.highContrast;
        _textScaleFactor = switch (settings.textSize.toLowerCase()) {
          'pequeño' || 'pequeña' => .9,
          'grande' => 1.15,
          _ => 1,
        };
      });
    } on Object {
      // Antes de autenticar no existe un ámbito de base local. Se mantienen
      // preferencias accesibles por defecto y se reintentará tras un cambio.
    }
  }

  @override
  void dispose() {
    unawaited(_settingsSubscription?.cancel());
    unawaited(_registerSyncSubscription?.cancel());
    unawaited(_agendaSyncSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final wrappedChild = MediaQuery(
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
    return Stack(
      children: [
        wrappedChild,
        if (_isSyncing)
          Positioned(
            top: media.padding.top + 8,
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: BebeStatusBanner(
                title: 'Sincronizando datos',
                description: _pendingSyncCount == 0
                    ? 'Descargando y actualizando información…'
                    : 'Subiendo $_pendingSyncCount cambios y actualizando información…',
                type: BebeStatusBannerType.information,
                leading: const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                compact: true,
              ),
            ),
          ),
      ],
    );
  }
}
