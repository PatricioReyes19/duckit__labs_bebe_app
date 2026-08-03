import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FamilyView extends StatelessWidget {
  const FamilyView({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<FamilyBloc, FamilyState>(
    builder: (context, state) => switch (state) {
      FamilyInitial() ||
      FamilyLoading() => const Center(child: CircularProgressIndicator()),
      FamilyFailure(:final message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    context.read<FamilyBloc>().add(const FamilyRetried()),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      FamilyLoaded() => const _FamilyLoadedContent(),
    },
  );
}

class _FamilyLoadedContent extends StatelessWidget {
  const _FamilyLoadedContent();
  @override
  Widget build(BuildContext context) {
    /* TODO(family): reemplazar por BebeFamilyOverviewTemplate. */
    return const SizedBox.expand(child: Center(child: Text('Familia')));
  }
}
