import 'package:agenda/agenda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaView extends StatelessWidget {
  const AgendaView({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<AgendaBloc, AgendaState>(
    builder: (context, state) => switch (state) {
      AgendaInitial() ||
      AgendaLoading() => const Center(child: CircularProgressIndicator()),
      AgendaFailure(:final message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    context.read<AgendaBloc>().add(const AgendaRetried()),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      AgendaLoaded() => const _AgendaLoadedContent(),
    },
  );
}

class _AgendaLoadedContent extends StatelessWidget {
  const _AgendaLoadedContent();
  @override
  Widget build(BuildContext context) {
    /* TODO(agenda): reemplazar por el template de Agenda. */
    return const SizedBox.expand(child: Center(child: Text('Agenda')));
  }
}
