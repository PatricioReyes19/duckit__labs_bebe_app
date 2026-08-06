import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:intl/date_symbol_data_local.dart';
import 'main.directories.g.dart';

class BebeThemeItem {
  const BebeThemeItem({
    required this.isDark,
  });

  final bool isDark;
}

const _bebeThemeAssetPath =
    'packages/design_system/assets/json/bebe_theme.json';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_CL');

  try {
    final bebeTheme = await loadBebeTheme(
      _bebeThemeAssetPath,
    );

    runApp(
      WidgetbookApp(
        bebeTheme: bebeTheme,
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('Error loading BebéApp theme: $error');
    debugPrintStack(stackTrace: stackTrace);

    runApp(
      ThemeLoadErrorApp(
        error: error,
      ),
    );
  }
}

class ThemeLoadErrorApp extends StatelessWidget {
  const ThemeLoadErrorApp({
    required this.error,
    super.key,
  });

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudo cargar bebe_theme.json.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({
    required this.bebeTheme,
    super.key,
  });

  final BebeTheme bebeTheme;

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      themeMode: ThemeMode.dark,
      addons: [
        ThemeAddon<BebeThemeItem>(
          themeBuilder: (context, item, child) {
            final themeData =
                item.isDark ? bebeTheme.darkTheme() : bebeTheme.lightTheme();

            return Theme(
              data: themeData,
              child: child,
            );
          },
          initialTheme: const WidgetbookTheme(
            name: 'BebéApp Light',
            data: BebeThemeItem(
              isDark: false,
            ),
          ),
          themes: const [
            WidgetbookTheme(
              name: 'BebéApp Light',
              data: BebeThemeItem(
                isDark: false,
              ),
            ),
            WidgetbookTheme(
              name: 'BebéApp Dark',
              data: BebeThemeItem(
                isDark: true,
              ),
            ),
          ],
        ),
        InspectorAddon(
          enabled: true,
        ),
        ViewportAddon(
          [
            Viewports.none,
            const ViewportData(
              name: 'Android compacto',
              width: 320,
              height: 640,
              pixelRatio: 2,
              platform: TargetPlatform.android,
            ),
            const ViewportData(
              name: 'Android estándar',
              width: 412,
              height: 917,
              pixelRatio: 3,
              platform: TargetPlatform.android,
            ),
            IosViewports.iPhoneSE,
            IosViewports.iPhone13Mini,
            const ViewportData(
              name: 'iPhone 16 Pro Max',
              width: 440,
              height: 956,
              pixelRatio: 3,
              platform: TargetPlatform.iOS,
              safeAreas: EdgeInsets.only(
                top: 47,
                bottom: 34,
              ),
            ),
          ],
        ),
        BuilderAddon(
          name: 'BebéApp Theme Surface',
          builder: (context, child) {
            final theme = context.theme;

            return ColoredBox(
              color: theme.colors.background.basicsWhite,
              child: child,
            );
          },
        ),
      ],
    );
  }
}

Future<BebeTheme> loadBebeTheme(
  String assetPath,
) async {
  final jsonString = await rootBundle.loadString(
    assetPath,
  );

  final decoded = jsonDecode(jsonString);

  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'bebe_theme.json debe contener un objeto JSON.',
    );
  }

  return BebeTheme.fromJson(decoded);
}
