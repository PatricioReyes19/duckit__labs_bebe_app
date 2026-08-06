import 'package:core/core.dart';
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
    this.minimumDisplayDuration = const Duration(milliseconds: 700),
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
  final Duration minimumDisplayDuration;

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
    final displayStopwatch = Stopwatch()..start();

    try {
      final resolution = await _resolveEntryDestination();
      await _waitForMinimumDisplayDuration(displayStopwatch.elapsed);

      if (resolution.destination == EntryDestination.authEntry) {
        emit(const SplashState.authEntry());
        return;
      }

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

  Future<void> _waitForMinimumDisplayDuration(Duration elapsed) async {
    final remaining = minimumDisplayDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
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
