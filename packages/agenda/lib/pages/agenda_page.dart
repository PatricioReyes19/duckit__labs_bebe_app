import 'package:agenda/agenda.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

typedef AgendaBlocFactory = AgendaBloc Function(BuildContext context);

class AgendaPage extends GoRoute {
  AgendaPage({required AgendaBlocFactory agendaBloc, super.name, super.routes})
    : super(
        path: fullPath,
        pageBuilder: (context, state) {
          return CupertinoPage<void>(
            key: const ValueKey('agenda'),
            name: name ?? nameRoute,
            child: BlocProvider(
              create: (context) =>
                  agendaBloc(context)..add(const AgendaEvent.started()),
              child: const AgendaView(),
            ),
          );
        },
      );

  static const nameRoute = 'Agenda';
  static const fullPath = '/agenda';

  static void open(BuildContext context) => context.go(fullPath);
}
