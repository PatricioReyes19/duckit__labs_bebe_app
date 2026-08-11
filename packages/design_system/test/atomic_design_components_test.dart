import 'dart:convert';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BebeTheme bebeTheme;

  setUpAll(() {
    final candidates = [
      File('assets/json/bebe_theme.json'),
      File('packages/design_system/assets/json/bebe_theme.json'),
    ];
    final file = candidates.firstWhere((candidate) => candidate.existsSync());
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    bebeTheme = BebeTheme.fromJson(json);
  });

  testWidgets('cards grow with long copy at 320 px and 200% text', (
    tester,
  ) async {
    const buttonKey = Key('growing-button');
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        textScaler: const TextScaler.linear(2),
        child: SizedBox(
          width: 288,
          height: 720,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BebeTitleSection(
                  title:
                      'Resumen completo de información familiar de esta jornada',
                  description:
                      'Este texto debe mostrarse completo sin cortar palabras importantes.',
                  actionLabel: 'Abrir historial completo',
                  onActionPressed: () {},
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 96,
                  child: BebeFamilyMetricCard(
                    value: '12',
                    label: 'invitaciones pendientes de confirmación',
                    icon: Icon(Icons.mail_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                const BebeSettingsValueTile(
                  title: 'Formato de horario de los registros',
                  value: '24 horas',
                  description: 'Se aplica en toda la aplicación',
                ),
                const SizedBox(height: 16),
                BebeMetricsOverview(
                  minimumItemWidth: 96,
                  maximumColumnCount: 3,
                  children: [
                    BebeCompactMetricCard(
                      label: 'Alimentación',
                      value: '720',
                      unit: 'mL',
                      supportingText: '6 tomas',
                      icon: Icon(Icons.local_drink_outlined),
                    ),
                    BebeCompactMetricCard(
                      label: 'Sueño',
                      value: '8',
                      supportingText: 'registros',
                      icon: Icon(Icons.bedtime_outlined),
                    ),
                    BebeCompactMetricCard(
                      label: 'Pañales',
                      value: '5',
                      supportingText: 'cambios',
                      icon: Icon(Icons.water_drop_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BebeBabyProfileCard(
                  name: 'Nombre compuesto del bebé sin abreviar',
                  supportingText:
                      'Bebé activo con información adicional importante',
                  avatar: const ColoredBox(color: Colors.pink),
                  isActive: true,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                BebeDetailActionCard(
                  title: 'Configuración completa del núcleo familiar',
                  description:
                      'Administra miembros, permisos, invitaciones y accesos sin perder información.',
                  metadata:
                      'Última actualización realizada durante esta jornada',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                BebeButton(
                  key: buttonKey,
                  label: 'Guardar todos los cambios de configuración familiar',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      find.text('invitaciones pendientes de confirmación'),
      findsOneWidget,
    );
    expect(tester.getSize(find.byKey(buttonKey)).height, greaterThan(56));
  });

  testWidgets('today summary exposes the full-day history action', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: SizedBox(
          width: 342,
          child: BebeTodaySummary(
            title: 'Resumen de hoy',
            items: _metrics,
            onHistoryPressed: () => opened = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ver historial'));

    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('section titles stay on one line', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: const SizedBox(
          width: 260,
          child: BebeTitleSection(title: 'Próximos en salud'),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text('Próximos en salud'));
    expect(title.maxLines, 1);
    expect(title.softWrap, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('carousel edge inset scrolls away with the first card', (
    tester,
  ) async {
    const firstKey = Key('first-carousel-card');
    const secondKey = Key('second-carousel-card');
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: SizedBox(
          width: 320,
          child: BebeHorizontalCardCarousel(
            height: 100,
            viewportFraction: .82,
            showPageIndicator: false,
            children: const [
              ColoredBox(key: firstKey, color: Colors.teal),
              ColoredBox(key: secondKey, color: Colors.purple),
            ],
          ),
        ),
      ),
    );

    final viewportLeft = tester.getTopLeft(find.byType(PageView)).dx;
    final firstInset =
        tester.getTopLeft(find.byKey(firstKey)).dx - viewportLeft;
    await tester.drag(find.byType(PageView), const Offset(-280, 0));
    await tester.pumpAndSettle();
    final firstAfterScroll = tester.getTopLeft(find.byKey(firstKey)).dx;

    expect(firstInset, greaterThan(0));
    expect(firstAfterScroll, lessThan(viewportLeft));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mockup-derived atomic components compose without overflow', (
    tester,
  ) async {
    var rating = 2;
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 300,
              height: 720,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    BebeProgressSteps(
                      currentIndex: 1,
                      steps: [
                        BebeProgressStep(label: 'Datos personales'),
                        BebeProgressStep(label: 'Evaluación pediátrica'),
                        BebeProgressStep(
                          label: 'Confirmación y consentimiento',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    BebeRatingSelector(
                      label: 'Valoración de la atención',
                      value: rating,
                      onChanged: (value) => setState(() => rating = value),
                    ),
                    const SizedBox(height: 24),
                    const BebeStatePanel(
                      title: 'Registro guardado correctamente',
                      description:
                          'La información quedó disponible para todo el círculo de cuidado.',
                      variant: BebeStatePanelVariant.success,
                    ),
                    const SizedBox(height: 24),
                    BebeTimeline(
                      entries: [
                        BebeTimelineEntry(
                          timeLabel: '09:30',
                          title: 'Observación clínica con descripción extensa',
                          description:
                              'El detalle completo del evento permanece visible y la tarjeta aumenta su altura.',
                          icon: const Icon(Icons.edit_note_rounded),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('4 de 5 estrellas'));
    await tester.pump();

    expect(rating, 4);
    expect(tester.takeException(), isNull);
  });
}

const _metrics = <BebeTodayMetricData>[
  BebeTodayMetricData(
    variant: BebeMetricCardVariant.feeding,
    label: 'Alimentación durante el día',
    value: '5',
    lastLabel: 'Último registro realizado hace',
    lastValue: '2 h 10 min',
    icon: Icon(Icons.local_drink_outlined),
  ),
  BebeTodayMetricData(
    variant: BebeMetricCardVariant.sleep,
    label: 'Sueño y descanso',
    value: '3 h',
    lastLabel: 'Último registro de hoy',
    lastValue: '07:30',
    icon: Icon(Icons.bedtime_outlined),
  ),
  BebeTodayMetricData(
    variant: BebeMetricCardVariant.diaper,
    label: 'Cambios de pañal',
    value: '6',
    lastLabel: 'Último registro realizado hace',
    lastValue: '45 min',
    icon: Icon(Icons.child_friendly_outlined),
  ),
];

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.theme,
    required this.child,
    this.textScaler = TextScaler.noScaling,
  });

  final ThemeData theme;
  final Widget child;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Scaffold(
          body: Align(alignment: Alignment.topCenter, child: child),
        ),
      ),
    );
  }
}
