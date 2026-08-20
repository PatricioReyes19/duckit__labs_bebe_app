import 'dart:async';

import 'package:app_base/app_base.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:notifications/notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'dependencies/dependencies.dart' hide getIt;

Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // El splash nativo se mantiene hasta que la app esté lista para montar
      // el router. Así se evita un árbol Flutter de transición entre el
      // splash nativo y la composición de nubes de `SplashView`.

      const environment = AppEnvironment.current;
      environment.ensureValid(platformFlavor: appFlavor);

      await initializeDateFormatting('es_CL');

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final supabaseConfiguration =
          SupabaseConfiguration.fromAppEnvironment(environment);
      if (supabaseConfiguration.isConfigured) {
        await Supabase.initialize(
          url: supabaseConfiguration.url,
          publishableKey: supabaseConfiguration.publishableKey,
          accessToken: () async =>
              FirebaseAuth.instance.currentUser?.getIdToken(),
        );
      }
      registerNotificationBackgroundHandler();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      FlutterError.onError = FlutterError.presentError;

      PlatformDispatcher.instance.onError = (
        error,
        stack,
      ) {
        debugPrint('Platform error: $error');
        debugPrintStack(stackTrace: stack);
        return true;
      };

      try {
        await setupDependencies();

        // Mantener el caché dentro de un presupuesto razonable para equipos
        // Android de gama media. Las imágenes se pueden recargar; terminar el
        // proceso por presión de memoria es peor que un cache miss.
        PaintingBinding.instance.imageCache.maximumSizeBytes = 96 << 20;

        final themeBloc = getIt<AppThemeBloc>();
        final sessionBloc = getIt<SessionBloc>()..add(const SessionStarted());
        final notificationService = getIt<NotificationService>();
        try {
          await notificationService.initialize();
        } on Object catch (error, stackTrace) {
          debugPrint('Notification initialization error: $error');
          debugPrintStack(stackTrace: stackTrace);
        }

        runApp(
          AppBuilder(
            themeBloc: themeBloc,
            app: App(
              customBlocProviders: [
                BlocProvider<AppThemeBloc>.value(
                  value: themeBloc,
                ),
                BlocProvider<SessionBloc>.value(
                  value: sessionBloc,
                ),
              ],
            ),
          ),
        );
      } on Object catch (error, stackTrace) {
        debugPrint('Bootstrap error: $error');
        debugPrintStack(
          stackTrace: stackTrace,
        );

        final themeBloc =
            getIt.isRegistered<AppThemeBloc>() ? getIt<AppThemeBloc>() : null;

        final app = themeBloc == null
            ? const AppError()
            : AppBuilder(
                themeBloc: themeBloc,
                preconditionView: const AppError(),
                app: const SizedBox.shrink(),
              );
        runApp(app);
      }
    },
    (error, stackTrace) {
      debugPrint('Unhandled zone error: $error');
      debugPrintStack(
        stackTrace: stackTrace,
      );
    },
  );
}
