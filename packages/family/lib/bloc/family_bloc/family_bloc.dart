import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_bloc.freezed.dart';
part 'family_event.dart';
part 'family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  FamilyBloc() : super(const FamilyState.initial()) {
    on<_Started>((event, emit) async {
      emit(const FamilyState.loading());
      // TODO(family): ejecutar caso de uso.
      emit(const FamilyState.loaded());
    });
  }
}
