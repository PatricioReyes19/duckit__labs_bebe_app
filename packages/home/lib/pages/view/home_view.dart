import 'dart:async';
import 'dart:io';

import 'package:core/core.dart' show RegisterEventType;
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
  final void Function(
    BuildContext context,
    RegisterEventType? type,
  ) openTodayHistory;
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
  final void Function(
    BuildContext context,
    RegisterEventType? type,
  ) openTodayHistory;
  final HomeBabySwitcher switchBaby;
  final HomeViewClock clock;

  @override
  State<_LoadedHome> createState() => _LoadedHomeState();
}

class _LoadedHomeState extends State<_LoadedHome> {
  Timer? _reminderTimer;
  HomeVisualReminderVm? _activeReminder;
  final Set<String> _dismissedReminderIds = <String>{};
  final Set<String> _finishingSummaryIds = <String>{};
  String? _switchingBabyId;

  HomeOverviewVm get overview => widget.overview;
  void Function(BuildContext, String) get openRegister => widget.openRegister;
  void Function(BuildContext) get openAgenda => widget.openAgenda;
  void Function(BuildContext) get openHealth => widget.openHealth;
  void Function(BuildContext, RegisterEventType?) get openTodayHistory =>
      widget.openTodayHistory;

  @override
  void initState() {
    super.initState();
    _activeReminder = _resolveActiveReminder();
    _armReminderTimer();
  }

  @override
  void didUpdateWidget(covariant _LoadedHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_switchingBabyId == overview.activeBaby.id) {
      _switchingBabyId = null;
    }
    _activeReminder = _resolveActiveReminder();
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
        _activeReminder = _resolveActiveReminder();
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
    final bannerActivities = overview.activeActivities
        .where((activity) => activity.kind != HomeActiveActivityKind.sleep)
        .toList(growable: false);

    return BebeHomeTemplate(
      onRefresh: context.read<HomeBloc>().refreshFromRemote,
      activeActivities: bannerActivities.isEmpty
          ? null
          : _HomeActiveActivitiesSection(
              activities: bannerActivities,
              clock: widget.clock,
              onFinish: (activity) =>
                  context.read<HomeBloc>().finishActiveActivity(activity.id),
            ),
      visualReminder: _activeReminder == null
          ? null
          : _HomeVisualReminderBanner(
              reminder: _activeReminder!,
              onPressed: () => _openReminder(context, _activeReminder!),
              onCompleted: () => _completeReminder(_activeReminder!),
              onDismissed: () => _dismissReminder(_activeReminder!),
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
        title: 'Resumen de hoy',
        items: overview.todayMetrics
            .map((metric) => _metric(context, metric))
            .toList(growable: false),
        onHistoryPressed: () => openTodayHistory(context, null),
        contentPadding: scrollContentPadding,
      ),
      quickActions: BebeQuickRegistrationActions(
        items: overview.quickActions.map(_action).toList(growable: false),
        onItemPressed: (itemId) => openRegister(context, itemId),
        contentPadding: scrollContentPadding,
      ),
      upcomingHealth: BebeUpcomingHealthSection(
        isEmpty: !health.hasUpcomingHealth,
        titleActionLabel: health.hasUpcomingHealth ? 'Ver más' : 'Ver Salud',
        onTitleActionPressed: () => openHealth(context),
        data: BebeUpcomingHealthData(
          title: health.title,
          dateLabel: health.dateLabel,
          timeLabel: health.timeLabel,
          caregiverLabel:
              health.caregiverLabel.isEmpty ? null : health.caregiverLabel,
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
    if (!mounted ||
        !context.mounted ||
        selectedId == null ||
        selectedId == active.id) {
      return;
    }
    await _switchBaby(context, selectedId);
  }

  Future<void> _switchBaby(BuildContext context, String babyId) async {
    if (_switchingBabyId != null || babyId == overview.activeBaby.id) return;
    setState(() => _switchingBabyId = babyId);
    try {
      await widget.switchBaby(babyId);
      if (!mounted || !context.mounted) return;
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
      if (!mounted ||
          !context.mounted ||
          context.read<HomeBloc>().state is! HomeFailure) {
        return;
      }
      throw StateError('No se pudieron cargar los datos del bebé.');
    } on Object {
      if (mounted && context.mounted) {
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
        openRegister(context, 'medication');
    }
  }

  HomeVisualReminderVm? _resolveActiveReminder() {
    return HomeVisualReminderVm.activeAt(
      overview.visualReminders.where(
        (reminder) => !_dismissedReminderIds.contains(reminder.id),
      ),
      widget.clock(),
    );
  }

  void _completeReminder(HomeVisualReminderVm reminder) {
    setState(() {
      _dismissedReminderIds.add(reminder.id);
      _activeReminder = _resolveActiveReminder();
    });
    _openReminder(context, reminder);
  }

  void _dismissReminder(HomeVisualReminderVm reminder) {
    setState(() {
      _dismissedReminderIds.add(reminder.id);
      _activeReminder = _resolveActiveReminder();
    });
    BebeInAppSnackbar.show(
      context,
      title: 'Recordatorio ocultado',
      message: 'No volveremos a mostrar este aviso en Home.',
      variant: BebeInAppSnackbarVariant.information,
    );
  }

  BebeTodayMetricData _metric(
    BuildContext context,
    HomeTodayMetricVm metric,
  ) {
    final activeEventId = metric.activeEventId;
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
      onPressed: activeEventId == null
          ? () => openTodayHistory(context, _registerType(metric.type))
          : null,
      actionLabel: activeEventId == null ? null : 'Detener',
      isActionLoading:
          activeEventId != null && _finishingSummaryIds.contains(activeEventId),
      onActionPressed: activeEventId == null
          ? null
          : () => _finishSummaryActivity(activeEventId),
    );
  }

  Future<void> _finishSummaryActivity(String eventId) async {
    if (_finishingSummaryIds.contains(eventId)) return;
    setState(() => _finishingSummaryIds.add(eventId));
    try {
      final finished = await context.read<HomeBloc>().finishActiveActivity(
            eventId,
          );
      if (!mounted) return;
      if (!finished) {
        BebeInAppSnackbar.show(
          context,
          title: 'El sueño ya cambió',
          message: 'Actualizamos Home con el estado más reciente.',
          variant: BebeInAppSnackbarVariant.information,
        );
      }
    } on Object {
      if (!mounted) return;
      BebeInAppSnackbar.show(
        context,
        title: 'No se pudo detener el sueño',
        message: 'El registro sigue en curso. Intenta nuevamente.',
        variant: BebeInAppSnackbarVariant.error,
      );
    } finally {
      if (mounted) setState(() => _finishingSummaryIds.remove(eventId));
    }
  }

  static RegisterEventType _registerType(HomeMetricType type) => switch (type) {
        HomeMetricType.feeding => RegisterEventType.feeding,
        HomeMetricType.sleep => RegisterEventType.sleep,
        HomeMetricType.diaper => RegisterEventType.diaper,
      };

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

class _HomeActiveActivitiesSection extends StatefulWidget {
  const _HomeActiveActivitiesSection({
    required this.activities,
    required this.clock,
    required this.onFinish,
  });

  final List<HomeActiveActivityVm> activities;
  final HomeViewClock clock;
  final Future<bool> Function(HomeActiveActivityVm activity) onFinish;

  @override
  State<_HomeActiveActivitiesSection> createState() =>
      _HomeActiveActivitiesSectionState();
}

class _HomeActiveActivitiesSectionState
    extends State<_HomeActiveActivitiesSection> {
  Timer? _durationTimer;
  final Set<String> _finishingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _durationTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      key: const ValueKey('home-active-activities'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ACTIVIDAD EN CURSO',
          style: theme.typography.styles.label.lg.semibold.copyWith(
            color: theme.colors.text.neutralTitle,
          ),
        ),
        SizedBox(height: theme.spacing.spacingM),
        for (var index = 0; index < widget.activities.length; index++) ...[
          _activityCard(context, widget.activities[index]),
          if (index != widget.activities.length - 1)
            SizedBox(height: theme.spacing.spacingM),
        ],
      ],
    );
  }

  Widget _activityCard(
    BuildContext context,
    HomeActiveActivityVm activity,
  ) {
    final finishing = _finishingIds.contains(activity.id);
    return BebeStatusBanner(
      key: ValueKey('home-active-${activity.id}'),
      title: activity.title,
      description: '${_startedLabel(activity.startedAt, widget.clock())}\n'
          '${_durationLabel(widget.clock().difference(activity.startedAt))}',
      type: BebeStatusBannerType.information,
      leading: Icon(_activityIcon(activity.kind)),
      semanticLabel:
          '${activity.title}. ${_durationLabel(widget.clock().difference(activity.startedAt))}',
      footer: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          key: ValueKey('finish-active-${activity.id}'),
          onPressed: finishing ? null : () => _finish(activity),
          icon: finishing
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.stop_circle_outlined),
          label: Text(finishing ? 'Finalizando…' : activity.actionLabel),
        ),
      ),
    );
  }

  Future<void> _finish(HomeActiveActivityVm activity) async {
    setState(() => _finishingIds.add(activity.id));
    try {
      final finished = await widget.onFinish(activity);
      if (!mounted) return;
      if (finished) {
        BebeInAppSnackbar.show(
          context,
          title: 'Actividad finalizada',
          message: 'La duración quedó guardada en el registro original.',
          variant: BebeInAppSnackbarVariant.success,
        );
      } else {
        BebeInAppSnackbar.show(
          context,
          title: 'La actividad ya cambió',
          message: 'Actualizamos Home con el estado más reciente.',
          variant: BebeInAppSnackbarVariant.information,
        );
      }
    } on Object {
      if (!mounted) return;
      BebeInAppSnackbar.show(
        context,
        title: 'No se pudo finalizar',
        message: 'El registro sigue en curso. Intenta nuevamente.',
        variant: BebeInAppSnackbarVariant.error,
      );
    } finally {
      if (mounted) setState(() => _finishingIds.remove(activity.id));
    }
  }

  static String _startedLabel(DateTime startedAt, DateTime now) {
    final start = startedAt.toLocal();
    final today = now.toLocal();
    final time = '${start.hour.toString().padLeft(2, '0')}:'
        '${start.minute.toString().padLeft(2, '0')}';
    if (start.year == today.year &&
        start.month == today.month &&
        start.day == today.day) {
      return 'Iniciado a las $time';
    }
    return 'Iniciado el ${start.day.toString().padLeft(2, '0')}/'
        '${start.month.toString().padLeft(2, '0')} a las $time';
  }

  static String _durationLabel(Duration elapsed) {
    final minutes = elapsed.isNegative ? 0 : elapsed.inMinutes;
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '$remainder min';
    return remainder == 0 ? '$hours h' : '$hours h $remainder min';
  }

  static IconData _activityIcon(HomeActiveActivityKind kind) => switch (kind) {
        HomeActiveActivityKind.feeding => LucideIcons.milk,
        HomeActiveActivityKind.sleep => LucideIcons.moon,
        HomeActiveActivityKind.diaper => LucideIcons.baby,
        HomeActiveActivityKind.observation => Icons.edit_outlined,
        HomeActiveActivityKind.medication => Icons.medication_outlined,
        HomeActiveActivityKind.measurement => Icons.straighten_outlined,
      };
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
    required this.onCompleted,
    required this.onDismissed,
  });

  final HomeVisualReminderVm reminder;
  final VoidCallback onPressed;
  final VoidCallback onCompleted;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final time = reminder.startsAt;
    final timeLabel = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    return BebeCareReminderBanner(
      key: const ValueKey('home-visual-reminder'),
      title: reminder.title,
      description: reminder.detail,
      timeLabel: timeLabel,
      variant: switch (reminder.kind) {
        HomeVisualReminderKind.feeding ||
        HomeVisualReminderKind.bottle ||
        HomeVisualReminderKind.formula =>
          BebeCareReminderBannerVariant.feeding,
        HomeVisualReminderKind.diaper => BebeCareReminderBannerVariant.diaper,
        HomeVisualReminderKind.medication =>
          BebeCareReminderBannerVariant.medication,
      },
      onPressed: onPressed,
      onCompleted: onCompleted,
      onDismissed: onDismissed,
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
    return BebeStatusBanner(
      key: const ValueKey('home-first-steps'),
      title: 'Comienza los registros de $babyName',
      description:
          'Alimentación, sueño y pañales aparecerán en el resumen del día.',
      type: BebeStatusBannerType.information,
      leading: const Icon(Icons.auto_awesome_outlined),
      footer: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onRegisterPressed,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Registrar primer cuidado'),
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
