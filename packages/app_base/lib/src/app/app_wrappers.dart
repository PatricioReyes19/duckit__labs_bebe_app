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
  StreamSubscription<SyncUxState>? _syncUxSubscription;
  final _syncAlertDeduplicator = SyncErrorAlertDeduplicator();
  bool _use24HourFormat = true;
  bool _reduceMotion = false;
  bool _highContrast = false;
  double _textScaleFactor = 1;

  @override
  void initState() {
    super.initState();
    final repository = getIt<AppSettingsRepository>();
    final syncCoordinator = getIt<InitialDataSyncCoordinator>();
    _settingsSubscription = repository.changes.listen((_) => _loadSettings());
    _syncUxSubscription = syncCoordinator.syncUxStates.listen(_syncChanged);
    _syncChanged(syncCoordinator.syncUxState);
    unawaited(_loadSettings());
  }

  void _syncChanged(SyncUxState state) {
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
    unawaited(_syncUxSubscription?.cancel());
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
