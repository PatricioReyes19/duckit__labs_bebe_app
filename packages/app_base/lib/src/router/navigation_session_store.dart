import 'package:shared_preferences/shared_preferences.dart';

import 'startup_route_mapper.dart';

/// Conserva una ubicación segura entre reconstrucciones completas de la app.
///
/// El splash sigue siendo la entrada de una instalación o sesión sin historial,
/// pero no se vuelve a insertar al recargar una ruta funcional conocida.
class NavigationSessionStore {
  NavigationSessionStore(this._preferences);

  static const _locationKey = 'bebeapp.navigation.last_location';

  static const _restorablePaths = <String>{
    StartupPaths.authEntry,
    StartupPaths.onboarding,
    StartupPaths.invitation,
    StartupPaths.createCareCircle,
    StartupPaths.selectCareCircle,
    StartupPaths.createBaby,
    StartupPaths.selectBaby,
    StartupPaths.home,
    '/home/history',
    '/agenda',
    '/agenda/reminders/settings',
    '/agenda/reminders/new',
    '/health',
    '/health/vaccines',
    '/health/controls',
    '/health/growth',
    '/health/consultations',
    '/health/pediatric-care',
    '/health/clinical-history',
    '/family',
    '/family/babies',
    '/family/babies/new',
    '/family/care-circle',
    '/family/care-circle/invite',
    '/family/settings',
    '/register',
    '/register/sleep',
    '/register/diaper',
    '/register/observation',
    '/register/medication',
    '/register/measurement',
    '/notifications',
    // Se conserva temporalmente para migrar sesiones de la ruta anterior.
    '/settings',
  };

  static const _restorablePrefixes = <String>{
    '/agenda/events/',
    '/family/members/',
    '/family/settings/',
  };

  final SharedPreferences _preferences;

  String get initialLocation {
    final location = _preferences.getString(_locationKey);
    if (location == null) {
      return StartupPaths.splash;
    }

    final uri = Uri.tryParse(location);
    if (uri == null || !_isRestorable(uri.path)) {
      return StartupPaths.splash;
    }

    return location;
  }

  Future<void> remember(Uri location) async {
    if (location.path == StartupPaths.splash) {
      await _preferences.remove(_locationKey);
      return;
    }

    if (_isRestorable(location.path)) {
      await _preferences.setString(_locationKey, location.toString());
    }
  }

  static bool _isRestorable(String path) {
    return _restorablePaths.contains(path) ||
        _restorablePrefixes.any(path.startsWith);
  }
}
