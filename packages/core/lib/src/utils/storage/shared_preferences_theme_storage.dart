import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesThemeStorage implements ThemeStorage {
  SharedPreferencesThemeStorage(this._preferences);

  static const _themeModeKey = 'theme_mode';

  final SharedPreferences _preferences;

  @override
  Future<String?> getThemeMode() async {
    return _preferences.getString(_themeModeKey);
  }

  @override
  Future<void> saveThemeMode(String mode) async {
    await _preferences.setString(_themeModeKey, mode);
  }
}
