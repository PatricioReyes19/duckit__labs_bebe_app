import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'active_baby_event.dart';
part 'active_baby_state.dart';

class ActiveBabyBloc extends Bloc<ActiveBabyEvent, ActiveBabyState> {
  ActiveBabyBloc() : super(ActiveBabyInitial()) {
    on<ActiveBabyEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
