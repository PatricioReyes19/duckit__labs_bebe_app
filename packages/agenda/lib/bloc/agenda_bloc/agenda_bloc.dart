import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'agenda_event.dart';
part 'agenda_state.dart';
class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc() : super(const AgendaInitial()) { on<AgendaStarted>(_onStarted); on<AgendaRefreshed>(_onRefreshed); on<AgendaRetried>(_onRetried); }
  Future<void> _onStarted(AgendaStarted event, Emitter<AgendaState> emit) async { emit(const AgendaLoading()); try { emit(const AgendaLoaded()); } on Object catch (error) { emit(AgendaFailure(message: error.toString())); } }
  Future<void> _onRefreshed(AgendaRefreshed event, Emitter<AgendaState> emit) async {}
  Future<void> _onRetried(AgendaRetried event, Emitter<AgendaState> emit) async { add(const AgendaStarted()); }
}
