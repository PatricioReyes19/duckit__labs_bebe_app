import 'package:app_base/src/app/app_lifecycle_observer.dart';
import 'package:app_base/src/app/app_listeners.dart';
import 'package:app_base/src/app/app_providers.dart';
import 'package:app_base/src/app/app_wrappers.dart';
import 'package:app_base/src/dependencies/dependencies.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

export 'app_error.dart';

class App extends StatelessWidget {
  const App({
    this.customBlocProviders = const <BlocProvider<dynamic>>[],
    super.key,
  });

  final List<BlocProvider<dynamic>> customBlocProviders;

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      customBlocProviders: customBlocProviders,
      child: AppListeners(
        child: Builder(
          builder: (context) {
            final router = getIt<GoRouter>();

            final themeState = context.select(
              (AppThemeBloc bloc) => bloc.state,
            );

            final theme = themeState.theme;

            return AppLifecycleObserver(
              child: MaterialApp.router(
                title: 'DuckIT BebéApp',
                debugShowCheckedModeBanner: false,
                scaffoldMessengerKey: appScaffoldMessengerKey,
                routerConfig: router,
                theme: theme.lightTheme(),
                darkTheme: theme.darkTheme(),
                themeMode: themeState.themeMode,
                // El cambio inmediato evita congelamientos y frames con una
                // mezcla de ambos temas en dispositivos de gama media.
                themeAnimationDuration: Duration.zero,
                locale: const Locale('es', 'CL'),
                supportedLocales: const [
                  Locale('es', 'CL'),
                ],
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                builder: (context, child) {
                  return AppWrappers(
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
