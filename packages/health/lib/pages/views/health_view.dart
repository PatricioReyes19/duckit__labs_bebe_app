import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';

class HealthView extends StatelessWidget {
  const HealthView({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<HealthBloc, HealthState>(
    builder: (context, state) => switch (state) {
      HealthInitial() ||
      HealthLoading() => const Center(child: CircularProgressIndicator()),
      HealthFailure(:final message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    context.read<HealthBloc>().add(const HealthRetried()),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      HealthLoaded() => const _HealthLoadedContent(),
    },
  );
}

class _HealthLoadedContent extends StatelessWidget {
  const _HealthLoadedContent();
  @override
  Widget build(BuildContext context) {
    /* TODO(health): reemplazar por BebeHealthOverviewTemplate. */
    return const SizedBox.expand(child: Center(child: Text('Salud')));
  }
}
