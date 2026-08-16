import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:home/home.dart';

typedef GetRegisterEventsFactory = GetRegisterEvents Function(
  BuildContext context,
);
typedef HomeDailyHistoryAction = void Function(BuildContext context);
typedef DeleteRegisterEventFactory = DeleteRegisterEvent Function(
  BuildContext context,
);
typedef FinishActiveRegisterEventFactory = FinishActiveRegisterEvent Function(
  BuildContext context,
);
typedef RegisterReminderDeleted = Future<void> Function(String eventId);
typedef RegisterEventSyncServiceFactory = RegisterEventSyncService Function(
  BuildContext context,
);
typedef HomeFamilyOverviewFactory = GetFamilyOverview Function(
  BuildContext context,
);

class HomeDailyHistoryPage extends GoRoute {
  HomeDailyHistoryPage({
    required GetRegisterEventsFactory getRegisterEvents,
    required HomeDailyHistoryAction onRegisterPressed,
    this.deleteRegisterEvent,
    this.finishActiveRegisterEvent,
    this.onEventDeleted,
    this.syncService,
    this.getFamilyOverview,
    this.babyId = 'baby-preview',
    this.babyName = 'Tu bebé',
    super.name,
    super.parentNavigatorKey,
    super.routes,
  }) : super(
          path: relativePath,
          pageBuilder: (context, state) {
            return MaterialPage<void>(
              key: const ValueKey('home-daily-history'),
              name: name ?? nameRoute,
              child: getFamilyOverview == null
                  ? _HomeDailyHistoryContent(
                      getRegisterEvents: getRegisterEvents,
                      deleteRegisterEvent: deleteRegisterEvent,
                      finishActiveRegisterEvent: finishActiveRegisterEvent,
                      onEventDeleted: onEventDeleted,
                      syncService: syncService,
                      babyId: babyId,
                      babyName: babyName,
                      onRegisterPressed: onRegisterPressed,
                    )
                  : FutureBuilder<FamilyOverviewEntity>(
                      future: getFamilyOverview(context)(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: SizedBox.shrink(),
                          );
                        }
                        final baby = snapshot.data!.activeBaby;
                        return _HomeDailyHistoryContent(
                          getRegisterEvents: getRegisterEvents,
                          deleteRegisterEvent: deleteRegisterEvent,
                          finishActiveRegisterEvent: finishActiveRegisterEvent,
                          onEventDeleted: onEventDeleted,
                          syncService: syncService,
                          babyId: baby.id,
                          babyName: baby.name,
                          onRegisterPressed: onRegisterPressed,
                        );
                      },
                    ),
            );
          },
        );

  final String babyId;
  final String babyName;
  final DeleteRegisterEventFactory? deleteRegisterEvent;
  final FinishActiveRegisterEventFactory? finishActiveRegisterEvent;
  final RegisterReminderDeleted? onEventDeleted;
  final RegisterEventSyncServiceFactory? syncService;
  final HomeFamilyOverviewFactory? getFamilyOverview;

  static const nameRoute = 'HomeDailyHistory';
  static const relativePath = 'history';
  static const fullPath = '/home/history';
}

class _HomeDailyHistoryContent extends StatelessWidget {
  const _HomeDailyHistoryContent({
    required this.getRegisterEvents,
    required this.deleteRegisterEvent,
    required this.finishActiveRegisterEvent,
    required this.onEventDeleted,
    required this.syncService,
    required this.babyId,
    required this.babyName,
    required this.onRegisterPressed,
  });

  final GetRegisterEventsFactory getRegisterEvents;
  final DeleteRegisterEventFactory? deleteRegisterEvent;
  final FinishActiveRegisterEventFactory? finishActiveRegisterEvent;
  final RegisterReminderDeleted? onEventDeleted;
  final RegisterEventSyncServiceFactory? syncService;
  final String babyId;
  final String babyName;
  final HomeDailyHistoryAction onRegisterPressed;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => HomeDailyHistoryCubit(
          getRegisterEvents: getRegisterEvents(context),
          deleteRegisterEvent: deleteRegisterEvent?.call(context),
          finishActiveRegisterEvent: finishActiveRegisterEvent?.call(context),
          onEventDeleted: onEventDeleted,
          syncService: syncService?.call(context),
          babyId: babyId,
        )..load(),
        child: HomeDailyHistoryView(
          babyName: babyName,
          onRegisterPressed: () => onRegisterPressed(context),
        ),
      );
}
