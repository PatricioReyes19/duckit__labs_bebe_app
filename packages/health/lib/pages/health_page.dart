import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => HealthBloc()..add(const HealthStarted()),
    child: const HealthView(),
  );
}
