import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';

typedef HealthBlocFactory = HealthBloc Function(BuildContext context);

class HealthPage extends GoRoute {
  HealthPage({required HealthBlocFactory healthBloc, super.name, super.routes})
    : super(
        path: fullPath,
        pageBuilder: (context, state) {
          return CupertinoPage<void>(
            key: const ValueKey('health'),
            name: name ?? nameRoute,
            child: BlocProvider(
              create: (context) =>
                  healthBloc(context)..add(const HealthEvent.started()),
              child: const HealthView(),
            ),
          );
        },
      );

  static const nameRoute = 'Health';
  static const fullPath = '/health';

  static void open(BuildContext context) => context.go(fullPath);
}
