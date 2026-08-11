import 'package:agenda/agenda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

typedef AgendaBlocFactory = AgendaBloc Function(BuildContext context);
typedef AgendaRouteAction = void Function(BuildContext context);
typedef AgendaEventRouteAction =
    void Function(BuildContext context, String eventId);

class AgendaPage extends GoRoute {
  AgendaPage({
    required AgendaBlocFactory agendaBloc,
    required AgendaRouteAction openNotifications,
    required AgendaRouteAction openReminderSettings,
    required AgendaRouteAction openHealth,
    required AgendaRouteAction createReminder,
    required AgendaRouteAction registerEvent,
    required AgendaRouteAction openRegisterHistory,
    required AgendaEventRouteAction openEvent,
    super.name,
    super.routes,
  }) : super(
         path: fullPath,
         pageBuilder: (context, state) {
           return MaterialPage<void>(
             key: const ValueKey('agenda'),
             name: name ?? nameRoute,
             child: BlocProvider(
               create: (context) =>
                   agendaBloc(context)..add(const AgendaEvent.started()),
               child: AgendaView(
                 onNotificationsPressed: () => openNotifications(context),
                 onConfigureRemindersPressed: () =>
                     openReminderSettings(context),
                 onHealthPressed: () => openHealth(context),
                 onCreateReminderPressed: () => createReminder(context),
                 onRegisterPressed: () => registerEvent(context),
                 onRegisterHistoryPressed: () => openRegisterHistory(context),
                 onEventPressed: (eventId) => openEvent(context, eventId),
               ),
             ),
           );
         },
       );

  static const nameRoute = 'Agenda';
  static const fullPath = '/agenda';

  static void open(BuildContext context) => context.go(fullPath);
}
