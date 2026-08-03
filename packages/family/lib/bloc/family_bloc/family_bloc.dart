import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'family_event.dart';
part 'family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  FamilyBloc() : super(const FamilyInitial()) {
    on<FamilyStarted>(_onStarted);
    on<FamilyRefreshed>(_onRefreshed);
    on<FamilyRetried>(_onRetried);
  }
  Future<void> _onStarted(
    FamilyStarted event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      emit(const FamilyLoaded());
    } on Object catch (error) {
      emit(FamilyFailure(message: error.toString()));
    }
  }

  Future<void> _onRefreshed(
    FamilyRefreshed event,
    Emitter<FamilyState> emit,
  ) async {}
  Future<void> _onRetried(
    FamilyRetried event,
    Emitter<FamilyState> emit,
  ) async {
    add(const FamilyStarted());
  }
}
