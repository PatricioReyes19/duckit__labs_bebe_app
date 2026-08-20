import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/startup.dart';
import 'package:design_system/themes/bebe_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splash/splash.dart';

class _ImmediateResolver implements ResolveEntryDestination {
  const _ImmediateResolver(this.destination);

  final EntryDestination destination;

  @override
  Future<EntryResolution> call() async {
    return EntryResolution(destination: destination);
  }
}

class _ControlledResolver implements ResolveEntryDestination {
  final completer = Completer<EntryResolution>();

  @override
  Future<EntryResolution> call() => completer.future;
}

class _ThrowingResolver implements ResolveEntryDestination {
  @override
  Future<EntryResolution> call() => throw StateError('startup failed');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BebeTheme bebeTheme;
  late Directory workspaceRoot;
  late AssetBundle testAssetBundle;

  setUpAll(() async {
    workspaceRoot = _findWorkspaceRoot();
    testAssetBundle = _WorkspaceAssetBundle(workspaceRoot);
    final themeFile = File(
      '${workspaceRoot.path}/packages/design_system/assets/json/'
      'bebe_theme.json',
    );
    final themeJson =
        jsonDecode(await themeFile.readAsString()) as Map<String, dynamic>;
    bebeTheme = BebeTheme.fromJson(themeJson);

    final fontBytes = await File(
      '${workspaceRoot.path}/packages/design_system/assets/fonts/'
      'PlusJakartaSans-Regular.ttf',
    ).readAsBytes();
    await (FontLoader('PlusJakartaSans')
          ..addFont(Future.value(ByteData.sublistView(fontBytes))))
        .load();
  });

  final goldenCases = <({String name, Size size, Brightness brightness})>[
    (
      name: '320x568_light',
      size: const Size(320, 568),
      brightness: Brightness.light,
    ),
    (
      name: '320x568_dark',
      size: const Size(320, 568),
      brightness: Brightness.dark,
    ),
    (
      name: '375x812_light',
      size: const Size(375, 812),
      brightness: Brightness.light,
    ),
    (
      name: '375x812_dark',
      size: const Size(375, 812),
      brightness: Brightness.dark,
    ),
    (
      name: '390x844_light',
      size: const Size(390, 844),
      brightness: Brightness.light,
    ),
    (
      name: '390x844_dark',
      size: const Size(390, 844),
      brightness: Brightness.dark,
    ),
    (
      name: '430x932_light',
      size: const Size(430, 932),
      brightness: Brightness.light,
    ),
    (
      name: '430x932_dark',
      size: const Size(430, 932),
      brightness: Brightness.dark,
    ),
    (
      name: '800x1280_light',
      size: const Size(800, 1280),
      brightness: Brightness.light,
    ),
    (
      name: '800x1280_dark',
      size: const Size(800, 1280),
      brightness: Brightness.dark,
    ),
  ];

  for (final goldenCase in goldenCases) {
    testWidgets('golden ${goldenCase.name}', (tester) async {
      await _pumpBrandContent(
        tester,
        theme: bebeTheme,
        assetBundle: testAssetBundle,
        size: goldenCase.size,
        brightness: goldenCase.brightness,
      );

      expect(tester.takeException(), isNull);
      final loadedKeys = (testAssetBundle as _WorkspaceAssetBundle).loadedKeys;
      expect(
        loadedKeys,
        contains('packages/splash/assets/branding/'
            '${goldenCase.brightness == Brightness.dark ? 'dark' : 'light'}'
            '/splash_clouds_background.png'),
      );
      await expectLater(
        find.byType(SplashBrandContent),
        matchesGoldenFile('goldens/splash_${goldenCase.name}.png'),
      );
    });
  }

  testWidgets('mantiene textos legibles con escala 1.3', (tester) async {
    await _pumpBrandContent(
      tester,
      theme: bebeTheme,
      assetBundle: testAssetBundle,
      size: const Size(320, 568),
      brightness: Brightness.light,
      textScale: 1.3,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('BebéApp'), findsOneWidget);
    expect(find.text('Cuidamos juntos\nlo que más importa'), findsOneWidget);
  });

  testWidgets('reduce motion usa una introducción breve sin idle', (
    tester,
  ) async {
    var completed = 0;
    await _pumpApp(
      tester,
      theme: bebeTheme,
      assetBundle: testAssetBundle,
      size: const Size(390, 844),
      brightness: Brightness.light,
      disableAnimations: true,
      child: SplashBrandIntro(
        onIntroCompleted: () => completed++,
      ),
    );

    await tester.pump(const Duration(milliseconds: 159));
    expect(completed, 0);
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();
    expect(completed, 1);
    await tester.pump(const Duration(seconds: 3));
    expect(completed, 1);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('espera la intro si la resolución termina primero', (
    tester,
  ) async {
    EntryDestination? destination;
    await _pumpSplashView(
      tester,
      theme: bebeTheme,
      assetBundle: testAssetBundle,
      resolver: const _ImmediateResolver(EntryDestination.home),
      onDestinationResolved: (value) => destination = value,
    );

    await tester.pump(const Duration(milliseconds: 1199));
    expect(destination, isNull);
    await tester.pump(const Duration(milliseconds: 2));
    for (var frame = 0; frame < 5 && destination == null; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(destination, EntryDestination.home);
  });

  testWidgets('permanece estable si la resolución tarda más que la intro', (
    tester,
  ) async {
    final resolver = _ControlledResolver();
    EntryDestination? destination;
    await _pumpSplashView(
      tester,
      theme: bebeTheme,
      assetBundle: testAssetBundle,
      resolver: resolver,
      onDestinationResolved: (value) => destination = value,
    );

    await tester.pump(const Duration(seconds: 2));
    expect(destination, isNull);

    resolver.completer.complete(
      const EntryResolution(destination: EntryDestination.authEntry),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(destination, EntryDestination.authEntry);
  });

  testWidgets('el error conserva el fondo temático del splash', (
    tester,
  ) async {
    await _pumpSplashView(
      tester,
      theme: bebeTheme,
      assetBundle: testAssetBundle,
      resolver: _ThrowingResolver(),
      onDestinationResolved: (_) {},
    );

    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('No pudimos iniciar'), findsOneWidget);
    expect(find.byKey(const Key('splash-clouds-background')), findsOneWidget);
  });

  testWidgets('retry rápido no produce claves duplicadas ni errores de layout', (
    tester,
  ) async {
    await _pumpSplashView(
      tester,
      theme: bebeTheme,
      assetBundle: testAssetBundle,
      resolver: _ThrowingResolver(),
      onDestinationResolved: (_) {},
    );

    for (var retry = 0; retry < 2; retry++) {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(find.text('Reintentar'));
      await tester.pump(const Duration(milliseconds: 80));
    }

    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpBrandContent(
  WidgetTester tester, {
  required BebeTheme theme,
  required AssetBundle assetBundle,
  required Size size,
  required Brightness brightness,
  double textScale = 1,
}) {
  return _pumpApp(
    tester,
    theme: theme,
    assetBundle: assetBundle,
    size: size,
    brightness: brightness,
    textScale: textScale,
    child: const SplashBrandContent(),
  );
}

Future<void> _pumpSplashView(
  WidgetTester tester, {
  required BebeTheme theme,
  required AssetBundle assetBundle,
  required ResolveEntryDestination resolver,
  required ValueChanged<EntryDestination> onDestinationResolved,
}) {
  return _pumpApp(
    tester,
    theme: theme,
    assetBundle: assetBundle,
    size: const Size(390, 844),
    brightness: Brightness.light,
    child: BlocProvider(
      create: (_) => SplashBloc(resolveEntryDestination: resolver),
      child: SplashView(
        onDestinationResolved: (_, destination) {
          onDestinationResolved(destination);
        },
        onInvitationAccessRequested: () {},
      ),
    ),
  );
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required BebeTheme theme,
  required AssetBundle assetBundle,
  required Size size,
  required Brightness brightness,
  required Widget child,
  double textScale = 1,
  bool disableAnimations = false,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme(),
      darkTheme: theme.darkTheme(),
      themeMode:
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: DefaultAssetBundle(
          bundle: assetBundle,
          child: child,
        ),
      ),
    ),
  );
  await tester.pump();

  var imagesReady = false;
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump();

    final rawImages = tester
        .widgetList<RawImage>(find.byType(RawImage))
        .toList(growable: false);
    imagesReady = rawImages.length >= 2 &&
        rawImages.every((rawImage) => rawImage.image != null);
    if (imagesReady) {
      break;
    }
  }

  if (!imagesReady) {
    throw TestFailure('Los assets del splash no entregaron un frame.');
  }
}

Directory _findWorkspaceRoot() {
  var directory = Directory.current.absolute;
  while (true) {
    final pubspec = File('${directory.path}/pubspec.yaml');
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains(
              'name: duckit_labs_bebe_app_workspace',
            )) {
      return directory;
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      throw StateError('No se encontró la raíz del workspace BebéApp.');
    }
    directory = parent;
  }
}

class _WorkspaceAssetBundle extends CachingAssetBundle {
  _WorkspaceAssetBundle(this.workspaceRoot);

  final Directory workspaceRoot;
  final loadedKeys = <String>{};

  @override
  Future<ByteData> load(String key) async {
    loadedKeys.add(key);
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage(
        <String, Object?>{},
      )!;
    }
    if (key == 'AssetManifest.json') {
      return ByteData.sublistView(Uint8List.fromList(utf8.encode('{}')));
    }
    if (key == 'FontManifest.json') {
      return ByteData.sublistView(Uint8List.fromList(utf8.encode('[]')));
    }

    final normalizedKey = key.replaceAll('/', Platform.pathSeparator);
    final bytes = await File(
      '${workspaceRoot.path}${Platform.pathSeparator}$normalizedKey',
    ).readAsBytes();
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}
