import 'dart:async';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home/home.dart';
import 'package:home/models/home_overview_vm.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

typedef HomeViewClock = DateTime Function();

class HomeView extends StatelessWidget {
  const HomeView({
    required this.openRegister,
    required this.openAgenda,
    required this.openHealth,
    required this.openTodayHistory,
    required this.switchBaby,
    this.clock,
    super.key,
  });

  final void Function(BuildContext context, String actionId) openRegister;
  final void Function(BuildContext context) openAgenda;
  final void Function(BuildContext context) openHealth;
  final void Function(BuildContext context) openTodayHistory;
  final HomeBabySwitcher switchBaby;
  final HomeViewClock? clock;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return switch (state) {
          HomeInitial() || HomeLoading() => const BebeHomeTemplate(
              isLoading: true,
              activeBabyHeader: SizedBox.shrink(),
              todaySummary: SizedBox.shrink(),
              quickActions: SizedBox.shrink(),
              upcomingHealth: SizedBox.shrink(),
              recentInformation: SizedBox.shrink(),
            ),
          HomeFailure(:final message) => BebeHomeTemplate(
              errorMessage: message,
              onRetry: () {
                context.read<HomeBloc>().add(const HomeEvent.retried());
              },
              activeBabyHeader: const SizedBox.shrink(),
              todaySummary: const SizedBox.shrink(),
              quickActions: const SizedBox.shrink(),
              upcomingHealth: const SizedBox.shrink(),
              recentInformation: const SizedBox.shrink(),
            ),
          HomeLoaded(:final overview) => _LoadedHome(
              overview: overview,
              openRegister: openRegister,
              openAgenda: openAgenda,
              openHealth: openHealth,
              openTodayHistory: openTodayHistory,
              switchBaby: switchBaby,
              clock: clock ?? DateTime.now,
            ),
        };
      },
    );
  }
}

class _LoadedHome extends StatefulWidget {
  const _LoadedHome({
    required this.overview,
    required this.openRegister,
    required this.openAgenda,
    required this.openHealth,
    required this.openTodayHistory,
    required this.switchBaby,
    required this.clock,
  });

  final HomeOverviewVm overview;
  final void Function(BuildContext context, String actionId) openRegister;
  final void Function(BuildContext context) openAgenda;
  final void Function(BuildContext context) openHealth;
  final void Function(BuildContext context) openTodayHistory;
  final HomeBabySwitcher switchBaby;
  final HomeViewClock clock;

  @override
  State<_LoadedHome> createState() => _LoadedHomeState();
}

class _LoadedHomeState extends State<_LoadedHome> {
  Timer? _reminderTimer;
  HomeVisualReminderVm? _activeReminder;
  String? _switchingBabyId;

  HomeOverviewVm get overview => widget.overview;
  void Function(BuildContext, String) get openRegister => widget.openRegister;
  void Function(BuildContext) get openAgenda => widget.openAgenda;
  void Function(BuildContext) get openHealth => widget.openHealth;
  void Function(BuildContext) get openTodayHistory => widget.openTodayHistory;

  @override
  void initState() {
    super.initState();
    _activeReminder = HomeVisualReminderVm.activeAt(
      overview.visualReminders,
      widget.clock(),
    );
    _armReminderTimer();
  }

  @override
  void didUpdateWidget(covariant _LoadedHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_switchingBabyId == overview.activeBaby.id) {
      _switchingBabyId = null;
    }
    _activeReminder = HomeVisualReminderVm.activeAt(
      overview.visualReminders,
      widget.clock(),
    );
    _armReminderTimer();
  }

  void _armReminderTimer() {
    _reminderTimer?.cancel();
    final now = widget.clock();
    final transition = HomeVisualReminderVm.nextTransitionAt(
      overview.visualReminders,
      now,
    );
    if (transition == null) return;
    final delay = transition.difference(now) + const Duration(milliseconds: 50);
    _reminderTimer = Timer(delay, () {
      if (!mounted) return;
      setState(() {
        _activeReminder = HomeVisualReminderVm.activeAt(
          overview.visualReminders,
          widget.clock(),
        );
      });
      _armReminderTimer();
    });
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baby = overview.activeBaby;
    final health = overview.upcomingHealth;
    final recent = overview.recentInformation;
    final scrollContentPadding = EdgeInsets.symmetric(
      horizontal: context.theme.spacing.spacing2xl,
    );

    return BebeHomeTemplate(
      onRefresh: context.read<HomeBloc>().refreshFromRemote,
      visualReminder: _activeReminder == null
          ? null
          : _HomeVisualReminderBanner(
              reminder: _activeReminder!,
              onPressed: () => _openReminder(context, _activeReminder!),
            ),
      isEmpty: !overview.hasCareData,
      emptyState: _HomeFirstSteps(
        babyName: baby.name,
        onRegisterPressed: () => openRegister(context, 'feeding'),
      ),
      activeBabyHeader: BebeActiveBabyHeader(
        name: baby.name,
        ageLabel: baby.ageLabel,
        avatar: _babyImage(baby.avatarAssetPath),
        familyContextLabel: baby.familyContextLabel,
        siblings: baby.siblings
            .map(
              (sibling) => BebeSiblingSummaryData(
                id: sibling.id,
                name: sibling.name,
                ageLabel: sibling.ageLabel,
                avatar: _babyImage(sibling.avatarAssetPath),
              ),
            )
            .toList(growable: false),
        switchingBabyId: _switchingBabyId,
        onBabyPressed:
            _switchingBabyId == null ? () => _openBabyPicker(context) : null,
        onSiblingPressed: _switchingBabyId == null
            ? (sibling) => _switchBaby(context, sibling.id)
            : null,
      ),
      todaySummary: BebeTodaySummary(
        title: 'Actividad del día',
        items: overview.todayMetrics.map(_metric).toList(growable: false),
        onHistoryPressed: () => openTodayHistory(context),
        contentPadding: scrollContentPadding,
      ),
      quickActions: BebeQuickRegistrationActions(
        items: overview.quickActions.map(_action).toList(growable: false),
        onItemPressed: (itemId) => openRegister(context, itemId),
        contentPadding: scrollContentPadding,
      ),
      upcomingHealth: BebeUpcomingHealthSection(
        data: BebeUpcomingHealthData(
          title: health.title,
          dateLabel: health.dateLabel,
          timeLabel: health.timeLabel,
          caregiverLabel: health.caregiverLabel,
          type: switch (health.type) {
            HomeUpcomingHealthKind.control => BebeUpcomingHealthType.control,
            HomeUpcomingHealthKind.vaccine => BebeUpcomingHealthType.vaccine,
            HomeUpcomingHealthKind.medicine => BebeUpcomingHealthType.vaccine,
          },
          icon: switch (health.type) {
            HomeUpcomingHealthKind.control =>
              const Icon(Icons.medical_services_outlined),
            HomeUpcomingHealthKind.vaccine =>
              const Icon(Icons.vaccines_outlined),
            HomeUpcomingHealthKind.medicine =>
              const Icon(Icons.medication_outlined),
          },
        ),
        onCardPressed: () => openHealth(context),
        onViewAgendaPressed: () => openAgenda(context),
        onOpenHealthPressed: () => openHealth(context),
      ),
      recentInformation: BebeRecentInformationSection(
        data: BebeRecentInformationData(
          title: recent.title,
          dateLabel: recent.dateLabel,
          description: recent.description,
          status: switch (recent.status) {
            HomeRecentStatus.success => BebeRecentInformationStatus.success,
            HomeRecentStatus.warning => BebeRecentInformationStatus.warning,
            HomeRecentStatus.information =>
              BebeRecentInformationStatus.information,
          },
          statusLabel: recent.statusLabel,
          icon: switch (recent.status) {
            HomeRecentStatus.success =>
              const Icon(Icons.assignment_turned_in_outlined),
            HomeRecentStatus.warning => const Icon(Icons.warning_amber_rounded),
            HomeRecentStatus.information =>
              const Icon(Icons.info_outline_rounded),
          },
        ),
        onPressed: () => openHealth(context),
      ),
    );
  }

  Future<void> _openBabyPicker(BuildContext context) async {
    final active = overview.activeBaby;
    final choices = <_HomeBabyChoice>[
      _HomeBabyChoice(
        id: active.id,
        name: active.name,
        ageLabel: active.ageLabel,
        avatarAssetPath: active.avatarAssetPath,
      ),
      for (final sibling in active.siblings)
        _HomeBabyChoice(
          id: sibling.id,
          name: sibling.name,
          ageLabel: sibling.ageLabel,
          avatarAssetPath: sibling.avatarAssetPath,
        ),
    ];
    final selectedId = await showBebeBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      variant: BebeBottomSheetVariant.dynamic,
      semanticLabel: 'Seleccionar bebé activo',
      headerBuilder: (_) => const BebeTitleSection(title: 'Cambiar bebé'),
      bodyBuilder: (sheetContext) => _HomeBabyPicker(
        choices: choices,
        activeBabyId: active.id,
        onSelected: (babyId) => Navigator.of(sheetContext).pop(babyId),
      ),
    );
    if (!mounted || selectedId == null || selectedId == active.id) return;
    await _switchBaby(context, selectedId);
  }

  Future<void> _switchBaby(BuildContext context, String babyId) async {
    if (_switchingBabyId != null || babyId == overview.activeBaby.id) return;
    setState(() => _switchingBabyId = babyId);
    try {
      await widget.switchBaby(babyId);
      if (!mounted) return;
      final bloc = context.read<HomeBloc>();
      final current = bloc.state;
      if (current is! HomeLoaded || current.overview.activeBaby.id != babyId) {
        await bloc.stream
            .firstWhere(
              (state) =>
                  state is HomeFailure ||
                  state is HomeLoaded && state.overview.activeBaby.id == babyId,
            )
            .timeout(const Duration(seconds: 5));
      }
      if (!mounted || context.read<HomeBloc>().state is! HomeFailure) return;
      throw StateError('No se pudieron cargar los datos del bebé.');
    } on Object {
      if (mounted) {
        BebeInAppSnackbar.show(
          context,
          title: 'No pudimos cambiar de bebé',
          message: 'Intenta nuevamente. Tus datos actuales siguen seguros.',
          variant: BebeInAppSnackbarVariant.error,
        );
      }
    } finally {
      if (mounted && _switchingBabyId != null) {
        setState(() => _switchingBabyId = null);
      }
    }
  }

  void _openReminder(BuildContext context, HomeVisualReminderVm reminder) {
    switch (reminder.kind) {
      case HomeVisualReminderKind.feeding:
      case HomeVisualReminderKind.bottle:
      case HomeVisualReminderKind.formula:
        openRegister(context, 'feeding');
      case HomeVisualReminderKind.diaper:
        openRegister(context, 'diaper');
      case HomeVisualReminderKind.medication:
        openAgenda(context);
    }
  }

  BebeTodayMetricData _metric(HomeTodayMetricVm metric) {
    return BebeTodayMetricData(
      variant: switch (metric.type) {
        HomeMetricType.feeding => BebeMetricCardVariant.feeding,
        HomeMetricType.sleep => BebeMetricCardVariant.sleep,
        HomeMetricType.diaper => BebeMetricCardVariant.diaper,
      },
      label: metric.label,
      value: metric.value,
      unit: metric.unit,
      lastLabel: metric.lastLabel,
      lastValue: metric.lastValue,
      icon: switch (metric.type) {
        HomeMetricType.feeding => const Icon(LucideIcons.milk),
        HomeMetricType.sleep => const Icon(LucideIcons.moon),
        HomeMetricType.diaper => const Icon(LucideIcons.baby),
      },
    );
  }

  BebeQuickActionData _action(HomeQuickActionVm action) {
    return BebeQuickActionData(
      id: action.id,
      type: switch (action.type) {
        HomeQuickActionKind.feeding => BebeQuickActionType.feeding,
        HomeQuickActionKind.sleep => BebeQuickActionType.sleep,
        HomeQuickActionKind.diaper => BebeQuickActionType.diaper,
        HomeQuickActionKind.observation => BebeQuickActionType.observation,
        HomeQuickActionKind.medicine => BebeQuickActionType.medicine,
      },
      label: action.label,
      icon: switch (action.type) {
        HomeQuickActionKind.feeding => const Icon(LucideIcons.milk),
        HomeQuickActionKind.sleep => const Icon(LucideIcons.moon),
        HomeQuickActionKind.diaper => const Icon(LucideIcons.baby),
        HomeQuickActionKind.observation => const Icon(Icons.edit_outlined),
        HomeQuickActionKind.medicine => const Icon(Icons.medication_outlined),
      },
    );
  }
}

class _HomeBabyChoice {
  const _HomeBabyChoice({
    required this.id,
    required this.name,
    required this.ageLabel,
    required this.avatarAssetPath,
  });

  final String id;
  final String name;
  final String ageLabel;
  final String? avatarAssetPath;
}

class _HomeBabyPicker extends StatelessWidget {
  const _HomeBabyPicker({
    required this.choices,
    required this.activeBabyId,
    required this.onSelected,
  });

  final List<_HomeBabyChoice> choices;
  final String activeBabyId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < choices.length; index++) ...[
          BebeBabySelector(
            key: ValueKey('home-baby-choice-${choices[index].id}'),
            name: choices[index].name,
            ageLabel: choices[index].ageLabel,
            avatar: BebeAvatar.image(
              image: _babyImage(choices[index].avatarAssetPath),
              size: BebeAvatarSize.lg,
              semanticLabel: 'Foto de ${choices[index].name}',
            ),
            contextLabel: choices[index].id == activeBabyId
                ? 'Perfil activo'
                : 'Cambiar a este perfil',
            isSelected: choices[index].id == activeBabyId,
            onPressed: () => onSelected(choices[index].id),
          ),
          if (index != choices.length - 1) SizedBox(height: spacing.spacingM),
        ],
      ],
    );
  }
}

class _HomeVisualReminderBanner extends StatelessWidget {
  const _HomeVisualReminderBanner({
    required this.reminder,
    required this.onPressed,
  });

  final HomeVisualReminderVm reminder;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final time = reminder.startsAt;
    final timeLabel = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    return BebeStatusBanner(
      key: const ValueKey('home-visual-reminder'),
      title: reminder.title,
      description: '${reminder.detail} · Programado a las $timeLabel',
      type: BebeStatusBannerType.warning,
      leading: Icon(
        switch (reminder.kind) {
          HomeVisualReminderKind.feeding ||
          HomeVisualReminderKind.bottle ||
          HomeVisualReminderKind.formula =>
            LucideIcons.milk,
          HomeVisualReminderKind.diaper => LucideIcons.baby,
          HomeVisualReminderKind.medication => Icons.medication_outlined,
        },
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onPressed: onPressed,
      semanticLabel: '${reminder.title}. ${reminder.detail}. '
          'Programado a las $timeLabel.',
    );
  }
}

class _HomeFirstSteps extends StatelessWidget {
  const _HomeFirstSteps({
    required this.babyName,
    required this.onRegisterPressed,
  });

  final String babyName;
  final VoidCallback onRegisterPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background.neutralsSurface,
        borderRadius: BorderRadius.circular(theme.borderRadius.radius3xl),
        border: Border.all(color: theme.colors.border.neutralDefault),
        boxShadow: theme.elevation.low,
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.spacingXl),
        child: Column(
          children: [
            Image.asset(
              BebeIllustrationAssets.emptyHome,
              package: BebeIllustrationAssets.packageName,
              height: 190,
              fit: BoxFit.contain,
              semanticLabel:
                  'Elefante bebé con mamadera para comenzar los registros',
            ),
            SizedBox(height: theme.spacing.spacingL),
            Text(
              'Aún no hay registros de $babyName',
              textAlign: TextAlign.center,
              style: theme.typography.styles.title.md.semibold.copyWith(
                color: theme.colors.text.neutralTitle,
              ),
            ),
            SizedBox(height: theme.spacing.spacingS),
            Text(
              'Cada cuidado cuenta. Empieza con su primera alimentación, sueño o cambio de pañal.',
              textAlign: TextAlign.center,
              style: theme.typography.styles.body.md.regular.copyWith(
                color: theme.colors.text.neutralBody,
              ),
            ),
            SizedBox(height: theme.spacing.spacingXl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRegisterPressed,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Registrar primer cuidado'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ImageProvider _babyImage(String? path) {
  if (path != null && path.isNotEmpty) {
    final file = File(path);
    if (file.existsSync()) return FileImage(file);
    return AssetImage(path);
  }
  return AssetImage(
    BebeBrandAssets.pathFor(BebeBrandMarkVariant.master),
    package: BebeBrandAssets.packageName,
  );
}
