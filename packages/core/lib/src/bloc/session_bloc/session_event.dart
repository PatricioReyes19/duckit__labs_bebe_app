part of 'session_bloc.dart';

sealed class SessionEvent {
  const SessionEvent();
}

final class SessionStarted extends SessionEvent {
  const SessionStarted();
}

final class SessionResumed extends SessionEvent {
  const SessionResumed();
}

final class SessionSignOutRequested extends SessionEvent {
  const SessionSignOutRequested();
}

final class _SessionChanged extends SessionEvent {
  const _SessionChanged(this.session);

  final AuthSession? session;
}

final class _SessionStreamFailed extends SessionEvent {
  const _SessionStreamFailed(this.error);

  final Object error;
}
