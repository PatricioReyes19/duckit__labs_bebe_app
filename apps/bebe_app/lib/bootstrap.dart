import 'dart:async';

import 'package:app_base/app_base.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dependencies/dependencies.dart' hide getIt;

Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

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

        PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20;

        final themeBloc = getIt<AppThemeBloc>();

        runApp(
          AppBuilder(
            themeBloc: themeBloc,
            app: App(
              customBlocProviders: [
                BlocProvider<AppThemeBloc>.value(
                  value: themeBloc,
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
