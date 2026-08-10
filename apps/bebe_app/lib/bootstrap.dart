import 'dart:async';

import 'package:app_base/app_base.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:notifications/notifications.dart';

import 'firebase_options.dart';
import 'dependencies/dependencies.dart' hide getIt;

Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      const supabaseConfiguration = SupabaseConfiguration.fromEnvironment;
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
        getIt<RegisterAgendaCoordinator>().start();
        await getIt<SupabaseRealtimeSyncCoordinator>().start();
        unawaited(getIt<RegisterEventSyncService>().synchronize());
        unawaited(getIt<AgendaEventSyncService>().synchronize());

        PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20;

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

        runApp(
          themeBloc == null
              ? const AppError()
              : AppBuilder(
                  themeBloc: themeBloc,
                  preconditionView: const AppError(),
                  app: const SizedBox.shrink(),
                ),
        );
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
