import 'dart:async';
import 'dart:developer' as developer;

/// Runs an offline-first upload without leaking failures to the root zone.
///
/// The local mutation has already succeeded when this is called, so callers
/// intentionally do not await network completion. Failures remain visible in
/// the sync service state and are also logged with their stack trace.
void scheduleBackgroundSync<T>(
  Future<T> Function() synchronize, {
  required String operation,
}) {
  unawaited(
    Future<T>.sync(synchronize).then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          '$operation failed',
          name: 'bebeapp.sync',
          error: error,
          stackTrace: stackTrace,
        );
      },
    ),
  );
}
