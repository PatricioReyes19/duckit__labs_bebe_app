import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:home/models/home_overview_vm.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState.initial()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
    on<_Retried>(_onRetried);
  }

  Future<void> _onStarted(
    _Started event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeState.loading());
    await _loadMockOverview(emit);
  }

  Future<void> _onRefreshed(
    _Refreshed event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;

    if (currentState is HomeLoaded) {
      emit(
        currentState.copyWith(
          isRefreshing: true,
        ),
      );
    }

    await _loadMockOverview(emit);
  }

  Future<void> _onRetried(
    _Retried event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeState.loading());
    await _loadMockOverview(emit);
  }

  Future<void> _loadMockOverview(
    Emitter<HomeState> emit,
  ) async {
    // Simula la espera de una fuente de datos.
    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );

    emit(
      HomeState.loaded(
        overview: _buildMockOverview(),
      ),
    );
  }

  HomeOverviewVm _buildMockOverview() {
    return const HomeOverviewVm(
      activeBaby: HomeActiveBabyVm(
        name: 'Franco Reyes',
        ageLabel: '1 meses y 8 días',
        avatarAssetPath: 'assets/images/baby_avatar.png',
        familyContextLabel: 'Familia Reyes',
      ),
      todayMetrics: [
        HomeTodayMetricVm(
          type: HomeMetricType.feeding,
          label: 'Alimentación',
          value: '6',
          unit: 'tomas',
          lastLabel: 'Última vez',
          lastValue: 'Hace 35 min',
        ),
        HomeTodayMetricVm(
          type: HomeMetricType.sleep,
          label: 'Sueño',
          value: '8 h',
          unit: 'total',
          lastLabel: 'Última vez',
          lastValue: 'Hace 1 h',
        ),
        HomeTodayMetricVm(
          type: HomeMetricType.diaper,
          label: 'Pañales',
          value: '5',
          unit: 'cambios',
          lastLabel: 'Última vez',
          lastValue: 'Hace 20 min',
        ),
      ],
      quickActions: [
        HomeQuickActionVm(
          id: 'feeding',
          type: HomeQuickActionKind.feeding,
          label: 'Alimentación',
        ),
        HomeQuickActionVm(
          id: 'sleep',
          type: HomeQuickActionKind.sleep,
          label: 'Sueño',
        ),
        HomeQuickActionVm(
          id: 'diaper',
          type: HomeQuickActionKind.diaper,
          label: 'Cambio',
        ),
        HomeQuickActionVm(
          id: 'observation',
          type: HomeQuickActionKind.observation,
          label: 'Observación',
        ),
        HomeQuickActionVm(
          id: 'medicine',
          type: HomeQuickActionKind.medicine,
          label: 'Medicina',
        ),
      ],
      upcomingHealth: HomeUpcomingHealthVm(
        title: 'Control de los 2 meses',
        dateLabel: 'Miércoles 5 de agosto',
        timeLabel: '10:30',
        caregiverLabel: 'Acompaña: Papá',
        type: HomeUpcomingHealthKind.control,
      ),
      recentInformation: HomeRecentInformationVm(
        title: 'Vacuna registrada',
        dateLabel: 'Hoy, 09:40',
        description: 'Se registró la vacuna correspondiente a los 2 meses.',
        status: HomeRecentStatus.success,
        statusLabel: 'Completado',
      ),
    );
  }
}
