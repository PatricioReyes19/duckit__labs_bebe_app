import 'package:design_system/design_system.dart';
import 'package:injectable/injectable.dart';

@module
abstract class PreloadModule {
  @preResolve
  @lazySingleton
  Future<BebeTheme> initTheme() async {
    final theme = await loadBebeTheme();

    return theme;
  }
}
