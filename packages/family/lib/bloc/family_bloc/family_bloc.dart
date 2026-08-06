import 'package:family/models/family_overview_vm.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_bloc.freezed.dart';
part 'family_event.dart';
part 'family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  FamilyBloc() : super(const FamilyState.initial()) {
    on<_Started>(_onStarted);
    on<_Retried>((event, emit) => add(const FamilyEvent.started()));
    on<_BabySelected>(_onBabySelected);
  }

  Future<void> _onStarted(
    _Started event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyState.loading());
    await Future<void>.delayed(const Duration(milliseconds: 250));
    emit(FamilyState.loaded(overview: _mockOverview()));
  }

  void _onBabySelected(
    _BabySelected event,
    Emitter<FamilyState> emit,
  ) {
    final current = state;
    if (current is! FamilyLoaded) {
      return;
    }

    final exists = current.overview.babies.any(
      (baby) => baby.id == event.babyId,
    );

    if (!exists) {
      return;
    }

    emit(
      FamilyState.loaded(
        overview: current.overview.copyWith(
          activeBabyId: event.babyId,
        ),
      ),
    );
  }

  FamilyOverviewVm _mockOverview() {
    return const FamilyOverviewVm(
      familyName: 'Familia Reyes González',
      activeBabyId: 'emilia',
      pendingInvitations: 1,
      babies: [
        FamilyBabyVm(
          id: 'emilia',
          name: 'Emilia Reyes',
          ageLabel: '2 meses y 8 días',
          initials: 'ER',
          avatarVariant: FamilyAvatarVariant.brand,
        ),
        FamilyBabyVm(
          id: 'sofia',
          name: 'Sofía Reyes',
          ageLabel: '8 meses',
          initials: 'SR',
          avatarVariant: FamilyAvatarVariant.accent,
        ),
      ],
      members: [
        FamilyMemberVm(
          id: 'gesslien',
          name: 'Gesslien González',
          role: 'Mamá',
          accessDescription: 'Puede registrar y ver salud',
          initials: 'GG',
          avatarVariant: FamilyAvatarVariant.brand,
        ),
        FamilyMemberVm(
          id: 'patricio',
          name: 'Patricio Reyes',
          role: 'Papá',
          accessDescription: 'Puede registrar y ver salud',
          initials: 'PR',
          avatarVariant: FamilyAvatarVariant.information,
        ),
        FamilyMemberVm(
          id: 'rosa',
          name: 'Rosa González',
          role: 'Abuela',
          accessDescription: 'Acceso de colaboración',
          initials: 'RG',
          avatarVariant: FamilyAvatarVariant.accent,
        ),
        FamilyMemberVm(
          id: 'carolina',
          name: 'Carolina Soto',
          role: 'Tía',
          accessDescription: 'Invitación pendiente',
          initials: 'CS',
          avatarVariant: FamilyAvatarVariant.warning,
          status: FamilyMemberStatus.pending,
        ),
      ],
    );
  }
}
