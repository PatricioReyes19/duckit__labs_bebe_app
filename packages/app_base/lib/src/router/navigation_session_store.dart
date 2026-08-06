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
    StartupPaths.login,
    StartupPaths.signUp,
    StartupPaths.onboarding,
    StartupPaths.invitation,
    StartupPaths.createCareCircle,
    StartupPaths.selectCareCircle,
    StartupPaths.createBaby,
    StartupPaths.selectBaby,
    StartupPaths.home,
    '/agenda',
    '/health',
    '/family',
    '/register',
    '/notifications',
    '/settings',
  };

  final SharedPreferences _preferences;

  String get initialLocation {
    final location = _preferences.getString(_locationKey);
    if (location == null) {
      return StartupPaths.splash;
    }

    final uri = Uri.tryParse(location);
    if (uri == null || !_restorablePaths.contains(uri.path)) {
      return StartupPaths.splash;
    }

    return location;
  }

  Future<void> remember(Uri location) async {
    if (location.path == StartupPaths.splash) {
      await _preferences.remove(_locationKey);
      return;
    }

    if (_restorablePaths.contains(location.path)) {
      await _preferences.setString(_locationKey, location.toString());
    }
  }
}
