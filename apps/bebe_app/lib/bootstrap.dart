import 'dart:async';

import 'package:app_base/app_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dependencies/dependencies.dart';

Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      FlutterError.onError = FlutterError.presentError;

      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Platform error: $error');
        debugPrintStack(stackTrace: stack);
        return true;
      };

      try {
        await setupDependencies();

        PaintingBinding.instance.imageCache.maximumSizeBytes =
            300 << 20;

        runApp(
          const AppBuilder(
            app: App(),
          ),
        );
      } on Object catch (error, stack) {
        debugPrint('Bootstrap error: $error');
        debugPrintStack(stackTrace: stack);
        runApp(const AppError());
      }
    },
    (error, stackTrace) {
      debugPrint('Zoned error: $error');
      debugPrintStack(stackTrace: stackTrace);
    },
  );
}
