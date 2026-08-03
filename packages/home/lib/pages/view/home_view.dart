import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home/home.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) => switch (state) {
            HomeInitial() ||
            HomeLoading() =>
              const Center(child: CircularProgressIndicator()),
            HomeFailure(:final message) => Center(child: Text(message)),
            HomeLoaded() =>
              const SizedBox.expand(child: Center(child: Text('Home'))),
          });
}
