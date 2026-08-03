abstract interface class ThemeStorage {
  Future<String?> getThemeMode();
  Future<void> saveThemeMode(String mode);
}
