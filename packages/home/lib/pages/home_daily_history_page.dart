import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:home/home.dart';

typedef GetRegisterEventsFactory = GetRegisterEvents Function(
  BuildContext context,
);
typedef HomeDailyHistoryAction = void Function(BuildContext context);

class HomeDailyHistoryPage extends GoRoute {
  HomeDailyHistoryPage({
    required GetRegisterEventsFactory getRegisterEvents,
    required HomeDailyHistoryAction onRegisterPressed,
    this.babyId = 'local-active-baby',
    this.babyName = 'Mateo Reyes',
    super.name,
    super.parentNavigatorKey,
    super.routes,
  }) : super(
          path: relativePath,
          pageBuilder: (context, state) {
            return CupertinoPage<void>(
              key: const ValueKey('home-daily-history'),
              name: name ?? nameRoute,
              child: BlocProvider(
                create: (_) => HomeDailyHistoryCubit(
                  getRegisterEvents: getRegisterEvents(context),
                  babyId: babyId,
                )..load(),
                child: HomeDailyHistoryView(
                  babyName: babyName,
                  onRegisterPressed: () => onRegisterPressed(context),
                ),
              ),
            );
          },
        );

  final String babyId;
  final String babyName;

  static const nameRoute = 'HomeDailyHistory';
  static const relativePath = 'history';
  static const fullPath = '/home/history';
}
