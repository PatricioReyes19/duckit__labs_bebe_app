import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/models/health_flow_controller.dart';

class HealthFlowState {
  const HealthFlowState({
    required this.revision,
    required this.isLoading,
    this.error,
  });

  factory HealthFlowState.fromController(
    HealthFlowController controller, {
    int revision = 0,
  }) => HealthFlowState(
    revision: revision,
    isLoading: controller.isLoading,
    error: controller.error,
  );

  final int revision;
  final bool isLoading;
  final Object? error;
}

/// BLoC de presentación para los recorridos secundarios de Salud.
///
/// El controller conserva la coordinación de casos de uso y repositorios; el
/// BLoC transforma sus cambios en estados consumibles por las vistas.
class HealthFlowBloc extends Cubit<HealthFlowState> {
  HealthFlowBloc(this.controller)
    : super(HealthFlowState.fromController(controller)) {
    controller.addListener(_controllerChanged);
  }

  final HealthFlowController controller;

  Future<void> load({bool force = false}) => controller.load(force: force);

  void _controllerChanged() => emit(
    HealthFlowState.fromController(controller, revision: state.revision + 1),
  );

  @override
  Future<void> close() {
    controller.removeListener(_controllerChanged);
    return super.close();
  }
}
