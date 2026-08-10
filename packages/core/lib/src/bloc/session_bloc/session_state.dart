part of 'session_bloc.dart';

sealed class SessionState {
  const SessionState();
}

final class SessionInitial extends SessionState {
  const SessionInitial();
}

final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.session);

  final AuthSession session;
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

final class SessionFailureState extends SessionState {
  const SessionFailureState(this.failure);

  final SessionFailure failure;
}
