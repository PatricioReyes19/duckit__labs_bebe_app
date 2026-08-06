import 'package:app_base/src/router/navigation_session_store.dart';
import 'package:app_base/src/router/router.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RouterModule {
  @lazySingleton
  GoRouter router(SharedPreferences preferences) {
    return createAppRouter(
      navigationSessionStore: NavigationSessionStore(preferences),
    );
  }
}
