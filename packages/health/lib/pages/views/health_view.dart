import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';

class HealthView extends StatelessWidget {
  const HealthView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      builder: (context, state) {
        return switch (state) {
          HealthInitial() || HealthLoading() => const _HealthLoading(),
          HealthFailure(:final message) => _HealthError(message: message),
          HealthLoaded() => const _HealthLoaded(),
        };
      },
    );
  }
}

class _HealthLoading extends StatelessWidget {
  const _HealthLoading();

  @override
  Widget build(BuildContext context) {
    return BebeHealthOverviewTemplate(
      primaryActions: const SizedBox.shrink(),
      supportAction: const SizedBox.shrink(),
      quickSummary: const SizedBox.shrink(),
      historyAction: const SizedBox.shrink(),
      upcomingHeader: SizedBox.shrink(),
      upcomingCarousel: SizedBox.shrink(),
    );
  }
}

class _HealthError extends StatelessWidget {
  const _HealthError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _HealthLoaded extends StatelessWidget {
  const _HealthLoaded();

  @override
  Widget build(BuildContext context) {
    return BebeHealthOverviewTemplate(
      primaryActions: const SizedBox.shrink(),
      supportAction: const SizedBox.shrink(),
      quickSummary: const SizedBox.shrink(),
      historyAction: const SizedBox.shrink(),
      upcomingHeader: SizedBox.shrink(),
      upcomingCarousel: SizedBox.shrink(),
    );
  }
}
