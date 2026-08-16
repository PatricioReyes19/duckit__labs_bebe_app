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
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'dependencies/dependencies.dart' hide getIt;

Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Entrega el primer frame de Flutter inmediatamente. De esta forma el
      // splash nativo no permanece visible durante Firebase, DI y servicios.
      runApp(const _BootstrapSplashHandoff());
      await WidgetsBinding.instance.endOfFrame;

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

/// Puente visual liviano entre el splash nativo y el flujo de arranque real.
/// No depende de servicios ni de GetIt, por lo que puede pintarse de inmediato.
class _BootstrapSplashHandoff extends StatefulWidget {
  const _BootstrapSplashHandoff();

  @override
  State<_BootstrapSplashHandoff> createState() =>
      _BootstrapSplashHandoffState();
}

class _BootstrapSplashHandoffState extends State<_BootstrapSplashHandoff>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFC),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F2A2D),
      ),
      home: Scaffold(
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = Curves.easeInOut.transform(_controller.value);
              return Opacity(
                opacity: .86 + (progress * .14),
                child: Transform.scale(
                  scale: .97 + (progress * .03),
                  child: child,
                ),
              );
            },
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BebeBrandMark(
                      variant: isDark
                          ? BebeBrandMarkVariant.darkColor
                          : BebeBrandMarkVariant.light,
                      size: 112,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppEnvironment.current.appDisplayName,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: isDark
                                    ? const Color(0xFFF4FBFB)
                                    : const Color(0xFF008C91),
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
