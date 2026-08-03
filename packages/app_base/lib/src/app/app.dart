import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../dependencies/dependencies.dart';
import '../router/router.dart';
import 'app_analytics.dart';
import 'app_lifecycle_observer.dart';
import 'app_listeners.dart';
import 'app_providers.dart';
import 'app_wrappers.dart';

export 'app_error.dart';

class App extends StatelessWidget {
  const App({
    this.customBlocProviders = const <BlocProvider<dynamic>>[],
    super.key,
  });

  final List<BlocProvider<dynamic>> customBlocProviders;

  @override
  Widget build(BuildContext context) {
    return AppAnalytics(
      child: AppProviders(
        customBlocProviders: customBlocProviders,
        child: AppListeners(
          child: Builder(
            builder: (context) {
              final router = _resolveRouter();

              return AppLifecycleObserver(
                child: MaterialApp.router(
                  title: 'DuckIT BebéApp',
                  debugShowCheckedModeBanner: false,
                  routerConfig: router,
                  theme: ThemeData(
                    useMaterial3: true,
                    colorSchemeSeed: const Color(0xFF2F7194),
                    brightness: Brightness.light,
                    scaffoldBackgroundColor: Colors.white,
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    colorSchemeSeed: const Color(0xFF2F7194),
                    brightness: Brightness.dark,
                  ),
                  themeMode: ThemeMode.system,
                  locale: const Locale('es', 'CL'),
                  supportedLocales: const [Locale('es', 'CL')],
                  localizationsDelegates:
                      GlobalMaterialLocalizations.delegates,
                  builder: (context, child) => AppWrappers(
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  GoRouter _resolveRouter() {
    if (getIt.isRegistered<GoRouter>()) {
      return getIt<GoRouter>();
    }
    final router = createAppRouter();
    getIt.registerSingleton<GoRouter>(router);
    return router;
  }
}
