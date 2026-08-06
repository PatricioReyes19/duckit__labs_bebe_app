import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesThemeStorage', () {
    late SharedPreferencesThemeStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = SharedPreferencesThemeStorage(
        await SharedPreferences.getInstance(),
      );
    });

    test('returns null when no theme has been stored', () async {
      expect(await storage.getThemeMode(), isNull);
    });

    test('persists and retrieves the selected theme', () async {
      await storage.saveThemeMode('dark');

      expect(await storage.getThemeMode(), 'dark');
    });
  });
}
