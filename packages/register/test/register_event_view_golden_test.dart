import 'dart:convert';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:register/register.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BebeTheme bebeTheme;

  setUpAll(() async {
    final candidates = [
      File('../design_system/assets/json/bebe_theme.json'),
      File('packages/design_system/assets/json/bebe_theme.json'),
    ];
    final file = candidates.firstWhere((candidate) => candidate.existsSync());
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    bebeTheme = BebeTheme.fromJson(json);

    final fontLoader = FontLoader('PlusJakartaSans')
      ..addFont(
        _loadFont('PlusJakartaSans-Regular.ttf'),
      )
      ..addFont(
        _loadFont('PlusJakartaSans-Medium.ttf'),
      )
      ..addFont(
        _loadFont('PlusJakartaSans-SemiBold.ttf'),
      )
      ..addFont(
        _loadFont('PlusJakartaSans-Bold.ttf'),
      );
    await fontLoader.load();

    final materialIconsLoader = FontLoader('MaterialIcons')
      ..addFont(_loadMaterialIcons());
    await materialIconsLoader.load();
  });

  const viewports = <(int, int)>[
    (320, 568),
    (375, 812),
    (390, 844),
    (430, 932),
    (768, 1024),
  ];

  for (final brightness in Brightness.values) {
    for (final viewport in viewports) {
      final width = viewport.$1;
      final height = viewport.$2;
      testWidgets('golden ${brightness.name} $width x $height', (tester) async {
        tester.view.physicalSize = Size(width.toDouble(), height.toDouble());
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final theme = brightness == Brightness.light
            ? bebeTheme.lightTheme()
            : bebeTheme.darkTheme();
        await tester.pumpWidget(
          MaterialApp(theme: theme, home: const _GoldenRegisterView()),
        );
        await tester.pump();

        await expectLater(
          find.byType(BebeRegisterEventTemplate),
          matchesGoldenFile(
            'goldens/register_feeding_${width}_${brightness.name}.png',
          ),
        );
      });
    }
  }
}

Future<ByteData> _loadFont(String name) async {
  final candidates = [
    File('../design_system/assets/fonts/$name'),
    File('packages/design_system/assets/fonts/$name'),
  ];
  final file = candidates.firstWhere((candidate) => candidate.existsSync());
  final bytes = await file.readAsBytes();
  return ByteData.sublistView(Uint8List.fromList(bytes));
}

Future<ByteData> _loadMaterialIcons() async {
  final executablePath = File(Platform.resolvedExecutable)
      .absolute
      .path
      .replaceAll('\\', '/');
  const cacheMarker = '/bin/cache/';
  final markerIndex = executablePath.indexOf(cacheMarker);
  if (markerIndex < 0) {
    throw StateError('Flutter cache not found from $executablePath');
  }
  final flutterCachePath = executablePath.substring(
    0,
    markerIndex + cacheMarker.length,
  );
  final file = File(
    '${flutterCachePath}artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  final bytes = await file.readAsBytes();
  return ByteData.sublistView(Uint8List.fromList(bytes));
}

class _GoldenRegisterView extends StatelessWidget {
  const _GoldenRegisterView();

  @override
  Widget build(BuildContext context) {
    return RegisterEventView(
      title: 'Registrar evento',
      selectedKind: RegisterEventKind.feeding,
      onKindChanged: (_) {},
      subcategories: const [
        BebeSegmentedItem(value: 'breast', label: 'Pecho'),
        BebeSegmentedItem(value: 'bottle', label: 'Mamadera'),
        BebeSegmentedItem(value: 'expressed', label: 'Leche extraída'),
        BebeSegmentedItem(value: 'formula', label: 'Fórmula'),
      ],
      selectedSubcategory: 'breast',
      onSubcategoryChanged: (_) {},
      contextTitle: 'Última toma hace 2 h 10 min',
      contextDescription: 'Sugerido cada 2–3 horas',
      contextTrailing: const Icon(Icons.info_outline_rounded),
      form: FeedingRegisterForm(
        onSideChanged: (_) {},
        onStartTimePressed: () {},
        onDurationPressed: () {},
        onEndTimePressed: () {},
        onMoodChanged: (_) {},
      ),
      onBackPressed: () {},
      onNotificationsPressed: () {},
      onBabyPressed: () {},
      onSavePressed: () {},
      onCancelPressed: () {},
    );
  }
}
