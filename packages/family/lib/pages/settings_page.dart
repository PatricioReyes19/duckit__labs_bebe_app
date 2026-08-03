import 'package:family/family.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SettingsBloc()..add(const SettingsStarted()),
    child: const SettingsView(),
  );
}
