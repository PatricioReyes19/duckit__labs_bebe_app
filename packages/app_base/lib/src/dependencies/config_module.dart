import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ConfigModule {
  @preResolve
  @Named('initialIsDark')
  Future<bool> initialIsDark(
    ThemeStorage themeStorage,
  ) async {
    final storedMode = await themeStorage.getThemeMode();

    return storedMode == 'dark';
  }
}
