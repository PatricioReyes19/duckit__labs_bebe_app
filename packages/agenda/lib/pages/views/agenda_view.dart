import 'package:agenda/agenda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaView extends StatelessWidget {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgendaBloc, AgendaState>(
      builder: (context, state) {
        return switch (state) {
          AgendaInitial() ||
          AgendaLoading() => const Center(child: CircularProgressIndicator()),
          AgendaFailure(:final message) => Center(child: Text(message)),
          AgendaLoaded() => const _AgendaDesignSystemBoundary(),
        };
      },
    );
  }
}

/// Punto de integración con el template definitivo de Agenda.
///
/// Se importa design_system desde ahora, pero no se inventa una firma de
/// template que todavía no fue compartida. Sustituir el contenido por el
/// template real cuando se cierre su API.
class _AgendaDesignSystemBoundary extends StatelessWidget {
  const _AgendaDesignSystemBoundary();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
