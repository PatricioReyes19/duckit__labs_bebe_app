import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/onboarding_cubit.dart';
import '../domain/onboarding_repository.dart';
import '../models/models.dart';
import '../views/onboarding_view.dart';

typedef OnboardingRepositoryFactory = OnboardingRepository Function(
  BuildContext context,
);

typedef OnboardingRouteAction = void Function(BuildContext context);

/// Ruta raíz del flujo de onboarding.
///
/// La composición de navegación permanece en `app_base`, mientras este
/// paquete conserva la creación del Cubit y de su View, igual que el resto de
/// los paquetes de feature.
class OnboardingPage extends GoRoute {
  OnboardingPage({
    required super.path,
    required OnboardingRepositoryFactory onboardingRepository,
    required OnboardingEntry entry,
    required OnboardingRouteAction onCompleted,
    required OnboardingRouteAction onExitRequested,
    required OnboardingRouteAction onUseAnotherAccount,
    super.name,
    super.parentNavigatorKey,
    super.redirect,
    super.routes,
  }) : super(
          pageBuilder: (context, state) {
            return CupertinoPage<void>(
              key: ValueKey('onboarding-${entry.name}'),
              name: name ?? nameRoute,
              child: BlocProvider(
                create: (_) {
                  final cubit = OnboardingCubit(
                    repository: onboardingRepository(context),
                    entry: entry,
                  );
                  final invitationCode =
                      state.uri.queryParameters['code']?.trim();
                  if (entry == OnboardingEntry.invitation &&
                      invitationCode != null &&
                      invitationCode.isNotEmpty) {
                    cubit.invitationCodeChanged(invitationCode);
                    unawaited(cubit.invitationSubmitted());
                  }
                  return cubit;
                },
                child: OnboardingView(
                  entry: entry,
                  onCompleted: () => onCompleted(context),
                  onExitRequested: () => onExitRequested(context),
                  onUseAnotherAccount: () => onUseAnotherAccount(context),
                ),
              ),
            );
          },
        );

  static const nameRoute = 'Onboarding';
  static const fullPath = '/onboarding';

  static void open(BuildContext context) => context.go(fullPath);
}
