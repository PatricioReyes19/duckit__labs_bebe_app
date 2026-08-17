import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home/home.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  test('UT-HOME-REFRESH-001 hydrated refresh never emits full loading',
      () async {
    final getHomeOverview = _MockGetHomeOverview();
    final finishActiveRegisterEvent = _MockFinishActiveRegisterEvent();
    final changes = StreamController<void>.broadcast();
    addTearDown(changes.close);

    when(() => getHomeOverview.changes).thenAnswer((_) => changes.stream);
    when(getHomeOverview.call).thenAnswer((_) async => _overview());

    final bloc = HomeBloc(
      getHomeOverview: getHomeOverview,
      finishActiveRegisterEvent: finishActiveRegisterEvent,
      clock: () => DateTime(2026, 8, 17, 12),
    );
    addTearDown(bloc.close);

    final firstLoad = bloc.stream.firstWhere((state) => state is HomeLoaded);
    bloc.add(const HomeEvent.started());
    await firstLoad;

    final refreshStates = <HomeState>[];
    final subscription = bloc.stream.listen(refreshStates.add);
    addTearDown(subscription.cancel);
    final refreshed = bloc.stream.firstWhere(
      (state) => state is HomeLoaded && !state.isRefreshing,
    );
    changes.add(null);
    await refreshed;

    expect(refreshStates.whereType<HomeLoading>(), isEmpty);
    expect(
      refreshStates.whereType<HomeLoaded>().any((state) => state.isRefreshing),
      isTrue,
    );
  });
}

HomeOverviewEntity _overview() {
  final baby = BabyEntity(
    id: 'baby-1',
    familyId: 'family-1',
    name: 'Mateo',
    birthDate: DateTime(2026, 6, 17),
  );
  return HomeOverviewEntity(
    family: FamilyOverviewEntity(
      id: 'family-1',
      name: 'Familia Mateo',
      activeBabyId: baby.id,
      babies: [baby],
      members: const [],
    ),
    activeBaby: baby,
    metrics: const [
      HomeMetricEntity(
        type: HomeMetricType.feeding,
        count: 0,
        totalMinutes: 0,
      ),
      HomeMetricEntity(
        type: HomeMetricType.sleep,
        count: 0,
        totalMinutes: 0,
      ),
      HomeMetricEntity(
        type: HomeMetricType.diaper,
        count: 0,
        totalMinutes: 0,
      ),
    ],
    activeRegisterEvents: const [],
    upcomingHealthEvent: null,
    mostRecentEvent: null,
  );
}

class _MockGetHomeOverview extends Mock implements GetHomeOverview {}

class _MockFinishActiveRegisterEvent extends Mock
    implements FinishActiveRegisterEvent {}
