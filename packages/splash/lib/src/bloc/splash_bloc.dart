import 'package:core/startup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash_bloc.freezed.dart';
part 'splash_event.dart';
part 'splash_state.dart';

typedef SplashErrorReporter = void Function(
  Object error,
  StackTrace stackTrace,
);

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({
    required ResolveEntryDestination resolveEntryDestination,
    SplashErrorReporter? errorReporter,
  })  : _resolveEntryDestination = resolveEntryDestination,
        _errorReporter = errorReporter,
        super(const SplashState.resolving()) {
    on<_Started>(_onResolveRequested);
    on<_Retried>(_onResolveRequested);
    on<_LoginRequested>(_onLoginRequested);
    on<_SignUpRequested>(_onSignUpRequested);

    add(const SplashEvent.started());
  }

  final ResolveEntryDestination _resolveEntryDestination;
  final SplashErrorReporter? _errorReporter;

  bool _isResolving = false;

  Future<void> _onResolveRequested(
    SplashEvent event,
    Emitter<SplashState> emit,
  ) async {
    if (_isResolving) {
      return;
    }

    _isResolving = true;
    emit(const SplashState.resolving());

    try {
      final resolution = await _resolveEntryDestination();
      emit(SplashState.routeRequested(destination: resolution.destination));
    } on Object catch (error, stackTrace) {
      _errorReporter?.call(error, stackTrace);

      emit(
        const SplashState.failure(
          message: 'No pudimos preparar BebéApp. Intenta nuevamente.',
          canRetry: true,
        ),
      );
    } finally {
      _isResolving = false;
    }
  }

  void _onLoginRequested(
    _LoginRequested event,
    Emitter<SplashState> emit,
  ) {
    emit(
      const SplashState.routeRequested(
        destination: EntryDestination.login,
      ),
    );
  }

  void _onSignUpRequested(
    _SignUpRequested event,
    Emitter<SplashState> emit,
  ) {
    emit(
      const SplashState.routeRequested(
        destination: EntryDestination.signUp,
      ),
    );
  }
}
