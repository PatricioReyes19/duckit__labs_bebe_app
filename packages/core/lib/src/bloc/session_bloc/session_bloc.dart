import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../domain/entities/session/session_entity.dart';
import '../../domain/use_cases/session/session.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({
    required ObserveSession observeSession,
    required RefreshSession refreshSession,
    required SignOutSession signOutSession,
  }) : _observeSession = observeSession,
       _refreshSession = refreshSession,
       _signOutSession = signOutSession,
       super(const SessionInitial()) {
    on<SessionStarted>(_onStarted);
    on<SessionResumed>(_onResumed);
    on<SessionSignOutRequested>(_onSignOutRequested);
    on<_SessionChanged>(_onSessionChanged);
    on<_SessionStreamFailed>(_onSessionStreamFailed);
  }

  final ObserveSession _observeSession;
  final RefreshSession _refreshSession;
  final SignOutSession _signOutSession;

  StreamSubscription<AuthSession?>? _sessionSubscription;

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    await _sessionSubscription?.cancel();

    _sessionSubscription = _observeSession().listen(
      (session) {
        add(_SessionChanged(session));
      },
      onError: (Object error) {
        add(_SessionStreamFailed(error));
      },
    );
  }

  Future<void> _onResumed(
    SessionResumed event,
    Emitter<SessionState> emit,
  ) async {
    try {
      final session = await _refreshSession();

      if (session == null) {
        emit(const SessionUnauthenticated());
        return;
      }

      emit(SessionAuthenticated(session));
    } on SessionFailure catch (failure) {
      // Una caída de red no debería expulsar al usuario
      // de una aplicación offline-first.
      if (state is SessionAuthenticated) {
        return;
      }

      emit(SessionFailureState(failure));
    }
  }

  Future<void> _onSignOutRequested(
    SessionSignOutRequested event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await _signOutSession();

      // No emitimos manualmente.
      //
      // Firebase provocará sessionChanges() -> null.
    } on SessionFailure catch (failure) {
      emit(SessionFailureState(failure));
    }
  }

  void _onSessionChanged(_SessionChanged event, Emitter<SessionState> emit) {
    final session = event.session;

    if (session == null) {
      emit(const SessionUnauthenticated());
      return;
    }

    emit(SessionAuthenticated(session));
  }

  void _onSessionStreamFailed(
    _SessionStreamFailed event,
    Emitter<SessionState> emit,
  ) {
    if (state is SessionAuthenticated) {
      return;
    }

    final error = event.error;

    emit(
      SessionFailureState(
        error is SessionFailure
            ? error
            : SessionFailure(SessionFailureCode.unknown, error.toString()),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();

    return super.close();
  }
}
