import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agenda_bloc.freezed.dart';
part 'agenda_event.dart';
part 'agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc() : super(const AgendaState.initial()) {
    on<_Started>((event, emit) async {
      emit(const AgendaState.loading());
      // TODO(agenda): ejecutar caso de uso.
      emit(const AgendaState.loaded());
    });
    on<_Retried>((event, emit) {
      add(const AgendaEvent.started());
    });
  }
}
