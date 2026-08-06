import 'dart:convert';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding/onboarding.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeData theme;

  setUpAll(() {
    final themeFile = [
      File('packages/design_system/assets/json/bebe_theme.json'),
      File('../design_system/assets/json/bebe_theme.json'),
    ].firstWhere((candidate) => candidate.existsSync());
    final themeJson =
        jsonDecode(themeFile.readAsStringSync()) as Map<String, dynamic>;
    theme = BebeTheme.fromJson(themeJson).lightTheme();
  });

  testWidgets('back del sistema retrocede el paso antes de salir de la ruta', (
    tester,
  ) async {
    var exits = 0;
    await tester.pumpWidget(
      _TestRouterApp(
        theme: theme,
        entry: OnboardingEntry.choice,
        onExitRequested: () => exits++,
      ),
    );

    await tester.tap(find.byKey(const Key('onboarding_create_baby')));
    await tester.pumpAndSettle();
    expect(find.text('Crear perfil del bebé'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding_create_baby')), findsOneWidget);
    expect(exits, 0);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(exits, 1);
  });

  testWidgets('back visible de una entrada directa solicita salir de la ruta', (
    tester,
  ) async {
    var exits = 0;
    await tester.pumpWidget(
      _TestRouterApp(
        theme: theme,
        entry: OnboardingEntry.babyProfile,
        onExitRequested: () => exits++,
      ),
    );

    await tester.tap(find.byTooltip('Volver'));
    await tester.pump();

    expect(exits, 1);
  });
}

class _TestRouterApp extends StatefulWidget {
  const _TestRouterApp({
    required this.theme,
    required this.entry,
    required this.onExitRequested,
  });

  final ThemeData theme;
  final OnboardingEntry entry;
  final VoidCallback onExitRequested;

  @override
  State<_TestRouterApp> createState() => _TestRouterAppState();
}

class _TestRouterAppState extends State<_TestRouterApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        OnboardingPage(
          path: '/onboarding',
          onboardingRepository: (_) => _FakeOnboardingRepository(),
          entry: widget.entry,
          onCompleted: (_) {},
          onExitRequested: (_) => widget.onExitRequested(),
          onUseAnotherAccount: (_) {},
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: widget.theme,
      routerConfig: _router,
    );
  }
}

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> acceptInvitation(CareInvitation invitation) async {}

  @override
  Future<void> complete() async {}

  @override
  Future<BabyProfile> createBaby(BabyDraft draft) => throw UnimplementedError();

  @override
  Future<void> declineInvitation(CareInvitation invitation) async {}

  @override
  Future<InvitationLookupResult> findInvitation(String code) =>
      throw UnimplementedError();

  @override
  Future<bool> isCompleted() async => false;
}
