import 'dart:async';

import 'package:app_base/app_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await configureDependencies();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      FlutterError.onError = (details) {
        FlutterError.presentError(details);

        if (kDebugMode) {
          debugPrint(
            '[BebéApp][Flutter] ${details.exceptionAsString()}',
          );
          debugPrintStack(stackTrace: details.stack);
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        if (kDebugMode) {
          debugPrint(
            '[BebéApp][Platform] $error',
          );
          debugPrintStack(stackTrace: stack);
        }

        return true;
      };

      runApp(const BebeApp());
    },
    (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Zoned error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    },
  );
}
