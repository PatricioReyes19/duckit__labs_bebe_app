import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home/home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (_) => HomeBloc()..add(const HomeStarted()),
      child: const HomeView());
}
