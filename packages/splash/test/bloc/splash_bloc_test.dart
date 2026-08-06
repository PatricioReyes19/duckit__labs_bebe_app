import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splash/splash.dart';

class _FakeResolver implements ResolveEntryDestination {
  _FakeResolver(this.resolution);

  final EntryResolution resolution;

  @override
  Future<EntryResolution> call() async => resolution;
}

class _ThrowingResolver implements ResolveEntryDestination {
  @override
  Future<EntryResolution> call() => throw StateError('startup failed');
}

void main() {
  for (final destination in EntryDestination.values.where(
    (destination) => destination != EntryDestination.authEntry,
  )) {
    blocTest<SplashBloc, SplashState>(
      'solicita la ruta de $destination cuando el inicio la resuelve',
      build: () => SplashBloc(
        minimumDisplayDuration: Duration.zero,
        resolveEntryDestination: _FakeResolver(
          EntryResolution(destination: destination),
        ),
      ),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        const SplashState.resolving(),
        SplashState.routeRequested(destination: destination),
      ],
    );
  }

  blocTest<SplashBloc, SplashState>(
    'sin sesión muestra entrada de autenticación',
    build: () => SplashBloc(
      minimumDisplayDuration: Duration.zero,
      resolveEntryDestination: _FakeResolver(
        const EntryResolution(
          destination: EntryDestination.authEntry,
        ),
      ),
    ),
    wait: const Duration(milliseconds: 10),
    expect: () => const [
      SplashState.resolving(),
      SplashState.authEntry(),
    ],
  );

  Object? reportedError;
  blocTest<SplashBloc, SplashState>(
    'muestra error recuperable y reporta el fallo de inicio',
    build: () => SplashBloc(
      minimumDisplayDuration: Duration.zero,
      resolveEntryDestination: _ThrowingResolver(),
      errorReporter: (error, _) => reportedError = error,
    ),
    wait: const Duration(milliseconds: 10),
    expect: () => const [
      SplashState.resolving(),
      SplashState.failure(
        message: 'No pudimos preparar BebéApp. Intenta nuevamente.',
        canRetry: true,
      ),
    ],
    verify: (_) => expect(reportedError, isA<StateError>()),
  );
}
