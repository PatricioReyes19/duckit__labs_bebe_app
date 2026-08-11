import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home/home.dart';
import 'package:home/models/home_overview_vm.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    required this.openRegister,
    required this.openAgenda,
    required this.openHealth,
    required this.openTodayHistory,
    super.key,
  });

  final void Function(BuildContext context, String actionId) openRegister;
  final void Function(BuildContext context) openAgenda;
  final void Function(BuildContext context) openHealth;
  final void Function(BuildContext context) openTodayHistory;

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
            ),
        };
      },
    );
  }
}

class _LoadedHome extends StatelessWidget {
  const _LoadedHome({
    required this.overview,
    required this.openRegister,
    required this.openAgenda,
    required this.openHealth,
    required this.openTodayHistory,
  });

  final HomeOverviewVm overview;
  final void Function(BuildContext context, String actionId) openRegister;
  final void Function(BuildContext context) openAgenda;
  final void Function(BuildContext context) openHealth;
  final void Function(BuildContext context) openTodayHistory;

  @override
  Widget build(BuildContext context) {
    final baby = overview.activeBaby;
    final health = overview.upcomingHealth;
    final recent = overview.recentInformation;

    return BebeHomeTemplate(
      onRefresh: () async {
        final bloc = context.read<HomeBloc>();
        final completed = bloc.stream.firstWhere(
          (state) => state is HomeLoaded || state is HomeFailure,
        );
        bloc.add(const HomeEvent.refreshed());
        await completed;
      },
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
        siblings: baby.sibling == null
            ? []
            : [
                BebeSiblingSummaryData(
                  name: baby.sibling!.name,
                  ageLabel: baby.sibling!.ageLabel,
                  avatar: _babyImage(baby.sibling!.avatarAssetPath),
                )
              ],
      ),
      todaySummary: BebeTodaySummary(
        title: 'Actividad del día',
        items: overview.todayMetrics.map(_metric).toList(growable: false),
        onHistoryPressed: () => openTodayHistory(context),
      ),
      quickActions: BebeQuickRegistrationActions(
        items: overview.quickActions.map(_action).toList(growable: false),
        onItemPressed: (itemId) => openRegister(context, itemId),
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
