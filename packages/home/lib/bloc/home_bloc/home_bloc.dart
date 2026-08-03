import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<HomeStarted>((e, emit) async {
      emit(const HomeLoading());
      emit(const HomeLoaded());
    });
    on<HomeRetried>((e, emit) => add(const HomeStarted()));
  }
}
