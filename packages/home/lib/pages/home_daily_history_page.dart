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
                  ? _historyContent(
                      context: context,
                      getRegisterEvents: getRegisterEvents,
                      deleteRegisterEvent: deleteRegisterEvent,
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
                        return _historyContent(
                          context: context,
                          getRegisterEvents: getRegisterEvents,
                          deleteRegisterEvent: deleteRegisterEvent,
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
  final RegisterEventSyncServiceFactory? syncService;
  final HomeFamilyOverviewFactory? getFamilyOverview;

  static const nameRoute = 'HomeDailyHistory';
  static const relativePath = 'history';
  static const fullPath = '/home/history';
}

Widget _historyContent({
  required BuildContext context,
  required GetRegisterEventsFactory getRegisterEvents,
  required DeleteRegisterEventFactory? deleteRegisterEvent,
  required RegisterEventSyncServiceFactory? syncService,
  required String babyId,
  required String babyName,
  required HomeDailyHistoryAction onRegisterPressed,
}) =>
    BlocProvider(
      create: (_) => HomeDailyHistoryCubit(
        getRegisterEvents: getRegisterEvents(context),
        deleteRegisterEvent: deleteRegisterEvent?.call(context),
        syncService: syncService?.call(context),
        babyId: babyId,
      )..load(),
      child: HomeDailyHistoryView(
        babyName: babyName,
        onRegisterPressed: () => onRegisterPressed(context),
      ),
    );
