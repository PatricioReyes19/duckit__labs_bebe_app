import 'package:agenda/agenda.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AgendaBloc()..add(const AgendaStarted()),
    child: const AgendaView(),
  );
}
